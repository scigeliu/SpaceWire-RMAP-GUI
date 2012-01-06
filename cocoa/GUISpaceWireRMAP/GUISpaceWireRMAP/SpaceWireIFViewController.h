//
//  SpaceWireIFViewController.h
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/25.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "GSRMainController.h"
#import "SpaceWireViewController.h"
#undef NO_XMLLODER
#include "SpaceWire.hh"

@class GSRMainController;

@interface SpaceWireIFViewController : NSObject {
@private
	SpaceWireIFOverTCP* spwif;
	bool connected;
	IBOutlet NSFormCell *ipAddressCell;
	IBOutlet NSFormCell *portCell;
	IBOutlet NSButton *connectButton;
	Utility* utility;
	
	IBOutlet NSForm *ipAddressForm;
	//controllers
	IBOutlet SpaceWireViewController *spacewireViewController;
	IBOutlet RMAPViewController *rmapViewController;
	IBOutlet GSRMainController *mainController;
}

- (void)saveDefaults;
- (void)restoreDefaults;

- (IBAction)connectButtonClicked:(id)sender;
- (void)connect;
- (void)disconnect;
- (void)spaceWireIFDisconnected;

@end
