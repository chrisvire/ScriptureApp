//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/david/Source/GitHub/app-builders/source/common/app-lib-common/src/org/sil/app/lib/common/c/c.java
//

#ifndef _ALCc_H_
#define _ALCc_H_

#include "J2ObjC_header.h"

@class IOSByteArray;

@interface ALCc : NSObject

#pragma mark Public

- (instancetype)init;
+ (NSString *)deobfuscateWithNSString:(NSString *)obfuscatedText;
+ (NSString *)obfuscateWithNSString:(NSString *)clearText;
@end

J2OBJC_EMPTY_STATIC_INIT(ALCc)

FOUNDATION_EXPORT void ALCc_obfuscateWithByteArray_withInt_(IOSByteArray *data, jint length);

FOUNDATION_EXPORT void ALCc_deobfuscateWithByteArray_withInt_(IOSByteArray *data, jint length);

FOUNDATION_EXPORT void ALCc_init(ALCc *self);

FOUNDATION_EXPORT ALCc *new_ALCc_init() NS_RETURNS_RETAINED;

J2OBJC_TYPE_LITERAL_HEADER(ALCc)

typedef ALCc OrgSilAppLibCommonCC;

#endif // _ALCc_H_
