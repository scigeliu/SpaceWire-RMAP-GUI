//
//  RMAPCRCViewController.h
//  RMAP CRC Calculator
//
//  Created by 湯浅 孝行 on 11/11/29.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "GSRMainController.h"
#import "Utility.h"

#include "RMAPUtilities.hh"
#include "CxxUtilities/String.hh"

@interface RMAPCRCViewController : NSObject {
	IBOutlet NSTextView *dataCell;
	IBOutlet NSTextField *totalBytesCell;
	IBOutlet NSTextField *crcCell;
	IBOutlet NSButton *allHexCheckBox;
	
	IBOutlet GSRMainController *mainController;
}

- (id)init;
- (void)dealloc;

- (void)applicationFinishedLaunching;

- (void)saveDefaults;
- (void)restoreDefaults;

- (IBAction)calculateButton:(id)sender;

@end
