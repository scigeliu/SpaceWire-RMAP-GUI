//
//  SpaceWireViewController.m
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/24.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "SpaceWireViewController.h"

@implementation SpaceWireViewController

class TimecodeThread : public CxxUtilities::StoppableThread {
private:
	SpaceWireIF* spwif;
	double waitDurationInMilliSec;
	uint8_t initialTimecode;
	id parent;
	NSTextField* timecodeValueCell;
public:
	TimecodeThread(id parent,SpaceWireIF* spwif,double waitDurationInMilliSec,NSTextField* timecodeValueCell,uint8_t initialTimecode=0){
		this->parent=parent;
		this->spwif=spwif;
		this->waitDurationInMilliSec=waitDurationInMilliSec;
		this->initialTimecode=initialTimecode;
		this->timecodeValueCell=timecodeValueCell;
		stopped=false;
	}
	
public:
	void run(){
		stopped=false;
		uint8_t timecode=initialTimecode;
		while(!stopped){
			try{
				spwif->emitTimecode(timecode);
				[timecodeValueCell setIntValue:(uint32_t)timecode];
				sleep(waitDurationInMilliSec);
				if(timecode>=63){
					timecode=0;
				}else{
					timecode++;
				}
			}catch(SpaceWireIFException e){
				[parent stopPeriodicTimecodeEmission];
				[parent handleSpaceWireIFException:e];
				stop();
			}
		}
	}
	
public:
	double getWaitDurationInMilliSec(){
		return waitDurationInMilliSec;
	}
};

class ReceiveThread : public CxxUtilities::StoppableThread {
private:
	SpaceWireIF* spwif;
	double timeoutDurationInMilliSec;
	static const double TimeoutDurationForContinuousReceiveInMilliSec=10;//ms
	id parent;
	std::vector<uint8_t>* latestPacket;
	std::string lastEndOfPacketMarker;
	
private:
	bool newPacketArrived;
	
public:
	CxxUtilities::Mutex mutex;
	
public:
	ReceiveThread(id parent,SpaceWireIF* spwif,double timeoutDurationInMilliSec=TimeoutDurationForContinuousReceiveInMilliSec){
		this->parent=parent;
		this->spwif=spwif;
		this->timeoutDurationInMilliSec=timeoutDurationInMilliSec;
		this->lastEndOfPacketMarker="";
		this->latestPacket=new std::vector<uint8_t>();
	}
	
public:
	void run(){
		stopped=false;
		spwif->setTimeoutDuration(timeoutDurationInMilliSec*1000.0);//in units of us
		spwif->eepShouldNotBeReportedAsAnException();
		newPacketArrived=false;
		while(!stopped){
			try{
				std::vector<uint8_t>* data=spwif->receive();
				mutex.lock();
				*latestPacket=*data;
				if(spwif->isTerminatedWithEOP()){//terminated with EOP
					lastEndOfPacketMarker="EOP";
				}else if(spwif->isTerminatedWithEEP()){//terminated with EEP
					lastEndOfPacketMarker="EEP";
				}else{//end-of-packet marker was not recognized
					lastEndOfPacketMarker="EOP_NOT_RECOGNIZED";
				}
				newPacketArrived=true;
				mutex.unlock();
			}catch(SpaceWireIFException e){
				if(e.getStatus()==SpaceWireIFException::Timeout){
					//do nothing
					continue;
				}
				[parent handleSpaceWireIFException:e];
				stop();
			}
		}
	}

	std::vector<uint8_t>* getLatestPacket(){
		return latestPacket;
	}
	
	std::string getLastEndOfPacketMarker(){
		return lastEndOfPacketMarker;
	}
	
public:
	void resetNewPacketArrived(){
		newPacketArrived=false;
	}
	
	bool hasNewPacketArrived(){
		return newPacketArrived;
	}
};

class UpdateThread : public CxxUtilities::StoppableThread {
private:
	id parent;
	CxxUtilities::Condition c;
	static const double WaitDuration=100;//ms
public:
	UpdateThread(id parent){
		this->parent=parent;
	}

public:
	void run(){
		stopped=false;
		while(!stopped){
			c.wait(WaitDuration);
				[parent updateReceivedPacket];
		}
	}
};

- (id)init{
	spacewireViewContollerCloseActionStopContinuousReceiveInstance=new SpaceWireViewContollerCloseActionStopContinuousReceive(self);
	isContinuouslyReceiving=false;
	updateThread=new UpdateThread(self);
	updateThread->start();
	return self;
}

- (void)dealloc{
	updateThread->stop();
	CxxUtilities::Condition c;
	c.wait([mainController getDefaultThreadWaitDuraion]);
	delete updateThread;
	[super dealloc];
}

- (void)saveDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	/*
	 // NSUserDefaultsに保存・更新する
	 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
	 [ud setInteger:100 forKey:@"KEY_I"];  // int型の100をKEY_Iというキーで保存
	 [ud setFloat:1.23 forKey:@"KEY_F"];  // float型の1.23をKEY_Fというキーで保存
	 [ud setDouble:1.23 forKey:@"KEY_D"];  // double型の1.23をKEY_Dというキーで保存
	 [ud setBool:YES forKey:@"KEY_B"];  // BOOL型のYESをKEY_Bというキーで保存
	 [ud setObject:@"あいう" forKey:@"KEY_S"];  // "あいう"をKEY_Sというキーで保存
	 [ud synchronize];  // NSUserDefaultsに即時反映させる（即時で無くてもよい場合は不要）
	 */
	
	//initiator/target information
	[ud setObject:[timecodeFrequencyCell stringValue] forKey:@"SpaceWire.TimecodeFrequencyCell"];
	[ud setObject:[timecodeValueCell stringValue] forKey:@"SpaceWire.TimecodeValueCell"];
}

- (void)restoreDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	[timecodeFrequencyCell setStringValue:[ud stringForKey:@"SpaceWire.TimecodeFrequencyCell"]];
	[timecodeValueCell setStringValue:[ud stringForKey:@"SpaceWire.TimecodeValueCell"]];
}

- (bool)spaceWireIFAvailable{
	if([mainController isSpaceWireIFSet]==false){
		[Utility showDialogBox:@"SpaceWire I/F is not connected." :@"Connect first."];
	}
	return [mainController isSpaceWireIFSet];
}

- (void)sendPacket:(uint32_t)eopType{
	using namespace std;
	using namespace CxxUtilities;
	if(![self spaceWireIFAvailable]){
		return;
	}
	std::vector<uint8_t> data;
	try{
		[sendPacketCell selectAll:nil];
		string str=[Utility toString:[sendPacketCell string]];
		if([allHexButton state]==NSOnState){
			str=String::put0xForAllElements(str);
		}
		data=String::toUInt8Array(str);
	}catch(...){
		[Utility showDialogBox:@"Invalid send packet data." :@""];
		return;
	}
	SpaceWireIF* spwif=[mainController getSpaceWireIFInstance];
	try{
		spwif->send(data,SpaceWireEOPMarker::EOP);
	}catch(SpaceWireIFException e){
		[self handleSpaceWireIFException:e];
		return;
	}
	std::stringstream ss;
	ss << "Sent a SpaceWire packet (" << std::dec << data.size() << ") bytes.";
	[mainController addMessageString:ss.str()];
	return;
}

- (IBAction)sendWithEOPButtonClicked:(id)sender {
	[self sendPacket:SpaceWireEOPMarker::EOP];
}

- (IBAction)sendWithEEPButtonClicked:(id)sender {
	[self sendPacket:SpaceWireEOPMarker::EEP];
}

- (bool)isTimeoutDurationValid{
	if([receiveTimeoutCell doubleValue]<1){//1ms
		[Utility showDialogBox:@"Receive timeout duration is too short." :@"Set value longer than 1 ms."];
		return false;
	}else if([receiveTimeoutCell doubleValue]>100000){//100s
		[Utility showDialogBox:@"Receive timeout duration is too long." :@"Set value shorter than 100 s."];
		return false;
	}else{
		return true;
	}
}

- (IBAction)receiveOnePacketButtonClicked:(id)sender {
	using namespace std;
	if(isContinuouslyReceiving==true){
		[Utility showDialogBox:@"Continuous packet receive is taking place." :@"Stop continuous receive to receive single packet."];
		return;
	}
	if(![self spaceWireIFAvailable]){
		return;
	}
	if(![self isTimeoutDurationValid]){
		return;
	}
	SpaceWireIF* spwif=[mainController getSpaceWireIFInstance];
	double timeoutDurationInMicroSec=[receiveTimeoutCell doubleValue]*1000.0;
	spwif->setTimeoutDuration(timeoutDurationInMicroSec);//in units of us
	spwif->eepShouldNotBeReportedAsAnException();
	std::vector<uint8_t>* data;
	[mainController addMessage:@"Receive wait..."];
	try{
		data=spwif->receive();
	}catch(SpaceWireIFException e){
		[self handleSpaceWireIFException:e];
		return;
	}
	[Utility setVectorUint8Pointer:data to:receivePacketCell];
	using namespace std;
	stringstream ss;
	if(data->size()<2){
		ss << "Has received " << dec << data->size() << " byte.";
	}else{
		ss << "Has received " << dec << data->size() << " bytes.";
	}
	[mainController addMessageString:ss.str()];
	return;
}

- (void)startContinuousReceive {
	if(isContinuouslyReceiving==false){
		if(![self spaceWireIFAvailable]){
			return;
		}
		SpaceWireIF* spwif=[mainController getSpaceWireIFInstance];
		receiveThread=new ReceiveThread(self,spwif);
		receiveThread->start();
		isContinuouslyReceiving=true;
		[receiveContinuousButton setTitle:@"Stop receive"];
		[mainController addMessage:@"Continuous packet receive has been started."];
	}
}

- (bool)isContinuouslyReceivingPackets{
	return isContinuouslyReceiving;
}

- (void)stopContinuousPacketReceive {
	if(isContinuouslyReceiving==true){
		receiveThread->stop();
		CxxUtilities::Condition c;
		c.wait([mainController getDefaultThreadWaitDuraion]);
		delete receiveThread;
		isContinuouslyReceiving=false;
		[receiveContinuousButton setTitle:@"Receive (continuous)"];
		[mainController addMessage:@"Continuous packet receive has been stopped."];
	}
}

- (IBAction)receiveContinuouslyButtonClicked:(id)sender {
	if(isContinuouslyReceiving==false){
		[self startContinuousReceive];
	}else{
		[self stopContinuousPacketReceive];
	}
}

- (IBAction)saveReceivedPacketButtonClicked:(id)sender {
}

- (void)startPeriodicTimecodeEmission {
	if(![self spaceWireIFAvailable]){
		return;
	}
	double waitdurationInMilliSec=1000.0/[timecodeFrequencyCell doubleValue];
	uint8_t initialTimecode=[timecodeValueCell intValue];
	if(waitdurationInMilliSec<1.0){
		[Utility showDialogBox:@"Too high timecode frequency." :@"Timecode frequency lower than 1000 Hz can be set."];
		return;
	}
	if(initialTimecode>63){
		[Utility showDialogBox:@"Initial timecode value is invalid." :@"Timecode value shall be 0-63."];
		return;
	}
	timecodeThread=new TimecodeThread(self,[mainController getSpaceWireIFInstance],waitdurationInMilliSec,currentTimecodeValueCell,initialTimecode);
	timecodeThread->start();
	emittingTimecode=true;
	[mainController addMessage:@""];
	[emitContinuouslyButton setTitle:@"Stop timecode"];
	[timecodeStatusCell setStringValue:@"Emitting"];
	using namespace std;
	stringstream ss;
	ss << "Periodic timecode emission has been started (" << [timecodeFrequencyCell doubleValue] << "Hz).";
	[mainController addMessageString:ss.str()];
}

- (void)stopPeriodicTimecodeEmission {
	if(emittingTimecode==true){
		timecodeThread->stop();
		CxxUtilities::Condition c;
		c.wait(timecodeThread->getWaitDurationInMilliSec()*1.01);//wait 
		delete timecodeThread;
		emittingTimecode=false;
		[emitContinuouslyButton setTitle:@"Emit periodically"];
		[timecodeStatusCell setStringValue:@"Stopped"];
		[mainController addMessage:@"Periodic timecode emission has been stopped."];
	}
}

- (IBAction)emitTimecodeContinuouslyButtonClicked:(id)sender {
	if(emittingTimecode==false){
		[self startPeriodicTimecodeEmission];
	}else{
		[self stopPeriodicTimecodeEmission];
	}
}

- (IBAction)emitTimecodeOneshotButtonClicked:(id)sender {
	if(emittingTimecode==false){
		if(![self spaceWireIFAvailable]){
			return;
		}
		uint8_t timecode=[timecodeValueCell intValue];
		if(timecode>63){
			[Utility showDialogBox:@"Initial timecode value is invalid." :@"Timecode value shall be 0-63."];
			return;
		}
		SpaceWireIF* spwif=[mainController getSpaceWireIFInstance];
		try{
			spwif->emitTimecode(timecode);
		}catch(SpaceWireIFException e){
			[self handleSpaceWireIFException:e];
			return;
		}
		return;
	}else{
		[Utility showDialogBox:@"Timecode emission failed." :@"Stop periodic timeout emission first."];
		return;
	}
}

- (bool)isEmittingTimecode{
	return emittingTimecode;
}

- (void)updateReceivedPacket{
	if(isContinuouslyReceiving){
		if(receiveThread->hasNewPacketArrived()){
			[receivePacketCell selectAll:nil];
			[receivePacketCell deleteBackward:nil];
			[Utility setVectorUint8Pointer:receiveThread->getLatestPacket() terminatedWith:@"" toNSTextView:receivePacketCell];
			receiveThread->resetNewPacketArrived();
		}
	}
}

- (void)handleSpaceWireIFException:(SpaceWireIFException&)e{
	if(e.getStatus()==SpaceWireIFException::Disconnected){
		[self stopContinuousPacketReceive];
		[self stopPeriodicTimecodeEmission];
		[Utility showDialogBox:@"SpaceWire I/F was disconnected." :@"Reconnect before emitting timecode."];
		std::stringstream ss;
		ss << "SpaceWire I/F was disconnected.";
		[mainController addMessageString:ss.str()];
		[mainController spaceWireIFDisconnected];
		return;
	}else if(e.getStatus()==SpaceWireIFException::Timeout){
		std::stringstream ss;
		ss << "Timed out.";
		[mainController addRedMessageString:ss.str()];
		return;
	}else{
		std::stringstream ss;
		ss << "Timecode emission failed.";
		[mainController addMessageString:ss.str()];
		[Utility showDialogBox:@"Timecode emission failed." :@"Stop periodic timeout emission first."];
		return;
	}	
}

- (void)rmapEngineWasStarted{
	[receiveOnePacketButton setEnabled:NO];
	[receiveContinuousButton setEnabled:NO];
	[stopRMAPEngineButton setEnabled:YES];
	[rmapEngineStatusLabel setStringValue:@"Started"];
}

- (void)rmapEngineWasStopped{
	[stopRMAPEngineButton setEnabled:NO];
	[receiveContinuousButton setEnabled:YES];
	[receiveOnePacketButton setEnabled:YES];
	[rmapEngineStatusLabel setStringValue:@"Stopped"];
}
	   
- (IBAction)stopRMAPEngineButtonClicked:(id)sender {	
	[rmapViewController callSpaceWireViewControllerRMAPEngineStoppedWhenStopping:false];
	[rmapViewController stopRMAPEngine];
	[stopRMAPEngineButton setEnabled:NO];
	[receiveContinuousButton setEnabled:YES];
	[receiveOnePacketButton setEnabled:YES];
	[rmapEngineStatusLabel setStringValue:@"Stopped"];
}

- (SpaceWireViewContollerCloseActionStopContinuousReceive*)getSpaceWireViewContollerCloseActionStopContinuousReceiveInstance{
	return spacewireViewContollerCloseActionStopContinuousReceiveInstance;
}
@end
