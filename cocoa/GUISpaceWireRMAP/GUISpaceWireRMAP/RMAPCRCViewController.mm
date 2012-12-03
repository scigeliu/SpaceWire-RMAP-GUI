//
//  RMAPCRCViewController.mm
//  RMAP CRC Calculator
//
//  Created by 湯浅 孝行 on 11/11/29.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "RMAPCRCViewController.h"

@implementation RMAPCRCViewController

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
	return self;
}

- (void)dealloc{
	[super dealloc];
}

- (void)saveDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	
	//total bytes cell
	[ud setObject:[totalBytesCell stringValue] forKey:@"RMAPCRC.totalBytesCell"];
	
	//crc cell
	[ud setObject:[crcCell stringValue] forKey:@"RMAPCRC.crcCell"];
		
	//data
	[ud setObject:[dataCell string] forKey:@"RMAPCRC.dataCell"];
	
	//all hex check box
	[ud setInteger:[allHexCheckBox state] forKey:@"RMAPCRC.allHexCheckBox"];
}

- (void)restoreDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	
	[totalBytesCell setStringValue:[ud stringForKey:@"RMAPCRC.totalBytesCell"]];
	[crcCell setStringValue:[ud stringForKey:@"RMAPCRC.crcCell"]];
	[Utility setTextToNSTextView:[ud stringForKey:@"RMAPCRC.dataCell"] to:dataCell];
	[allHexCheckBox setState:[ud integerForKey:@"RMAPCRC.allHexCheckBox"]];
}

- (std::string)toString:(NSString*)string{
	return [string cStringUsingEncoding:NSASCIIStringEncoding];
}

- (NSString*)toNSString:(std::string)string{
	return [NSString stringWithUTF8String:string.c_str()];
}

- (void)applicationFinishedLaunching{
	//set font
	[dataCell setFont:[NSFont fontWithName:@"Courier" size:11]]; 
}

- (IBAction)calculateButton:(id)sender {
	using namespace std;
	using namespace CxxUtilities;
	[totalBytesCell setStringValue:[self toNSString:""]];
	[crcCell setStringValue:[self toNSString:""]];
	string str=[self toString:[dataCell string]];
	if([allHexCheckBox state]==NSOnState){
		str=String::put0xForAllElements(str);
	}
	vector<uint8_t> array=String::toUInt8Array(str);
	uint8_t crc=RMAPUtilities::calculateCRC(array);
	stringstream ss;
	ss << "0x" << hex << setfill('0') << setw(2) << right << (uint32_t)crc;
	[crcCell setStringValue:[self toNSString:ss.str()]];
	stringstream ss2;
	ss2 << dec << array.size();
	[totalBytesCell setStringValue:[self toNSString:ss2.str()]];
}

@end
