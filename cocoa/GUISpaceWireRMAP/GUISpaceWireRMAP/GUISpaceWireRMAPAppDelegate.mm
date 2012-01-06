//
//  GUISpaceWireRMAPAppDelegate.m
//  GUISpaceWireRMAP
//
//  Created by Takayuki Yuasa on 11/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GUISpaceWireRMAPAppDelegate.h"

@implementation GUISpaceWireRMAPAppDelegate

@synthesize window;

using namespace CxxUtilities;
class SplashWindowClass : public CxxUtilities::Thread {
private:
	NSWindow *mainWindow;
	NSPanel* splashWindow;
public:
	SplashWindowClass(NSWindow *mainWindow, NSPanel* splashWindow){
		this->mainWindow=mainWindow;
		this->splashWindow=splashWindow;
	}
	
	void run(){
		using namespace std;
		cout << "splash window" << endl;
		sleep(2000);
		cout << "closing splash window" << endl;
		[splashWindow orderOut:nil];
	}
};

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[mainController restoreDefaults];
/*
	SplashWindowClass* splashWindowClass=new SplashWindowClass(window,splashWindow);
	splashWindowClass->start();
*/
}

- (IBAction)clearLogButtonClicked:(id)sender {
}

- (IBAction)saveLogButtonClicked:(id)sender {
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
	[mainController saveDefaults];
	return(NSTerminateNow);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
	[mainController saveDefaults];
	return(NSTerminateNow);
}

- (NSWindow*)getMainWindow{
	return window;
}
@end
