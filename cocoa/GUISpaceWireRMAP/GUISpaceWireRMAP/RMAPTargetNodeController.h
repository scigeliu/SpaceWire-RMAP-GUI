//
//  RMAPTargetNodeController.h
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/12/05.
//  Copyright 2011年 ISAS. All rights reserved.
//

#undef NO_XMLLODER
#import <Foundation/Foundation.h>
#include "RMAPTargetNode.hh"
#import "RMAPViewController.h"
#import "GSRMainController.h"

@interface RMAPTargetNodeController : NSObject{
	//rmap view controller
	IBOutlet RMAPViewController *rmapViewController;

	//main window
	IBOutlet NSWindow *mainWindow;
	
	//sub window
	IBOutlet NSPanel *registeredRMAPTargetNodesWindow;
	IBOutlet NSTextView *registeredRMAPTargetNodesTextView;
	IBOutlet NSButton *showRegisteredRMAPTargetNodesButton;
	bool isRegisteredRMAPTargetNodesWindowDisplayed;
	//main controller
	IBOutlet GSRMainController *mainController;
	
	
	std::map<std::string,RMAPTargetNode*> rmapTargetNodes;
}

- (IBAction)loadConfigurationButtonClicked:(id)sender;
- (IBAction)clearNodesButtonClicked:(id)sender;

- (void)addRMAPTargetNode:(RMAPTargetNode*)node;
- (void)addRMAPTargetNodes:(std::vector<RMAPTargetNode*>)nodes;
- (std::map<std::string,RMAPTargetNode*>*)getRMAPTargetNodes;
- (IBAction)showInfoButtonClicked:(id)sender;
- (IBAction)transparencySliderAction:(id)sender;

@end

