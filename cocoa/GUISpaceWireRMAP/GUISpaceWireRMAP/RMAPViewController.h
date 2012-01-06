//
//  RMAPViewController.h
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/26.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHeader.h"
#import "GSRMainController.h"
#import "SpaceWireViewController.h"

#include "CxxUtilities/CxxUtilities.hh"
#undef NO_XMLLODER
#include "RMAP.hh"

class RMAPViewControllerCloseActionStopRMAPEngine : public SpaceWireIFActionCloseAction {
private:
	id rmapViewController;
public:
	RMAPViewControllerCloseActionStopRMAPEngine(id rmapViewController){
		this->rmapViewController=rmapViewController;
	}
	
public:
	void doAction(SpaceWireIF* spacewireIF){
		[rmapViewController stopRMAPEngine];
	}
};

class RMAPEngineStoppedActionByRMAPViewController : public RMAPEngineStoppedAction{
private:
	id rmapViewController;
public:
	RMAPEngineStoppedActionByRMAPViewController(id rmapViewController){
		this->rmapViewController=rmapViewController;
	}
	virtual void doAction(void* rmapEngine){
		[rmapViewController rmapEngineWasStopped];
	}
};

class RMAPViewControllerConstants {
public:
	static const double WaitDurationForStoppingRMAPEngine=300;//ms
	static const double WaitDurationForStoppingRMAPInitiator=300;//ms
	static const size_t MaximumReadLength=10*1024*1024;//bytes
};

@interface RMAPViewController : NSObject {
	
	//initiator/target information
	IBOutlet NSFormCell *initiatorLogicalAddressCell;
	IBOutlet NSFormCell *targetLogicalAddressCell;
	IBOutlet NSFormCell *keyCell;
	IBOutlet NSFormCell *targetSpaceWireAddressCell;
	IBOutlet NSFormCell *replyAddressCell;
	IBOutlet NSPopUpButtonCell *registeredTargetNodeSelector;
	
	//memory information
	IBOutlet NSForm *extendedAddressCell;
	IBOutlet NSPopUpButton *incrementSelector;
	IBOutlet NSFormCell *memoryAddressCell;
	IBOutlet NSFormCell *lengthCell;
	IBOutlet NSPopUpButton *registeredMemoryObjectSelector;
	
	//transaction information
	IBOutlet NSMatrix *tidModeSelector;
	
	//write data
	IBOutlet NSTextView *writeDataCell;
	IBOutlet NSPopUpButton *verifySelector;
	IBOutlet NSPopUpButton *ackSelector;
	
	//read data
	IBOutlet NSTextView *readDataCell;
	
	//timeout
	IBOutlet NSFormCell *timeoutDurationCell;
	
	//tid
	IBOutlet NSTextField *manualTIDCell;
	
	//debug mode
	IBOutlet NSButton *logPacketDumpCheckButton;

	//main controller
	IBOutlet GSRMainController *mainController;	
	IBOutlet SpaceWireViewController *spacewireViewController;
	//main window
	IBOutlet NSWindow *mainWindow;
	
	RMAPEngine* rmapEngine;
	RMAPInitiator* rmapInitiator;
	RMAPTargetNode* rmapTargetNode;
	RMAPViewControllerCloseActionStopRMAPEngine* rmapViewControllerCloseActionStopRMAPEngine;
	RMAPEngineStoppedActionByRMAPViewController* rmapEngineStoppedActionByRMAPViewController;
	bool callSpaceWireViewControllerRMAPEngineStoppedWhenStopping_;

}

- (void)saveDefaults;
- (void)restoreDefaults;

- (IBAction)rmapWriteButtonClicked:(id)sender;
- (IBAction)rmapReadButtonClicked:(id)sender;
- (void)tryToStartRMAPEngine;
- (void)stopRMAPEngine;
- (void)constructRMAPInitiator;
- (void)destructRMAPInitiator;

- (void)rmapTargetNodesUpdated:(std::map<std::string,RMAPTargetNode*>*)rmapTargetNodes;
- (void)rmapTargetNodesCleared;

- (void)setMemoryObjectSelector:(RMAPTargetNode*)rmapTargetNode_;
- (IBAction)rmapTargetNodeSelectorAction:(id)sender;
- (IBAction)memoryObjectSelectorAction:(id)sender;

- (void)logCommandPacketDump;
- (void)logReplyPacketDump;
- (void)rmapEngineWasStopped;



- (void)callSpaceWireViewControllerRMAPEngineStoppedWhenStopping:(bool)flag;
- (RMAPViewControllerCloseActionStopRMAPEngine*)getRMAPViewControllerCloseActionStopRMAPEngine;
@end
