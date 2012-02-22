//
//  RMAPPacketUtilityController.h
//  GUISpaceWireRMAP
//
//  Created by Takayuki Yuasa on 11/07/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSRMainController.h"
#undef NO_XMLLODER
#include "RMAPPacket.hh"

@interface RMAPPacketUtilityViewController : NSObject {
@private
	//GUI objects
	IBOutlet NSFormCell *initiatorLogicalAddressField;
	
	IBOutlet NSFormCell *targetLogicalAddressField;
	IBOutlet NSFormCell *targetSpaceWireAddressField;
	IBOutlet NSFormCell *returnPathAddressField;
	IBOutlet NSFormCell *transactionIDField;
	IBOutlet NSFormCell *keyField;

	IBOutlet NSPopUpButton *readWriteSelector;
	IBOutlet NSPopUpButton *verifyNoVerifySelector;
	IBOutlet NSPopUpButton *commandReplySelector;
	IBOutlet NSPopUpButton *ackNoAckSelector;
	IBOutlet NSPopUpButton *inrementNoIncrementSelector;
	IBOutlet NSFormCell *extendedAddressField;
	IBOutlet NSFormCell *memoryAddressField;
	IBOutlet NSFormCell *lengthField;
	IBOutlet NSPopUpButton *headerCRCSelector;
	IBOutlet NSTextField *headerCRCField;
	IBOutlet NSPopUpButton *dataCRCSelector;
	IBOutlet NSTextField *dataCRCField;
	IBOutlet NSTextField *replyStatusField;
	
	IBOutlet NSTextField *replyStatusLabel;
	IBOutlet NSTextField *instructionField;
	
	IBOutlet NSTextView *dataField;
	IBOutlet NSTextView *byteSequenceField;
	
	IBOutlet NSButton *generateButton;
	IBOutlet NSButton *interpretButton;
	
	//log setting
	IBOutlet NSButton *logPacketDumpForGenerationButton;
	IBOutlet NSButton *logPacketDumpForInterpretationButton;
	
	//instances of original classes
	IBOutlet GSRMainController *mainController;
	
	//instances of library classes
	RMAPPacket* rmapPacket;
}

- (void)applicationFinishedLaunching;

- (void)saveDefaults;
- (void)restoreDefaults;

- (IBAction)generateButtonPushed:(id)sender;
- (IBAction)interpretButtonPushed:(id)sender;

- (unsigned char)toUnsignedChar:(id)inputfield;
- (void)setUnsignedChar:(unsigned char)data to:(id)field;
- (void)setInteger:(int)data to:(id)field;
- (std::vector<unsigned char>)toUnsignedCharArray:(id)inputfield;
- (void)setUnsignedCharArray:(std::vector<unsigned char>)data to:(id)field;

- (IBAction)instructionSelectorUpdated:(id)sender;
- (IBAction)instructionFieldUpdated:(id)sender;
- (IBAction)replyStatusUpdated:(id)sender;

@end
