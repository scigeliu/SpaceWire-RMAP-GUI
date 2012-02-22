//
//  GSRMainController.h
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/26.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#undef NO_XMLLODER
#include "SpaceWire.hh"
#include "RMAP.hh"

@class SpaceWireIFViewController;
@class SpaceWireViewController;
@class RMAPViewController;
@class RMAPPacketUtilityViewController;
@class RMAPTargetNodeController;
@class RMAPCRCViewController;

class SpaceWireRMAPGUIVersion {
public:
	const static uint32_t Version=20120210;
};

class CheckUpdateThread;

@interface GSRMainController : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet SpaceWireIFViewController *spaceWireIFViewController;
	IBOutlet SpaceWireViewController *spaceWireViewController;
	IBOutlet RMAPViewController *rmapViewController;
	IBOutlet RMAPPacketUtilityViewController *rmapPacketUtilityViewController;
	IBOutlet RMAPTargetNodeController *rmapTargetNodeController;
	IBOutlet RMAPCRCViewController *rmapCRCViewController;
	
	IBOutlet NSTextView *messageCell;
	SpaceWireIF* spwif;
	bool isSpaceWireIFSet_;
	NSString* previousTime;
	//GUI objects
	IBOutlet NSFormCell *ipAddressCell;
	IBOutlet NSFormCell *portCell;
	IBOutlet NSFormCell *timecodeFrequencyCell;
	IBOutlet NSFormCell *timecodeValueCell;
	
	IBOutlet NSWindow *splashWindow;
	
	//update window
	
	IBOutlet NSPanel *updateNotificationWindow;
	IBOutlet NSTextField *currentVersionField;
	IBOutlet NSTextField *latestVersionField;

	//
	bool logWindowIsDisplayed;
	IBOutlet NSButton *showLogWindowButton;
	IBOutlet NSPanel *logWindow;
	IBOutlet NSPanel *ackWindow;
	IBOutlet NSTextField *ackWindowVersionCell;
	IBOutlet NSTabView *mainTab;
	NSUserDefaults* ud;
	CheckUpdateThread* checkUpdateThread;
}

- (NSUserDefaults*)getNSUserDefaults;
- (void)saveDefaults;
- (void)restoreDefaults;

- (IBAction)clearLogButton:(id)sender;
- (IBAction)saveLogButton:(id)sender;

- (NSString*)getDateTimeString;
- (void)addMessage:(NSString*)text;
- (void)addMessageString:(std::string)text;
- (void)addRedMessage:(NSString*)text;
- (void)addRedMessageString:(std::string)text;
- (void)setSpaceWireIFInstance:(SpaceWireIF*)spwif_;
- (void)removeSpaceWireIFInstance;
- (SpaceWireIF*)getSpaceWireIFInstance;
- (bool)isSpaceWireIFSet;
- (void)tryingToDisconnectSpaceWireIF;

- (void)saveConfiguration;
- (double)getDefaultThreadWaitDuraion;

- (void)spaceWireIFDisconnected;

- (std::map<std::string,RMAPTargetNode*>*)getRMAPTargetNodes;
- (NSWindow*)getMainWindow;
- (IBAction)aboutMenuSelected:(id)sender;
- (IBAction)splashWindowClicked:(id)sender;
- (IBAction)ackWindowCloseButtonClicked:(id)sender;
- (IBAction)ackButtonClicked:(id)sender;
- (IBAction)showLogButtonClicked:(id)sender;
- (IBAction)logWindowTransparencyChanged:(id)sender;

- (void)showUpdateNotificationWindow;
- (IBAction)updateWindowOKButtonClicked:(id)sender;
- (IBAction)openTheDownloadPageButtonClicked:(id)sender;



@end
