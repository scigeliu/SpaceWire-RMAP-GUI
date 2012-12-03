//
//  Utility.h
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/26.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <string>
#include <vector>

@interface Utility : NSObject{

}

+(std::string)toString:(NSString*)string;
+(NSString*)toNSString:(std::string)string;
+(int)toInt:(id)object;

+(unsigned char)toUnsignedChar:(id)inputfield;
+(uint8_t)toUInt8:(id)inputfield;
+(uint16_t)toUInt16:(id)inputfield;
+(uint32_t)toUInt32:(id)inputfield;
+(void)setUnsignedChar:(unsigned char)data to:(id)field;
+(void)setUInt8:(uint8_t)data to:(id)field;
+(void)setInteger:(int)data to:(id)field;
+(std::vector<unsigned char>)toUnsignedCharArray:(id)inputfield;
+(std::vector<uint8_t>)toUInt8Array:(id)inputfield;
+(std::vector<uint8_t>)toUInt8ArrayFromTextView:(id)inputfield;
+(void)setUnsignedCharArray:(std::vector<unsigned char>&)data to:(id)field;
+(void)setUnsignedCharArrayPointer:(std::vector<unsigned char>*)data to:(id)field;
+(void)setUnsignedCharArrayPointer:(std::vector<unsigned char>*)data terminatedWith:(NSString*)termination to:(id)field;
+(void)setUInt8Array:(std::vector<uint8_t>)data to:(id)field;
+(void)showDialogBox:(NSString*)message1:(NSString*)message2;
+(void)setVectorUint8Pointer:(std::vector<uint8_t>*)data terminatedWith:(NSString*)termination toNSTextView:(NSTextView*)field;
+(void)setVectorUint8:(std::vector<uint8_t>&)data to:(id)field;
+(void)setVectorUint8Pointer:(std::vector<uint8_t>*)data to:(id)field;
+(void)setVectorUint8Pointer:(std::vector<uint8_t>*)data terminatedWith:(NSString*)termination to:(id)field;

+(void)setTextToNSTextView:(NSString*)string to:(NSTextView*)id;
+(NSString*)vectorUint8ToNSString:(std::vector<uint8_t>&)data;

+(NSString*)integerToNSString:(int)value;

+(NSString*)doubleToNSString:(int)value;

@end

