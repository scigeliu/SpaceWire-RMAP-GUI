//
//  Utility.m
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/26.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "Utility.h"
#include "CxxUtilities/CxxUtilities.hh"

using namespace std;
using namespace CxxUtilities;

@implementation Utility

+(id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(std::string)toString:(NSString*)string{
	return [string cStringUsingEncoding:NSASCIIStringEncoding];
}

+(NSString*)toNSString:(std::string)string{
	return [NSString stringWithUTF8String:string.c_str()];
}

+(int)toInt:(id)object{
	return (int)String::toInteger([[object stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
}

+(unsigned char)toUnsignedChar:(id)inputfield {
	return (unsigned char)String::toUInt32([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
}

+(uint8_t)toUInt8:(id)inputfield {
	return (uint8_t)(String::toUInt32([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding])%0xFF);
}

+(uint16_t)toUInt16:(id)inputfield {
	return (uint16_t)(String::toUInt32([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding])%0xFFFF);
}

+(uint32_t)toUInt32:(id)inputfield {
	return (uint32_t)String::toUInt32([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
}

+(void)setUnsignedChar:(unsigned char)data to:(id)field{
	[field setStringValue:[[NSString stringWithString:@"0x"] stringByAppendingString:[NSString stringWithFormat:@"%02x",data]]];
}

+(void)setUInt8:(uint8_t)data to:(id)field{
	[field setStringValue:[[NSString stringWithString:@"0x"] stringByAppendingString:[NSString stringWithFormat:@"%02x",data]]];
}

+(void)setInteger:(int)data to:(id)field{
	[field setStringValue:[[NSString stringWithString:@"0x"] stringByAppendingString:[NSString stringWithFormat:@"%02x",data]]];
}

+(std::vector<unsigned char>)toUnsignedCharArray:(id)inputfield{
	return String::toUnsignedCharArray([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
}

+(std::vector<uint8_t>)toUInt8Array:(id)inputfield{
	std::vector<unsigned char> data=String::toUnsignedCharArray([[inputfield stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
	std::vector<uint8_t> result;
	for(size_t i=0;i<data.size();i++){
		result.push_back((uint8_t)data[i]);
	}
	return result;
}

+(std::vector<uint8_t>)toUInt8ArrayFromTextView:(id)inputfield{
	std::vector<unsigned char> data=String::toUnsignedCharArray([[inputfield string] cStringUsingEncoding:NSASCIIStringEncoding]);
	std::vector<uint8_t> result;
	for(size_t i=0;i<data.size();i++){
		result.push_back((uint8_t)data[i]);
	}
	return result;
}

+(void)setUnsignedCharArray:(std::vector<unsigned char>&)data to:(id)field{
	[self setUnsignedCharArrayPointer:&data terminatedWith:@"" to:field];	
}

+(void)setUnsignedCharArrayPointer:(std::vector<unsigned char>*)data to:(id)field{
	[self setUnsignedCharArrayPointer:data terminatedWith:@"" to:field];
}

+(void)setUnsignedCharArrayPointer:(std::vector<unsigned char>*)data terminatedWith:(NSString*)termination to:(id)field{
	stringstream ss;
	for(int i=0;i<data->size();i++){
		ss << "0x" << hex << setw(2) << setfill('0') << right << (uint32_t)data->at(i);
		if(i!=data->size()){
			ss << " ";
		}
	}
	ss << [Utility toString:termination];
	string str=ss.str();
	if(str==""){
		str=" ";
	}
	[field setStringValue:[NSString stringWithUTF8String:str.c_str()]];
}

+(void)setUInt8Array:(std::vector<uint8_t>)data to:(id)field{
	[self setVectorUint8Pointer:&data terminatedWith:@"" to:field];
}

+(void)setVectorUint8:(std::vector<uint8_t>&)data to:(id)field{
	[self setVectorUint8Pointer:&data terminatedWith:@"" to:field];
}

+(void)setVectorUint8Pointer:(std::vector<uint8_t>*)data to:(id)field{
	[self setVectorUint8Pointer:data terminatedWith:@"" to:field];
}

+(void)setVectorUint8Pointer:(std::vector<uint8_t>*)data terminatedWith:(NSString*)termination to:(id)field{
	stringstream ss;
	for(int i=0;i<data->size();i++){
		ss << "0x" << hex << setw(2) << setfill('0') << right << (uint32_t)data->at(i);
		if(i!=data->size()){
			ss << " ";
		}
	}
	ss << [Utility toString:termination];
	string str=ss.str();
	if(str==""){
		str=" ";
	}
	[field setStringValue:[NSString stringWithUTF8String:str.c_str()]];
}

+(void)setVectorUint8Pointer:(std::vector<uint8_t>*)data terminatedWith:(NSString*)termination toNSTextView:(NSTextView*)field{
	stringstream ss;
	for(int i=0;i<data->size();i++){
		ss << "0x" << hex << setw(2) << setfill('0') << right << (uint32_t)data->at(i);
		if(i!=data->size()){
			ss << " ";
		}
	}
	ss << [Utility toString:termination];
	string str=ss.str();
	if(str==""){
		str=" ";
	}
	[Utility setTextToNSTextView:[NSString stringWithUTF8String:str.c_str()] to:field];
}

+(void)showDialogBox:(NSString*)message1:(NSString*)message2{
	// Display modal dialog
	NSInteger	result;
	result = NSRunAlertPanel(
							 message1, 
							 message2, 
							 @"OK", 
							 nil, 
							 nil);
	return;
}


+ (void)setTextToNSTextView:(NSString*)string to:(NSTextView*)id{
	[id selectAll:nil];
	[id delete:nil];
	[id insertText:string];
}

+(NSString*)vectorUint8ToNSString:(std::vector<uint8_t>&)data{
	using namespace std;
	stringstream ss;
	for(int i=0;i<data.size();i++){
		ss << "0x" << hex << setw(2) << setfill('0') << right << (uint32_t)data.at(i);
		if(i!=data.size()){
			ss << " ";
		}
	}
	return [Utility toNSString:ss.str()];
}
@end
