//
//  GUISpaceWireRMAPAppDelegate.h
//  GUISpaceWireRMAP
//
//  Created by Takayuki Yuasa on 11/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSRMainController.h"
#include "CxxUtilities/CxxUtilities.hh"

@interface GUISpaceWireRMAPAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSWindow *window;
	IBOutlet NSScrollView *logCell;
	IBOutlet GSRMainController *mainController;
	IBOutlet NSPanel *splashWindow;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)clearLogButtonClicked:(id)sender;
- (IBAction)saveLogButtonClicked:(id)sender;
- (NSWindow*)getMainWindow;

@end
