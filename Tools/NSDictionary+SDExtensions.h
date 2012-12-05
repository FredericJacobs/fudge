//
//  NSDictionary+SDExtensions.h
//  SetDirection
//
//  Created by Brandon Sneed on 6/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSDictionary_SDExtensions)

// values
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)intForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSUInteger)unsignedIntForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (long long)longLongForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSArray*)arrayForKey:(NSString *)key;
- (BOOL)keyExists:(NSString *)key;

// keypath values
- (NSString *)stringForKeyPath:(NSString *)key;
- (NSInteger)intForKeyPath:(NSString *)key;
- (NSInteger)integerForKeyPath:(NSString *)key;
- (NSUInteger)unsignedIntForKeyPath:(NSString *)key;
- (NSUInteger)unsignedIntegerForKeyPath:(NSString *)key;
- (float)floatForKeyPath:(NSString *)key;
- (double)doubleForKeyPath:(NSString *)key;
- (long long)longLongForKeyPath:(NSString *)key;
- (BOOL)boolForKeyPath:(NSString *)key;
- (NSArray*)arrayForKeyPath:(NSString *)key;

@end
