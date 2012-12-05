//
//  DateUtil.h
//  
//
//  Created by Frederic Jacobs on 23/8/12.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString*) stringForTimeDifferenceWith:(NSDate*)date;
+ (NSString*) stringForNumberOfPosts:(NSInteger)numberOfPosts;

@end
