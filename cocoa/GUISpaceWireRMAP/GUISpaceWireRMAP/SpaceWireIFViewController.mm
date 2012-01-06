//
//  SpaceWireIFViewController.m
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/25.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "SpaceWireIFViewController.h"
#import "Utility.h"
using namespace std;

@implementation SpaceWireIFViewController

- (id)init
{
    self = [super init];
    if (self) {
        connected=false;
		utility=[[Utility alloc] init];
    }
    return self;
}

- (void)saveDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	[ud setObject:[ipAddressCell stringValue] forKey:@"SpaceWireIF.IPAddressCell"];
	[ud setObject:[portCell stringValue] forKey:@"SpaceWireIF.PortCell"];
}

- (void)restoreDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	[ipAddressCell setStringValue:[ud stringForKey:@"SpaceWireIF.IPAddressCell"]];
	[portCell setStringValue:[ud stringForKey:@"SpaceWireIF.PortCell"]];
}

- (IBAction)connectButtonClicked:(id)sender {
	using namespace std;
	if(connected==false){
		[self connect];
	}else{
		[self disconnect];
	}
}

- (void)connect{
	//connect
	cout << [Utility toString:[ipAddressCell stringValue]] << " "<< [portCell intValue] << endl;
	spwif=new SpaceWireIFOverTCP([Utility toString:[ipAddressCell stringValue]],[portCell intValue]);
	try{
		spwif->open();
		cout << "connected" << endl;
	}catch(...){
		//open failed
		[mainController addRedMessage:@"Connection to SpaceWire-to-GigabitEther cannot be established."];
		[Utility showDialogBox:@"Connection to SpaceWire-to-GigabitEther cannot be established." :@"TCP/IP connection timeout."];
		delete spwif;
		return;
	}
	//register close action
	spwif->addSpaceWireIFCloseAction([spacewireViewController getSpaceWireViewContollerCloseActionStopContinuousReceiveInstance]);
	spwif->addSpaceWireIFCloseAction([rmapViewController getRMAPViewControllerCloseActionStopRMAPEngine]);
	//successfully connected
	[mainController setSpaceWireIFInstance:spwif];
	//change button label
	[connectButton setTitle:@"Disconnect"];
	//add log
	std::stringstream ss;
	ss << "SpaceWire-to-GigabitEther (" << [Utility toString:[ipAddressCell stringValue]] << ") is connected.";
	[mainController addMessageString:ss.str()];
	connected=true;
}

- (void)disconnect{
	if(connected==true){
		//notify other view controllers about disconnection
		[mainController tryingToDisconnectSpaceWireIF];
		//disconnect
		spwif->close();
		//change button label
		[connectButton setTitle:@"Connect"];
		//add log
		[mainController addMessage:@"SpaceWire-to-GigabitEther disconnected."];
		connected=false;
	}
}

- (void)spaceWireIFDisconnected{
	[self disconnect];
}


@end
