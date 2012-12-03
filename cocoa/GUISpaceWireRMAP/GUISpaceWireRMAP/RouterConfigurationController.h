//
//  RouterConfigurationController.h
//  GUISpaceWireRMAP
//
//  Created by Takayuki Yuasa on 2012/11/30.
//
//

#import <Foundation/Foundation.h>
#import "GSRMainController.h"

#include "SpaceWire.hh"
#include "ConfigurationPorts/ShimafujiElectricSpaceWireToGigabitEthernetStandalone.hh"

class PortStatus {
public:
	uint32_t portNumber;
	
public:
	bool linkEnabled;
	bool linkStarted;
	bool autoStart;
	
public:
	double txRate;
	
public:
	bool connected;
};

@interface RouterConfigurationController : NSObject {

	///////////////////////////
	IBOutlet NSFormCell *targetSpaceWireAddressCell;
	IBOutlet NSFormCell *replyAddressCell;
	
	IBOutlet NSTextField *deviceIDLabel;
	IBOutlet NSTextField *revisionIDLabel;
	IBOutlet NSTextField *spaceWireIPRevisionLabel;
	IBOutlet NSTextField *rmapIPRevisionLabel;
	
	IBOutlet NSPopUpButton *portSelector;
	IBOutlet NSPopUpButton *linkRateSelector;
	
	IBOutlet NSButton *linkEnableButton;
	IBOutlet NSButton *linkStartButton;
	IBOutlet NSButton *autoStartButton;
	
	IBOutlet NSTextView *statusTextView;
	
	IBOutlet NSTableView *routingTableTableView;

	IBOutlet NSTableView *portStatusTable;
	
	//main controller
	IBOutlet GSRMainController *mainController;

	//main window
	IBOutlet NSWindow *mainWindow;

	IBOutlet RMAPViewController *rmapViewController;
	
	//////////////////////////
	RMAPTargetNode* rmapTargetRouterConfigurationPort;
	ShimafujiElectricSpaceWireToGigabitEthernetStandalone* router;
	NSButton *linkEnableCliked;
	NSButton *linkStartClicked;
	NSButton *autoStartClicked;
	
	std::vector<std::vector<uint8_t> > routingTable;
	std::vector<PortStatus> portStatus;
	
	//
	uint8_t selectedPort;
}

- (IBAction)routerTypeSelectorAction:(id)sender;
- (IBAction)checkAvailabilityButtonClicked:(id)sender;


- (IBAction)portSelectorAction:(id)sender;
- (IBAction)txSelectorAction:(id)sender;


- (IBAction)linkEnableClicked:(id)sender;
- (IBAction)linkStartClicked:(id)sender;
- (IBAction)autoStartClicked:(id)sender;

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex;

- (void)setNumberOfPorts;

- (void)updateStatus;

- (void)notAccessible;

- (void)accessible;

- (void) initializeRoutingTableVector;

- (void) readWholeRoutingTable;

- (void) showSpaceWireErrorMessage;

@end
