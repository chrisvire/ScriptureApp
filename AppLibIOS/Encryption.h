//
//  Encryption.h
//  ScriptureApp
//
//  Created by David Moore on 5/15/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryption : NSObject
@property (strong, nonatomic) NSString *key;
//- (instancetype)initWithNSString:(NSString *)key;
- (NSString *)decrypt:(NSString *)encryptedText;
- (NSString *)encrypt:(NSString *)data;
@end
