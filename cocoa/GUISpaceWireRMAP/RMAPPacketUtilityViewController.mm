//
//  RMAPPacketUtilityController.m
//  GUISpaceWireRMAP
//
//  Created by Takayuki Yuasa on 11/07/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RMAPPacketUtilityViewController.h"
#include "CxxUtilities/CxxUtilities.hh"
#import "Utility.h"

using namespace CxxUtilities;
using namespace std;

@implementation RMAPPacketUtilityViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
	rmapPacket=new RMAPPacket();
	
    return self;
}

- (void)dealloc
{
	delete rmapPacket;
    [super dealloc];
}

- (void)applicationFinishedLaunching{
	//set fonts
	[dataField setFont:[NSFont fontWithName:@"Courier" size:10]]; 
	[byteSequenceField setFont:[NSFont fontWithName:@"Courier" size:10]]; 
}

- (void)saveDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	/*
	 // NSUserDefaultsに保存・更新する
	 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
	 [ud setInteger:100 forKey:@"KEY_I"];  // int型の100をKEY_Iというキーで保存
	 [ud setFloat:1.23 forKey:@"KEY_F"];  // float型の1.23をKEY_Fというキーで保存
	 [ud setDouble:1.23 forKey:@"KEY_D"];  // double型の1.23をKEY_Dというキーで保存
	 [ud setBool:YES forKey:@"KEY_B"];  // BOOL型のYESをKEY_Bというキーで保存
	 [ud setObject:@"あいう" forKey:@"KEY_S"];  // "あいう"をKEY_Sというキーで保存
	 [ud synchronize];  // NSUserDefaultsに即時反映させる（即時で無くてもよい場合は不要）
	 */
	
	//initiator/target information
	[ud setObject:[initiatorLogicalAddressField stringValue] forKey:@"RMAPPacketUtility.initiatorLogicalAddressField"];
	[ud setObject:[targetLogicalAddressField stringValue] forKey:@"RMAPPacketUtility.targetLogicalAddressField"];
	[ud setObject:[keyField stringValue] forKey:@"RMAPPacketUtility.Key"];
	[ud setObject:[targetSpaceWireAddressField stringValue] forKey:@"RMAPPacketUtility.targetSpaceWireAddressField"];
	[ud setObject:[returnPathAddressField stringValue] forKey:@"RMAPPacketUtility.returnPathAddressField"];
	[ud setObject:[transactionIDField stringValue] forKey:@"RMAPPacketUtility.transactionIDField"];
	
	
	//memory information
	[ud setObject:[extendedAddressField stringValue] forKey:@"RMAPPacketUtility.extendedAddressField"];
	[ud setObject:[memoryAddressField stringValue] forKey:@"RMAPPacketUtility.memoryAddressField"];
	[ud setObject:[lengthField stringValue] forKey:@"RMAPPacketUtility.lengthField"];
	
	//crc
	[ud setObject:[headerCRCSelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.headerCRCSelector"];
	[ud setObject:[dataCRCSelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.dataCRCSelector"];
	[ud setObject:[headerCRCField stringValue] forKey:@"RMAPPacketUtility.headerCRCField"];
	[ud setObject:[dataCRCField stringValue] forKey:@"RMAPPacketUtility.dataCRCField"];
	
	//reply status
	[ud setObject:[replyStatusField stringValue] forKey:@"RMAPPacketUtility.replyStatusField"];
	
	//instruction
	[ud setObject:[readWriteSelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.readWriteSelector"];
	[ud setObject:[verifyNoVerifySelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.verifyNoVerifySelector"];
	[ud setObject:[commandReplySelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.commandReplySelector"];
	[ud setObject:[ackNoAckSelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.ackNoAckSelector"];
	[ud setObject:[inrementNoIncrementSelector titleOfSelectedItem] forKey:@"RMAPPacketUtility.inrementNoIncrementSelector"];

	//data
	[ud setObject:[dataField string] forKey:@"RMAPPacketUtility.dataField"];
	
	//byte sequence
	[ud setObject:[byteSequenceField string] forKey:@"RMAPPacketUtility.byteSequenceField"];
	
	//log button
	[ud setInteger:[logPacketDumpForGenerationButton state] forKey:@"RMAPPacketUtility.logPacketDumpForGenerationButton"];
	[ud setInteger:[logPacketDumpForInterpretationButton state] forKey:@"RMAPPacketUtility.logPacketDumpForInterpretationButton"];
}

- (void)restoreDefaults{
	NSUserDefaults* ud=[mainController getNSUserDefaults];
	
	//initiator/target information
	[initiatorLogicalAddressField setStringValue:[ud stringForKey:@"RMAPPacketUtility.initiatorLogicalAddressField"]];
	[targetLogicalAddressField setStringValue:[ud stringForKey:@"RMAPPacketUtility.targetLogicalAddressField"]];
	[keyField setStringValue:[ud stringForKey:@"RMAPPacketUtility.Key"]];
	[targetSpaceWireAddressField setStringValue:[ud stringForKey:@"RMAPPacketUtility.targetSpaceWireAddressField"]];
	[returnPathAddressField setStringValue:[ud stringForKey:@"RMAPPacketUtility.returnPathAddressField"]];
	[transactionIDField setStringValue:[ud stringForKey:@"RMAPPacketUtility.transactionIDField"]];
	
	//memory information
	[extendedAddressField setStringValue:[ud stringForKey:@"RMAPPacketUtility.extendedAddressField"]];
	[memoryAddressField setStringValue:[ud stringForKey:@"RMAPPacketUtility.memoryAddressField"]];
	[lengthField setStringValue:[ud stringForKey:@"RMAPPacketUtility.lengthField"]];

	//crc
	[headerCRCSelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.headerCRCSelector"]];
	[dataCRCSelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.dataCRCSelector"]];
	[headerCRCField setStringValue:[ud stringForKey:@"RMAPPacketUtility.headerCRCField"]];
	[dataCRCField setStringValue:[ud stringForKey:@"RMAPPacketUtility.dataCRCField"]];
	
	//reply status
	[replyStatusField setStringValue:[ud stringForKey:@"RMAPPacketUtility.replyStatusField"]];
	
	//instruction
	[readWriteSelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.readWriteSelector"]];
	[verifyNoVerifySelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.verifyNoVerifySelector"]];
	[commandReplySelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.commandReplySelector"]];
	[ackNoAckSelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.ackNoAckSelector"]];
	[inrementNoIncrementSelector selectItemWithTitle:[ud stringForKey:@"RMAPPacketUtility.inrementNoIncrementSelector"]];
	
	//data
	[Utility setTextToNSTextView:[ud stringForKey:@"RMAPPacketUtility.dataField"] to:dataField];
	
	//byte sequence
	[Utility setTextToNSTextView:[ud stringForKey:@"RMAPPacketUtility.byteSequenceField"] to:byteSequenceField];
	
	//log button
	[logPacketDumpForGenerationButton setState:[ud integerForKey:@"RMAPPacketUtility.logPacketDumpForGenerationButton"]];
	[logPacketDumpForInterpretationButton setState:[ud integerForKey:@"RMAPPacketUtility.logPacketDumpForInterpretationButton"]];
}


- (unsigned char)toUnsignedChar:(id)inputfield {
	return [Utility toUInt8:inputfield];
}

- (uint8_t)toUInt8:(id)inputfield {
	return [Utility toUInt8:inputfield];
}

- (uint16_t)toUInt16:(id)inputfield {
	return [Utility toUInt16:inputfield];
}

- (uint32_t)toUInt32:(id)inputfield {
	return [Utility toUInt32:inputfield];
}

- (void)setUnsignedChar:(unsigned char)data to:(id)field{
	[field setStringValue:[[NSString stringWithString:@"0x"] stringByAppendingString:[NSString stringWithFormat:@"%02x",(uint32_t)data]]];
}

- (void)setInteger:(int)data to:(id)field{
	[field setStringValue:[[NSString stringWithString:@"0x"] stringByAppendingString:[NSString stringWithFormat:@"%02x",(uint32_t)data]]];
}

- (std::vector<unsigned char>)toUnsignedCharArray:(id)inputfield{
	return String::toUnsignedCharArray([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (std::vector<uint8_t>)toUInt8Array:(id)inputfield{
	return String::toUInt8Array([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (void)setUnsignedCharArray:(std::vector<unsigned char>)data to:(id)field{
	stringstream ss;
	for(int i=0;i<data.size();i++){
		ss << "0x" << hex << setw(2) << setfill('0') << right << (uint32_t)data[i];
		if(i!=data.size()-1){
			ss << " ";
		}
	}
	if(ss.str()==""){
		ss << " ";
	}
	[field setStringValue:[NSString stringWithUTF8String:ss.str().c_str()]];
}

- (void)setUInt8Array:(std::vector<uint8_t>)data to:(id)field{
	stringstream ss;
	for(int i=0;i<data.size();i++){
		ss << "0x" << hex << setw(2) << setfill('0') << right << (uint32_t)data[i];
		if(i!=data.size()-1){
			ss << " ";
		}
	}
	if(ss.str()==""){
		ss << " ";
	}
	[field setStringValue:[NSString stringWithUTF8String:ss.str().c_str()]];
}

- (IBAction)generateButtonPushed:(id)sender {
	using namespace std;
	rmapPacket->setInitiatorLogicalAddress([self toUnsignedChar:initiatorLogicalAddressField]);
	rmapPacket->setReplyAddress([self toUInt8Array:returnPathAddressField]);
	rmapPacket->setTargetLogicalAddress([self toUnsignedChar:targetLogicalAddressField]);
	rmapPacket->setTargetSpaceWireAddress([self toUInt8Array:targetSpaceWireAddressField]);
	rmapPacket->setKey([self toUnsignedChar:keyField]);

	if([readWriteSelector selectedTag]==0){
		rmapPacket->setRead();
	}else{
		rmapPacket->setWrite();
	}
	
	if([commandReplySelector selectedTag]==1){
		rmapPacket->setCommand();
	}else{
		rmapPacket->setReply();
	}
	
	if([ackNoAckSelector selectedTag]==1){
		rmapPacket->setReplyMode();
	}else{
		rmapPacket->setNoReplyMode();
	}
	
	if([inrementNoIncrementSelector selectedTag]==1){
		rmapPacket->setIncrementMode();
	}else{
		rmapPacket->setNoIncrementMode();
	}
	
	if([verifyNoVerifySelector selectedTag]==1){
		rmapPacket->setVerifyMode();
	}else{
		rmapPacket->setNoVerifyMode();
	}
	
	//key
	rmapPacket->setKey([self toUnsignedChar:keyField]);
	
	//transaction ID
	rmapPacket->setTransactionID([self toUInt16:transactionIDField]);
	
	//reply status
	if(rmapPacket->isReply()){
		rmapPacket->setStatus([self toUInt8:replyStatusField]);
	}
	
	//extended address
	rmapPacket->setExtendedAddress([self toUnsignedChar:extendedAddressField]);
	
	//memory address
	rmapPacket->setAddress([self toUInt32:memoryAddressField]);
 	
	//set data (only for write command and read reply)
	if( (rmapPacket->isRead() && rmapPacket->isReply()) || (rmapPacket->isWrite() && rmapPacket->isCommand())){
		std::vector<uint8> data=CxxUtilities::String::toUInt8Array([Utility toString:[dataField string]]);
		rmapPacket->setData(data);
	}else{
		std::vector<uint8> data;
		rmapPacket->setData(data);
	}

	//data length (only for read command and write reply)
	using namespace std;
	if( (rmapPacket->isRead() && rmapPacket->isCommand()) || (rmapPacket->isWrite() && rmapPacket->isReply())){
		rmapPacket->setLength([self toUInt32:lengthField]);
	}
	
	//CRCs
	if([headerCRCSelector selectedTag]==0){
		rmapPacket->setHeaderCRCMode(RMAPPacket::AutoCRC);
	}else{
		rmapPacket->setHeaderCRCMode(RMAPPacket::ManualCRC);
		rmapPacket->setHeaderCRC([self toUnsignedChar:headerCRCField]);
	}

	if([dataCRCSelector selectedTag]==0){
		rmapPacket->setDataCRCMode(RMAPPacket::AutoCRC);
	}else{
		rmapPacket->setDataCRCMode(RMAPPacket::ManualCRC);
		rmapPacket->setDataCRC([self toUnsignedChar:dataCRCField]);
	}
	
	//create
	rmapPacket->constructPacket();
	stringstream ss;
	std::vector<uint8_t> data=rmapPacket->getPacket();
	int wordwidth=1;
	int DumpsPerLine=8;
	SpaceWireUtilities::dumpPacket(&ss,&data,wordwidth,DumpsPerLine);
	[Utility setTextToNSTextView:[NSString stringWithUTF8String:ss.str().c_str()] to:byteSequenceField];
	
	[mainController addMessage:@"Packet was generated."];

	if([logPacketDumpForGenerationButton state]==NSOnState){
		[mainController addMessage:@"Packet dump:"];
		[mainController addMessage:[byteSequenceField string]];
		[mainController addMessageString:rmapPacket->toString()];
	}
}

- (void)updateReplyStatusLabel:(uint8_t)status{
	[replyStatusLabel setStringValue:[Utility toNSString:RMAPReplyStatus::replyStatusToStringWithoutCodeValue(status)]];
}

- (void)updateInstructionSelectors:(uint8_t)instruction{
	RMAPPacket tempPacket;
	tempPacket.setInstruction(instruction);
	
	if(tempPacket.isRead()){
		[readWriteSelector selectItemAtIndex:0];//read
	}else{
		[readWriteSelector selectItemAtIndex:1];//write
	}
	
	if(tempPacket.isCommand()){
		[commandReplySelector selectItemAtIndex:0];//command
	}else{
		[commandReplySelector selectItemAtIndex:1];//reply
	}
	
	if(tempPacket.isReplyFlagSet()){
		[ackNoAckSelector selectItemAtIndex:0];//ack
	}else{
		[ackNoAckSelector selectItemAtIndex:1];//no ack
	}
	
	if(tempPacket.isIncrementFlagSet()){
		[inrementNoIncrementSelector selectItemAtIndex:0];//increment
	}else{
		[inrementNoIncrementSelector selectItemAtIndex:1];//no increment
	}
	
	if(tempPacket.isVerifyFlagSet()){
		[verifyNoVerifySelector selectItemAtIndex:0];//verify
	}else{
		[verifyNoVerifySelector selectItemAtIndex:1];//no verify
	}
	
}

- (IBAction)interpretButtonPushed:(id)sender {
	bool dataLengthMismatch=false;
	std::vector<uint8_t> data=CxxUtilities::String::toUInt8Array([Utility toString:[byteSequenceField string]]);
	[mainController addMessage:@"Packet interpretation was executed."];
	//interpret withtout checking crcs
	try{
		rmapPacket->setHeaderCRCIsChecked(false);
		rmapPacket->setDataCRCIsChecked(false);
		rmapPacket->interpretAsAnRMAPPacket(&data);
	}catch(RMAPPacketException e){
		if(e.getStatus()==RMAPPacketException::DataLengthMismatch){
			[mainController addRedMessage:@"Warning: Data Length Mismatch. CRC check is not performed."];
			dataLengthMismatch=true;
		}else{
			goto invalidPacket;
		}
	}
	[mainController addMessage:@"Packet was interpreted."];
	
	if([logPacketDumpForInterpretationButton state]==NSOnState){
		[mainController addMessage:@"Packet dump:"];
		[mainController addMessage:[byteSequenceField string]];
		[mainController addMessageString:rmapPacket->toString()];
	}
	
	[self setUnsignedChar:(unsigned char)(rmapPacket->getInitiatorLogicalAddress()) to:initiatorLogicalAddressField];
	[self setUnsignedChar:(unsigned char)(rmapPacket->getTargetLogicalAddress()) to:targetLogicalAddressField];
	[self setUInt8Array:rmapPacket->getTargetSpaceWireAddress() to:targetSpaceWireAddressField];
	[self setUInt8Array:rmapPacket->getReplyAddress() to:returnPathAddressField];
	[self setInteger:rmapPacket->getTransactionID() to:transactionIDField];
	[self setUnsignedChar:rmapPacket->getKey() to:keyField];
	

	//set instruction field
	[Utility setUnsignedChar:rmapPacket->getInstruction() to:instructionField];
	[self updateInstructionSelectors:rmapPacket->getInstruction()];
	
	//reply status
	if(rmapPacket->isCommand()){
		[replyStatusField setStringValue:@" "];
	}else{
		[Utility setUInt8:rmapPacket->getStatus() to:replyStatusField];
	}
	
	[self setUnsignedChar:rmapPacket->getExtendedAddress() to:extendedAddressField];
	[self setInteger:rmapPacket->getAddress() to:memoryAddressField];
	[self setInteger:rmapPacket->getDataLength() to:lengthField];
	[self setUnsignedChar:rmapPacket->getHeaderCRC() to:headerCRCField];
	
	if(rmapPacket->hasData()){
		[self setUnsignedChar:rmapPacket->getDataCRC() to:dataCRCField];
		std::vector<uint8_t> dataPointer=rmapPacket->getData();
		[Utility setVectorUint8Pointer:&dataPointer terminatedWith:@"" toNSTextView:dataField];
	}else{
		[dataCRCField setStringValue:@" "];
		[Utility setTextToNSTextView:@" " to:dataField];
	}

	if(dataLengthMismatch){
		return;
	}
	
	//check header crc
	try {
		rmapPacket->setHeaderCRCIsChecked(true);
		rmapPacket->setDataCRCIsChecked(false);
		rmapPacket->interpretAsAnRMAPPacket(&data);
		[mainController addMessage:@"Header CRC is correct."];
	} catch (RMAPPacketException e) {
		if(e.getStatus()==RMAPPacketException::InvalidHeaderCRC){
			[mainController addRedMessage:@"Header CRC is not correct."];
			using namespace std;
			cerr << "Header CRC is not correct" << endl;
			rmapPacket->setHeaderCRCIsChecked(false);
			rmapPacket->setDataCRCIsChecked(false);
			rmapPacket->interpretAsAnRMAPPacket(&data);
			rmapPacket->constructPacket();
			using namespace std;
			stringstream ss;
			ss << "Correct Header CRC is 0x" << hex << setw(2) << setfill('0') << right << (uint32_t)rmapPacket->getHeaderCRC();
			[mainController addRedMessageString:ss.str()];
		}else{
			goto invalidPacket;
		}
	}
	
	//check data crc
	if (rmapPacket->hasData()) {
		try {
			rmapPacket->setHeaderCRCIsChecked(false);
			rmapPacket->setDataCRCIsChecked(true);
			rmapPacket->interpretAsAnRMAPPacket(&data);
			[mainController addMessage:@"Data CRC is correct."];
		} catch (RMAPPacketException e) {
			if(e.getStatus()==RMAPPacketException::InvalidDataCRC){
				[mainController addRedMessage:@"Data CRC is not correct."];
				rmapPacket->setHeaderCRCIsChecked(false);
				rmapPacket->setDataCRCIsChecked(false);
				rmapPacket->interpretAsAnRMAPPacket(&data);
				rmapPacket->constructPacket();
				rmapPacket->calculateDataCRC();
				using namespace std;
				stringstream ss;
				ss << "Correct Data CRC is 0x" << hex << setw(2) << setfill('0') << right << (uint32_t)rmapPacket->getDataCRC();
				[mainController addRedMessageString:ss.str()];
		   }else{
			   goto invalidPacket;
		   }
		}
	}
	
	return;
	
	invalidPacket:
	[mainController addRedMessage:@"Packet interpretation failed."];
	return;
}

- (IBAction)instructionSelectorUpdated:(id)sender {
	RMAPPacket tempPacket;
	if([readWriteSelector selectedTag]==0){
		tempPacket.setRead();
	}else{
		tempPacket.setWrite();
	}
	
	if([commandReplySelector selectedTag]==1){
		tempPacket.setCommand();
	}else{
		tempPacket.setReply();
	}
	
	if([ackNoAckSelector selectedTag]==1){
		tempPacket.setReplyMode();
	}else{
		tempPacket.setNoReplyMode();
	}
	
	if([inrementNoIncrementSelector selectedTag]==1){
		tempPacket.setIncrementMode();
	}else{
		tempPacket.setNoIncrementMode();
	}
	
	if([verifyNoVerifySelector selectedTag]==1){
		tempPacket.setVerifyMode();
	}else{
		tempPacket.setNoVerifyMode();
	}
	uint8_t instruction=tempPacket.getInstruction();
	[Utility setUnsignedChar:instruction to:instructionField];
}

- (IBAction)instructionFieldUpdated:(id)sender {
	uint8_t instruction=[Utility toUInt8:instructionField];
	[self updateInstructionSelectors:instruction];
}

- (IBAction)replyStatusUpdated:(id)sender {
	[self updateReplyStatusLabel:[Utility toUInt8:replyStatusField]];
}


@end

/*
std::string -> NSString
[NSString stringWithUTF8String:collect->getTheLatestResultAsString().c_str()]];
 
NSString -> std::string
 [[ipAddressCell stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
*/