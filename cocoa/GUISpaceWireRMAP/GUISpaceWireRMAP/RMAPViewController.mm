//
//  RMAPViewController.m
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/26.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "RMAPViewController.h"
#include "SpaceWireUtilities.hh"

@implementation RMAPViewController

- (id)init
{
    self = [super init];
    if (self) {
		rmapEngine=NULL;
		rmapInitiator=NULL;
		rmapTargetNode=new RMAPTargetNode();
		rmapViewControllerCloseActionStopRMAPEngine=new RMAPViewControllerCloseActionStopRMAPEngine(self);
    }
    
    return self;
}

- (void)dealloc{
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
	[ud setObject:[initiatorLogicalAddressCell stringValue] forKey:@"RMAP.InitiatorLogicalAddressCell"];
	[ud setObject:[targetLogicalAddressCell stringValue] forKey:@"RMAP.targetLogicalAddressCell"];
	[ud setObject:[keyCell stringValue] forKey:@"RMAP.Key"];
	[ud setObject:[targetSpaceWireAddressCell stringValue] forKey:@"RMAP.TargetSpaceWireAddressCell"];
	[ud setObject:[replyAddressCell stringValue] forKey:@"RMAP.ReplyAddressCell"];
	[ud setObject:[initiatorLogicalAddressCell stringValue] forKey:@"RMAP.InitiatorLogicalAddressCell"];
	
	//memory information
	[ud setObject:[memoryAddressCell stringValue] forKey:@"RMAP.MemoryAddressCell"];
	[ud setObject:[lengthCell stringValue] forKey:@"RMAP.LengthCell"];
	[ud setObject:[incrementSelector titleOfSelectedItem] forKey:@"RMAP.IncrementSelector"];
	
	//timeout
	[ud setObject:[timeoutDurationCell stringValue] forKey:@"RMAP.TimeoutDurationCell"];
	
	//log button
	[ud setInteger:[logPacketDumpCheckButton state] forKey:@"RMAP.LogPacketDumpCheckButton"];
}

- (void)restoreDefaults{
	using namespace std;
	//cout << "#RMAPViewController is restoring default parameters." << endl;
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	//sample
	//[ud stringForKey:@"KEY_S"];

	//initiator/target information
	[initiatorLogicalAddressCell setStringValue:[ud stringForKey:@"RMAP.InitiatorLogicalAddressCell"]];
	[targetLogicalAddressCell setStringValue:[ud stringForKey:@"RMAP.targetLogicalAddressCell"]];
	[keyCell setStringValue:[ud stringForKey:@"RMAP.Key"]];
	[targetSpaceWireAddressCell setStringValue:[ud stringForKey:@"RMAP.TargetSpaceWireAddressCell"]];
	[replyAddressCell setStringValue:[ud stringForKey:@"RMAP.ReplyAddressCell"]];
	[initiatorLogicalAddressCell setStringValue:[ud stringForKey:@"RMAP.InitiatorLogicalAddressCell"]];
	
	//memory information
	[memoryAddressCell setStringValue:[ud stringForKey:@"RMAP.MemoryAddressCell"]];
	[lengthCell setStringValue:[ud stringForKey:@"RMAP.LengthCell"]];
	[incrementSelector selectItemWithTitle:[ud stringForKey:@"RMAP.IncrementSelector"]];
	
	//timeout
	[timeoutDurationCell setStringValue:[ud stringForKey:@"RMAP.TimeoutDurationCell"]];
	
	//log button
	[logPacketDumpCheckButton setState:[ud integerForKey:@"RMAP.LogPacketDumpCheckButton"]];
	
	[self rmapTargetNodesCleared];
	
}

- (bool)spaceWireIFAvailable{
	if([mainController isSpaceWireIFSet]==false){
		[Utility showDialogBox:@"SpaceWire I/F is not connected." :@"Connect first."];
		return false;
	}else{//spwif is available
		return [mainController isSpaceWireIFSet];
	}
}

- (bool)isRMAPEngineStarted{
	if(rmapEngine==NULL){
		[self tryToStartRMAPEngine];
		if(rmapEngine==NULL){
			return false;
		}else{
			return true;
		}
	}else{
		return true;
	}
}

- (void)tryToStartRMAPEngine{
	using namespace std;
	if(rmapEngine!=NULL){
		//rmapEngine is already started and available
		return;
	}
	if(![self spaceWireIFAvailable]){//if spw if is not available
		//rmapengine cannot be started
		return;
	}
	if([spacewireViewController isContinuouslyReceivingPackets]){
		[Utility showDialogBox:@"RMAPEngine cannot be started." :@"Stop 'Continuous Packet Receive' in the SpaceWire tab to perform RMAP transactions using RMAPEngine."];
		return;
	}
	rmapEngine=new RMAPEngine([mainController getSpaceWireIFInstance]);
	rmapEngineStoppedActionByRMAPViewController=new RMAPEngineStoppedActionByRMAPViewController(self);
	rmapEngine->addRMAPEngineStoppedAction(rmapEngineStoppedActionByRMAPViewController);
	[spacewireViewController rmapEngineWasStarted];//tell SpaceWireViewController the start of RMAPEngine
	rmapEngine->start();
	if(rmapInitiator!=NULL){
		delete rmapInitiator;
	}
	rmapInitiator=new RMAPInitiator(rmapEngine);
}

- (void)stopRMAPEngine{
	if(rmapEngine!=NULL){
		rmapEngine->stop();
		delete rmapEngine;
		rmapEngine=NULL;
		[spacewireViewController rmapEngineWasStopped];
	}
}

- (void)callSpaceWireViewControllerRMAPEngineStoppedWhenStopping:(bool)flag{
	callSpaceWireViewControllerRMAPEngineStoppedWhenStopping_ = flag;
}

- (void)rmapEngineWasStopped{
	if(callSpaceWireViewControllerRMAPEngineStoppedWhenStopping_){
		[spacewireViewController rmapEngineWasStopped];
	}
}

- (void)constructTargetNode{
	rmapTargetNode->setInitiatorLogicalAddress([Utility toInt:initiatorLogicalAddressCell]);
	rmapTargetNode->setTargetLogicalAddress([Utility toInt:targetLogicalAddressCell]);
	std::vector<uint8_t> targetSpaceWireAddress=[Utility toUInt8Array:targetSpaceWireAddressCell];
	rmapTargetNode->setTargetSpaceWireAddress(targetSpaceWireAddress);
	std::vector<uint8_t> replyAddress=[Utility toUInt8Array:replyAddressCell];
	rmapTargetNode->setReplyAddress(replyAddress);
	rmapTargetNode->setDefaultKey([Utility toInt:keyCell]);
}

- (void)constructRMAPInitiator{
	rmapInitiator=new RMAPInitiator(rmapEngine);	
}

- (void)destructRMAPInitiator{
	CxxUtilities::Condition c;
	c.wait(RMAPViewControllerConstants::WaitDurationForStoppingRMAPInitiator);
	delete rmapInitiator;
	rmapInitiator=NULL;
}

- (bool)timeoutDurationIsValid:(double)timeoutduration{
	double timeoutdurationInSec=timeoutduration/1000;
	if(timeoutdurationInSec<0.001){
		[Utility showDialogBox:@"Too short timeout duration." :@"Timeout duration must be longer than 1ms."];
		return false;
	}
	if(10<timeoutdurationInSec){
		[Utility showDialogBox:@"Too long timeout duration." :@"Timeout duration must be shorter than 10s."];
		return false;
	}
	return true;
}

- (bool)specifiedTransactionIDAvailable:(uint16_t)tid{
	if(![self isRMAPEngineStarted]){//if rmapEngine is not available
		return false;
	}
	if(rmapEngine->isTransactionIDAvailable(tid)){
		return true;
	}else{
		[mainController addRedMessage:@"Specified transaction ID is already used."];
		return false;
	}
}

- (bool)setRMAPInitiatorOptions{
	using namespace std;
	//tid
	if([[tidModeSelector selectedCell] tag]==1){//manualTID
		uint16_t tid=[Utility toUInt16:manualTIDCell];
		//cout << "#tid " << [Utility toUInt16:manualTIDCell] << endl;
		if([self specifiedTransactionIDAvailable:tid]){
			rmapInitiator->setTransactionID(tid);
		}else{
			[mainController addRedMessage:@"RMAP transaction was not initiated since specified transaction ID is already in use."];
			return false;
		}
	}else{
		rmapInitiator->unsetTransactionID();
	}
	//increment mode
	if([[incrementSelector titleOfSelectedItem] isEqualToString:@"Increment"]){
		rmapInitiator->setIncrementMode(true);
	}else{
		rmapInitiator->setIncrementMode(false);
	}
	//verify mode
	if([[verifySelector titleOfSelectedItem] isEqualToString:@"Verify"]){
		rmapInitiator->setVerifyMode(true);
	}else{
		rmapInitiator->setVerifyMode(false);
	}
	//reply mode
	if([[ackSelector titleOfSelectedItem] isEqualToString:@"Reply"]){
		rmapInitiator->setReplyMode(true);
	}else{
		rmapInitiator->setReplyMode(false);
	}
	return true;
}

- (IBAction)rmapWriteButtonClicked:(id)sender {
	if(![self isRMAPEngineStarted]){//if rmapEngine is not available
		return;
	}
	[self constructTargetNode];
	uint32_t address=[Utility toUInt32:memoryAddressCell];
	std::vector<uint8_t> writedata=[Utility toUInt8ArrayFromTextView:writeDataCell];
	
	uint32_t length=(uint32_t)writedata.size();
	if(length==0){
		[mainController addRedMessage:@"Write data is empty."];
		return;
	}
	double timeoutDuration=[timeoutDurationCell doubleValue];
	if(![self timeoutDurationIsValid:timeoutDuration]){
		return;
	}
	
	if(![self setRMAPInitiatorOptions]){
		return;
	}
	
	std::stringstream ss;
	using namespace std;
	ss << "RMAP Write to target logical address 0x" << hex << setw(2) << setfill('0') << [targetLogicalAddressCell intValue]
	<< " address=" << hex << setw(2) << setfill('0') << address << " length=" << dec << length;
	[mainController addMessage:[Utility toNSString:ss.str()]];
	try{
		rmapInitiator->write(rmapTargetNode, address, &(writedata.at(0)), length, timeoutDuration);
		[self logCommandPacketDump];
		if(rmapInitiator->isReplyModeSet()){
			[mainController addMessage:@"RMAP Write Reply has been reiceived."];
			[self logReplyPacketDump];
		}else{
			[mainController addMessage:@"RMAP Write Command was sent."];
		}
	}catch(RMAPInitiatorException e){
		[self logCommandPacketDump];
		if(rmapInitiator->isReplyModeSet()){
			[self logReplyPacketDump];
		}
		if(e.getStatus()==RMAPInitiatorException::Timeout){
			[mainController addRedMessage:@"RMAP Write Timeout."];
		}else{
			[mainController addRedMessageString:e.toString()];
			[mainController addRedMessage:@"It seems that RMAP Write command was not sent properly."];
		}
	}catch(RMAPReplyException e){
		[mainController addRedMessage:@"RMAP Write was not successful due to error in RMAP Engine."];
		[mainController addRedMessageString:e.toString()];
		return;
	}catch(...){
		[mainController addRedMessage:@"Unknown error in RMAP Write."];
		return;
	}
}

- (void)clearReadDataCell{
	[Utility setTextToNSTextView:@"" to:readDataCell];
}

- (IBAction)rmapReadButtonClicked:(id)sender {
	using namespace std;
	if(![self isRMAPEngineStarted]){//if rmapEngine is not available
		return;
	}
	[self constructTargetNode];
	uint32_t address=[Utility toUInt32:memoryAddressCell];
	if([lengthCell intValue]<0){
		[Utility showDialogBox:@"Read length is invalid." :@""];
	}
	uint32_t length=[Utility toUInt32:lengthCell];
	double timeoutDuration=[timeoutDurationCell doubleValue];
	if(![self timeoutDurationIsValid:timeoutDuration]){
		return;
	}
	if(RMAPViewControllerConstants::MaximumReadLength<length){
		[Utility showDialogBox:@"Read length is too long." :@"Must be less than 10MB."];
	}

	uint8_t *buffer;
	if(length==0){
		buffer=new uint8_t[1];
	}else{
		buffer=new uint8_t[length];
	}

	if(![self setRMAPInitiatorOptions]){
		return;
	}
	
	stringstream ss;
	ss << "RMAP Read to target logical address 0x" << hex << setw(2) << setfill('0') << (uint32_t)rmapTargetNode->getTargetLogicalAddress()
	<< " address=0x" << hex << setw(8) << setfill('0') << address << " length(dec)=" << dec << length;
	[mainController addMessageString:ss.str()];
	
	try{
		rmapInitiator->read(rmapTargetNode, address, length, buffer, timeoutDuration);
		[self logCommandPacketDump];
		[self logReplyPacketDump];
	}catch(RMAPInitiatorException e){
		[self logCommandPacketDump];
		[self logReplyPacketDump];
		if(e.getStatus()==RMAPInitiatorException::Timeout){
			[mainController addRedMessage:@"RMAP Read Timeout."];
		}else{
			[mainController addRedMessage:@"It seems that RMAP Read command was not sent properly."];
			[mainController addRedMessageString:e.toString()];
		}
		[self clearReadDataCell];
		return;
	}catch(RMAPReplyException e){
		[self logCommandPacketDump];
		[self logReplyPacketDump];
		[mainController addRedMessage:@"RMAP Read was not successful."];
		[mainController addRedMessage:[Utility toNSString:e.toString()]];
		[self clearReadDataCell];
		return;
	}catch(RMAPReplyException e){
		[mainController addRedMessage:@"RMAP Write was not successful due to error in RMAP Engine."];
		[mainController addRedMessageString:e.toString()];
		return;
	}catch(...){
		[self logCommandPacketDump];
		[self logReplyPacketDump];
		[mainController addRedMessage:@"RMAP Read was not successful with unknown error."];
		[Utility showDialogBox:@"Unknown error" :@""];
		[self clearReadDataCell];
		return;
	}
	std::vector<uint8_t> readdata;
	for(size_t i=0;i<length;i++){
		readdata.push_back(buffer[i]);
	}
	
	[Utility setTextToNSTextView:[Utility vectorUint8ToNSString:readdata] to:readDataCell];
	delete buffer;
}

- (void)rmapTargetNodesUpdated:(std::map<std::string,RMAPTargetNode*>*)rmapTargetNodes{
	using namespace std;
	if(rmapTargetNodes->size()==0){
		return;
	}
	[registeredTargetNodeSelector removeAllItems];
	[registeredTargetNodeSelector addItemWithTitle:@"Manual"];
	std::map<std::string,RMAPTargetNode*>::iterator it=rmapTargetNodes->begin();
	[self setMemoryObjectSelector:it->second];
	while(it!=rmapTargetNodes->end()){
		[registeredTargetNodeSelector addItemWithTitle:[Utility toNSString:it->second->getID()]];
		it++;
	}
}

- (void)rmapTargetNodesCleared{
	[registeredTargetNodeSelector removeAllItems];
	[registeredTargetNodeSelector addItemWithTitle:@"Manual"];
	[registeredMemoryObjectSelector removeAllItems];
	[registeredMemoryObjectSelector addItemWithTitle:@"Manual"];
}

- (void)setMemoryObjectSelector:(RMAPTargetNode*)rmapTargetNode_{
	[registeredMemoryObjectSelector removeAllItems];
	[registeredMemoryObjectSelector addItemWithTitle:@"Manual"];
	std::map<std::string,RMAPMemoryObject*>* memoryObjects=rmapTargetNode_->getMemoryObjects();
	std::map<std::string,RMAPMemoryObject*>::iterator it=memoryObjects->begin();
	while(it!=memoryObjects->end()){
		[registeredMemoryObjectSelector addItemWithTitle:[Utility toNSString:it->second->getID()]];
		it++;
	}
}

- (IBAction)rmapTargetNodeSelectorAction:(id)sender {
	std::string title=[Utility toString:[registeredTargetNodeSelector titleOfSelectedItem]];
	if(title=="Manual"){
		return;
	}
	std::map<std::string,RMAPTargetNode*>* rmapTargetNodes=[mainController getRMAPTargetNodes];
	std::map<std::string,RMAPTargetNode*>::iterator it=rmapTargetNodes->find(title);
	if(it!=rmapTargetNodes->end()){
		RMAPTargetNode* targetNode_=it->second;
		[self setMemoryObjectSelector:targetNode_];
		if(targetNode_->isInitiatorLogicalAddressSet()){
			[Utility setUInt8:targetNode_->getInitiatorLogicalAddress() to:initiatorLogicalAddressCell];
		}
		[Utility setUInt8:targetNode_->getTargetLogicalAddress() to:targetLogicalAddressCell];
		[Utility setUInt8Array:targetNode_->getTargetSpaceWireAddress() to:targetSpaceWireAddressCell];
		[Utility setUInt8Array:targetNode_->getReplyAddress() to:replyAddressCell];
		[Utility setUInt8:targetNode_->getDefaultKey() to:keyCell];
	}
}

- (IBAction)memoryObjectSelectorAction:(id)sender {
	std::string titleOfSelectedTargetNode=[Utility toString:[registeredTargetNodeSelector titleOfSelectedItem]];
	std::string titleOfSelectedMemoryObject=[Utility toString:[sender titleOfSelectedItem]];
	if(titleOfSelectedMemoryObject=="Manual"){
		return;
	}
	
	std::map<std::string,RMAPTargetNode*>* rmapTargetNodes=[mainController getRMAPTargetNodes];
	std::map<std::string,RMAPTargetNode*>::iterator it_RMAPTargetNode=rmapTargetNodes->find(titleOfSelectedTargetNode);
	if(it_RMAPTargetNode==rmapTargetNodes->end()){
		return;
	}
	RMAPTargetNode* rmapTargetNode_=it_RMAPTargetNode->second;
	std::map<std::string,RMAPMemoryObject*>* memoryObjects=rmapTargetNode_->getMemoryObjects();
	std::map<std::string,RMAPMemoryObject*>::iterator it_RMAPMemoryObject=memoryObjects->find(titleOfSelectedMemoryObject);
	if(it_RMAPMemoryObject!=memoryObjects->end()){
		RMAPMemoryObject* memoryObject=it_RMAPMemoryObject->second;
		[Utility setInteger:memoryObject->getAddress() to:memoryAddressCell];
		[Utility setUInt8:memoryObject->getExtendedAddress() to:extendedAddressCell];
		[Utility setInteger:memoryObject->getLength() to:lengthCell];
		if(memoryObject->isIncrementModeSet()){
			if(memoryObject->isIncrementMode()){
				[incrementSelector selectItemWithTitle:@"Increment"];
			}else{
				[incrementSelector selectItemWithTitle:@"No increment"];
			}
		}
		if(memoryObject->isKeySet()){
			[Utility setUInt8:memoryObject->getKey() to:keyCell];
		}
		//check for access mode
		//todo
	}
}

- (void)logCommandPacketDump{
	using namespace std;
	if([logPacketDumpCheckButton state] != NSOnState){
		return;
	}
	RMAPPacket* packet=rmapInitiator->getCommandPacketPointer();
	if(packet==NULL){
		return;
	}
	stringstream ss;
	ss << "RMAP Command Packet Dump" << endl;
	SpaceWireUtilities::dumpPacket(&ss,packet->getPacketBufferPointer(),1,16);
	[mainController addMessageString:ss.str()];
}

- (void)logReplyPacketDump{
	using namespace std;
	if([logPacketDumpCheckButton state] != NSOnState){
		return;
	}
	RMAPPacket* packet=rmapInitiator->getReplyPacketPointer();
	if(packet==NULL){
		return;
	}
	stringstream ss;
	ss << "RMAP Reply Packet Dump" << endl;
	SpaceWireUtilities::dumpPacket(&ss,packet->getPacketBufferPointer(),1,16);
	[mainController addMessageString:ss.str()];
}

- (RMAPViewControllerCloseActionStopRMAPEngine*)getRMAPViewControllerCloseActionStopRMAPEngine{
	return rmapViewControllerCloseActionStopRMAPEngine;
}
@end
