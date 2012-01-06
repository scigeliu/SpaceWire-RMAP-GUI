//
//  SpaceWireViewController.h
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/24.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonHeader.h"
#import "RMAPViewController.h"

class TimecodeThread;
class ReceiveThread;
class UpdateThread;

class SpaceWireViewContollerCloseActionStopContinuousReceive : public SpaceWireIFActionCloseAction {
private:
	id spacewireViewController;
public:
	SpaceWireViewContollerCloseActionStopContinuousReceive(id spacewireViewController){
		this->spacewireViewController=spacewireViewController;
	}
	
public:
	void doAction(SpaceWireIF* spacewireIF){
		[spacewireViewController stopContinuousPacketReceive];
		[spacewireViewController stopPeriodicTimecodeEmission];
	}
};

		 
@interface SpaceWireViewController : NSObject {
	//send
	IBOutlet NSTextView *sendPacketCell;
	IBOutlet NSButton *allHexButton;

	//receive
	IBOutlet NSTextView *receivePacketCell;
	IBOutlet NSFormCell *receiveTimeoutCell;
	IBOutlet NSButton *stopRMAPEngineButton;
	IBOutlet NSTextField *rmapEngineStatusLabel;
	IBOutlet NSButton *receiveOnePacketButton;
	IBOutlet NSButton *receiveContinuousButton;
	
	//timecode
	IBOutlet NSTextField *timecodeStatusCell;
	IBOutlet NSTextField *currentTimecodeValueCell;
	IBOutlet NSFormCell *timecodeFrequencyCell;
	IBOutlet NSFormCell *timecodeValueCell;
	IBOutlet NSButton *emitContinuouslyButton;
	IBOutlet NSButton *emitOneShotButton;
	
	IBOutlet NSScrollView *messageCell;
	
	//main controller
	IBOutlet GSRMainController *mainController;
	
	IBOutlet RMAPViewController *rmapViewController;
	//
	bool emittingTimecode;
	bool isContinuouslyReceiving;
	TimecodeThread* timecodeThread;
	ReceiveThread* receiveThread;
	UpdateThread* updateThread;
	SpaceWireViewContollerCloseActionStopContinuousReceive* spacewireViewContollerCloseActionStopContinuousReceiveInstance;
	//
}

- (void)saveDefaults;
- (void)restoreDefaults;

- (IBAction)sendWithEOPButtonClicked:(id)sender;
- (IBAction)sendWithEEPButtonClicked:(id)sender;
- (IBAction)receiveOnePacketButtonClicked:(id)sender;
- (bool)isContinuouslyReceivingPackets;
- (void)stopContinuousPacketReceive;
- (IBAction)receiveContinuouslyButtonClicked:(id)sender;
- (IBAction)saveReceivedPacketButtonClicked:(id)sender;
- (void)stopPeriodicTimecodeEmission;
- (IBAction)emitTimecodeContinuouslyButtonClicked:(id)sender;
- (IBAction)emitTimecodeOneshotButtonClicked:(id)sender;
- (bool)isEmittingTimecode;
- (void)updateReceivedPacket;
- (void)handleSpaceWireIFException:(SpaceWireIFException&)e;

- (void)rmapEngineWasStarted;
- (void)rmapEngineWasStopped;
- (IBAction)stopRMAPEngineButtonClicked:(id)sender;

- (SpaceWireViewContollerCloseActionStopContinuousReceive*)getSpaceWireViewContollerCloseActionStopContinuousReceiveInstance;


@end
