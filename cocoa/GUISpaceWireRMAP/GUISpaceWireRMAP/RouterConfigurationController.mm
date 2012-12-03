//
//  RouterConfigurationController.mm
//  GUISpaceWireRMAP
//
//  Created by Takayuki Yuasa on 2012/11/30.
//
//

#import "RouterConfigurationController.h"

#import "CommonHeader.h"
#import "GSRMainController.h"


@implementation RouterConfigurationController

- (id)init{
    self = [super init];
    if (self) {
		[self initializeRoutingTableVector];
		router = new ShimafujiElectricSpaceWireToGigabitEthernetStandalone();
		rmapTargetRouterConfigurationPort = router->getRMAPTargetNodeInstance();
		[self notAccessible];
    }
	return self;
}

- (void)dealloc{
	[super dealloc];
}

- (void)saveDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	
	//target SpaceWire address cell
	[ud setObject:[targetSpaceWireAddressCell stringValue] forKey:@"RouterConfiguration.SpaceWireAddressCell"];
	
	//reply address cell
	[ud setObject:[replyAddressCell stringValue] forKey:@"RouterConfiguration.ReplyAddressCell"];
}

- (void)restoreDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	
	[targetSpaceWireAddressCell setStringValue:[ud stringForKey:@"RouterConfiguration.SpaceWireAddressCell"]];
	[replyAddressCell setStringValue:[ud stringForKey:@"RouterConfiguration.ReplyAddressCell"]];
}

- (std::string)toString:(NSString*)string{
	return [string cStringUsingEncoding:NSASCIIStringEncoding];
}

- (NSString*)toNSString:(std::string)string{
	return [NSString stringWithUTF8String:string.c_str()];
}

- (void)applicationFinishedLaunching{
	[self notAccessible];
}

- (IBAction)routerTypeSelectorAction:(id)sender {
	//only one router is currently implemented
}

- (IBAction)checkAvailabilityButtonClicked:(id)sender {
	using namespace std;
	if(![rmapViewController isRMAPEngineStarted]){//if rmapEngine is not available
		[Utility showDialogBox:@"RMAP Engine cannot be started." :@"Check TCP/IP connection to SpaceWire-to-GigabitEther."];
		return;
	}
	
	RMAPInitiator* rmapInitiator=[rmapViewController getRMAPInitiator];
	router->setRMAPInitiator(rmapInitiator);
	try{
		uint8_t value[4];
		router->readLinkControlStatusRegister(1,value);
		[self accessible];
		[self readWholeRoutingTable];
		std::stringstream ss;
		using namespace std;
		ss << "Router Congiguration ports is accessible." << endl;
		[mainController addMessage:[Utility toNSString:ss.str()]];
	}catch(...){
		[self showSpaceWireErrorMessage];
		[self notAccessible];
		return;
	}
	
	try{
		[deviceIDLabel setStringValue:[Utility toNSString:router->getDeviceIDAsString()]];
		[revisionIDLabel setStringValue:[Utility toNSString:router->getFPGARevisionAsString()]];
		[spaceWireIPRevisionLabel setStringValue:[Utility toNSString:router->getSpaceWireIPRevisionAsString()]];
		[rmapIPRevisionLabel setStringValue:[Utility toNSString:router->getRMAPIPRevisionAsString()]];
	}catch(...){
		[self showSpaceWireErrorMessage];
		[self notAccessible];
		return;
	}
	
}

- (IBAction)portSelectorAction:(id)sender {
	selectedPort=[[[(NSPopUpButton*)sender selectedItem] title] integerValue];
}

- (IBAction)txSelectorAction:(id)sender {
	std::string str=[Utility toString:[[(NSPopUpButton*)sender selectedItem] title]];
	std::vector<std::string> strs=CxxUtilities::String::split(str," ");
	double rate=CxxUtilities::String::toDouble(strs[0]);
	if(router->isSpecifiedLinkFrequencyAvailable(rate)){
		try{
			router->setLinkFrequency(selectedPort,rate);
			std::stringstream ss;
			using namespace std;
			ss << "Link rate of Port " << (uint32_t)selectedPort << " was changed to " << rate << " MHz." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}catch(...){
			std::stringstream ss;
			using namespace std;
			ss << "Link rate could not be changed due to an error." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
			[self showSpaceWireErrorMessage];
		}
	}else{
		[Utility showDialogBox:@"Selected Tx frequency is not available." :@"Try other values."];
		return;
	}
	[self updateStatus];
}

- (IBAction)linkEnableClicked:(id)sender {
	using namespace std;
	if(![rmapViewController isRMAPEngineStarted]){//if rmapEngine is not available
		[Utility showDialogBox:@"RMAP Engine cannot be started." :@"Check TCP/IP connection to SpaceWire-to-GigabitEther."];
		return;
	}
	
	RMAPInitiator* rmapInitiator=[rmapViewController getRMAPInitiator];
	router->setRMAPInitiator(rmapInitiator);
	try{
		if([(NSButton*)sender state]==1){
			router->setLinkEnable(selectedPort);
			std::stringstream ss;
			using namespace std;
			ss << "Port " << (uint32_t)selectedPort << ": Link Enabled." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}else{
			router->setLinkDisable(selectedPort);
			std::stringstream ss;
			using namespace std;
			ss << "Port " << (uint32_t)selectedPort << ": Link Disabled." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}
		[self updateStatus];
	}catch(...){
		[self showSpaceWireErrorMessage];
		return;
	}
}

- (IBAction)linkStartClicked:(id)sender {
	using namespace std;
	if(![rmapViewController isRMAPEngineStarted]){//if rmapEngine is not available
		[Utility showDialogBox:@"RMAP Engine cannot be started." :@"Check TCP/IP connection to SpaceWire-to-GigabitEther."];
		return;
	}
	
	RMAPInitiator* rmapInitiator=[rmapViewController getRMAPInitiator];
	router->setRMAPInitiator(rmapInitiator);
	try{
		if([(NSButton*)sender state]==1){
			router->setLinkStart(selectedPort);
			std::stringstream ss;
			using namespace std;
			ss << "Port " << (uint32_t)selectedPort << ": Link Start On." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}else{
			router->unsetLinkStart(selectedPort);
			std::stringstream ss;
			using namespace std;
			ss << "Port " << (uint32_t)selectedPort << ": Link Start Off." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}
		[self updateStatus];
	}catch(...){
		[self showSpaceWireErrorMessage];
		return;
	}
}

- (IBAction)autoStartClicked:(id)sender {
	using namespace std;
	if(![rmapViewController isRMAPEngineStarted]){//if rmapEngine is not available
		[Utility showDialogBox:@"RMAP Engine cannot be started." :@"Check TCP/IP connection to SpaceWire-to-GigabitEther."];
		return;
	}
	
	RMAPInitiator* rmapInitiator=[rmapViewController getRMAPInitiator];
	router->setRMAPInitiator(rmapInitiator);
	try{
		if([(NSButton*)sender state]==1){
			router->setAutoStart(selectedPort);
			std::stringstream ss;
			using namespace std;
			ss << "Port " << (uint32_t)selectedPort << ": Auto Start On." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}else{
			router->unsetAutoStart(selectedPort);
			std::stringstream ss;
			using namespace std;
			ss << "Port " << (uint32_t)selectedPort << ": Auto Start Off." << endl;
			[mainController addMessage:[Utility toNSString:ss.str()]];
		}
		[self updateStatus];
	}catch(...){
		[self showSpaceWireErrorMessage];
		return;
	}
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
	if([[aTableView identifier] isEqualToString:@"routingTableTable"]){
		return (SpaceWireProtocol::MaximumLogicalAddress-SpaceWireProtocol::MinimumLogicalAddress);
	}else if([[aTableView identifier] isEqualToString:@"portStatusTable"]){
		return portStatus.size();
	}else{
		return 0;
	}
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
			using namespace std;
	if([[aTableView identifier] isEqualToString:@"routingTableTable"]){
		//use uint32_t instead of uint8_t here because of easy printing
		uint32_t logicalAddress=rowIndex+SpaceWireProtocol::MinimumLogicalAddress;
		
		if([[aTableColumn identifier] isEqualToString: @"columnRoutedPorts"]){
			stringstream ss;
			std::vector<uint8_t> routedPorts=routingTable.at(logicalAddress);
			for(size_t i=0;i<routedPorts.size();i++){
				ss << dec << (uint32_t)routedPorts.at(i);
				if(i!=routedPorts.size()-1){
					ss << ", ";
				}
			}
			NSString *st=[[NSString alloc] initWithCString:ss.str().c_str() encoding:NSASCIIStringEncoding];
			return st;
		}else{//logical address column
			stringstream ss;
			ss << hex << uppercase << right << setw(2) << setfill('0')  << (uint32_t)logicalAddress << " (" << dec << logicalAddress << ")";
			NSString *st=[[NSString alloc] initWithCString:ss.str().c_str() encoding:NSASCIIStringEncoding];
			return st;
		}
	}else if([[aTableView identifier] isEqualToString:@"portStatusTable"]){
		if(rowIndex<portStatus.size()){
			uint32_t port=rowIndex;
			if([[aTableColumn identifier] isEqualToString: @"portColumn"]){
				return [Utility integerToNSString:portStatus.at(port).portNumber];
			}
			if([[aTableColumn identifier] isEqualToString: @"statusColumn"]){
				if(portStatus.at(port).connected==true){
					return [Utility toNSString:"Connected"];
				}else{
					return [Utility toNSString:"Disconnected"];
				}
			}
			if([[aTableColumn identifier] isEqualToString: @"TxRateColumn"]){
				return [Utility doubleToNSString:portStatus.at(port).txRate];
			}
			if([[aTableColumn identifier] isEqualToString: @"enabledColumn"]){
				if(portStatus.at(port).linkEnabled==true){
					return [Utility toNSString:"YES"];
				}else{
					return [Utility toNSString:"NO"];
				}
			}
			if([[aTableColumn identifier] isEqualToString: @"startedColumn"]){
				if(portStatus.at(port).linkStarted==true){
					return [Utility toNSString:"YES"];
				}else{
					return [Utility toNSString:"NO"];
				}
			}
			if([[aTableColumn identifier] isEqualToString: @"autoStartColumn"]){
				if(portStatus.at(port).autoStart==true){
					return [Utility toNSString:"YES"];
				}else{
					return [Utility toNSString:"NO"];
				}
			}
		}
	}
	//will not reach here
	return NULL;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex{
	using namespace std;
	
	if([[aTableColumn identifier] isEqualToString: @"columnRoutedPorts"]){
		uint32_t logicalAddress=rowIndex+SpaceWireProtocol::MinimumLogicalAddress;
		std::string str=[Utility toString:anObject];
		str=CxxUtilities::String::replace(str,","," ");
		std::vector<uint8_t> ports=CxxUtilities::String::toUInt8Array(str);
		
		//check if all ports are valid
		if(!router->areAllPortNumbersValid(ports)){
			[Utility showDialogBox:@"Invalid routing port is specified." :@"Check values in the routing table."];
			return;
		}

		if(![rmapViewController isRMAPEngineStarted]){//if rmapEngine is not available
			[Utility showDialogBox:@"RMAP Engine cannot be started." :@"Check TCP/IP connection to SpaceWire-to-GigabitEther."];
			return;
		}
		
		RMAPInitiator* rmapInitiator=[rmapViewController getRMAPInitiator];
		router->setRMAPInitiator(rmapInitiator);
		try{
			router->writeRoutingTable(logicalAddress, ports);
			routingTable[logicalAddress]=ports;
		}catch(...){
			[self showSpaceWireErrorMessage];
			return;
		}

		std::stringstream ss;
		using namespace std;
		ss << "Routing Table has been updated." << endl;
		ss << "Logical Address " << "0x" << hex << right << setw(2) << setfill('0')  << (uint32_t)logicalAddress << " is routed to Port ";
		for(size_t i=0;i<ports.size();i++){
			ss << "0x" << hex << right << setw(2) << setfill('0')  << (uint32_t)ports[i];
			if(i!=ports.size()-1){
				ss << ",";
			}
		}
		ss << endl;
		[mainController addMessage:[Utility toNSString:ss.str()]];
	}
}

- (void)setNumberOfPorts{
	[portSelector removeAllItems];
	std::vector<uint8_t> ports=router->getConfigurablePorts();
	for(size_t i=0;i<ports.size();i++){
		std::stringstream ss;
		ss << std::dec << (uint32_t)ports[i];
		[portSelector addItemWithTitle:[Utility toNSString:ss.str()]];
	}
	selectedPort=1;
}

- (void)updateStatus{
	using namespace std;
	stringstream ss;
	portStatus.clear();
	
	try{
		for(size_t i=1;i<=router->NumberOfExternalPorts;i++){
			PortStatus p;
			p.portNumber=i;
			p.linkEnabled=router->isLinkEnabled(i);
			p.linkStarted=router->isLinkStarted(i);
			p.autoStart=router->isAutoStarted(i);
			p.txRate=router->getLinkFrequency(i);
			p.connected=router->isConnected(i);
			portStatus.push_back(p);
		}
		
		PortStatus p6,p7;
		p6.portNumber=6;
		p6.linkEnabled=true;
		p6.linkStarted=true;
		p6.autoStart=true;
		p6.txRate=200;
		p6.connected=true;
		p7.portNumber=7;
		p7.linkEnabled=true;
		p7.linkStarted=true;
		p7.autoStart=true;
		p7.txRate=200;
		p7.connected=true;
		portStatus.push_back(p6);
		portStatus.push_back(p7);
		
		[portStatusTable reloadData];
	}catch(...){
		[self showSpaceWireErrorMessage];
		[self notAccessible];
		return;
	}
}

- (void)notAccessible{
	//change state of GUI parts
	[linkEnableButton setEnabled:NO];
	[linkStartButton setEnabled:NO];
	[autoStartButton setEnabled:NO];
	[linkRateSelector setEnabled:NO];
	[portSelector setEnabled:NO];
	
	[self initializeRoutingTableVector];
}

- (void)accessible{
	//change state of GUI parts
	[linkEnableButton setEnabled:YES];
	[linkStartButton setEnabled:YES];
	[autoStartButton setEnabled:YES];
	[linkRateSelector setEnabled:YES];
	[portSelector setEnabled:YES];

	[self setNumberOfPorts];
	
	[self updateStatus];
}

- (void) initializeRoutingTableVector{
	routingTable.clear();
	routingTable.resize(SpaceWireProtocol::MaximumLogicalAddress+1);
}

- (void) readWholeRoutingTable{
	try{
		std::vector<std::vector<uint8_t> > table0x20_0xFE=router->readWholeRoutingTable();
		[self initializeRoutingTableVector];
		for(size_t i=0;i<table0x20_0xFE.size();i++){
			routingTable[SpaceWireProtocol::MinimumLogicalAddress+i]=table0x20_0xFE[i];
		}
		[routingTableTableView reloadData];
	}catch(...){
		[Utility showDialogBox:@"Routing Table could not be read out." :@"SpaceWire-to-GigabitEther might not be available."];
		[self notAccessible];
	}
}

- (void) showSpaceWireErrorMessage{
	[Utility showDialogBox:@"Could not access to the Router Congiguration port." :@"Check if SpaceWire-to-GigabitEther has the latest FPGA."];
}
@end
