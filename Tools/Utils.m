//
//  DateUtil.m
//  
//
//  Created by Frederic Jacobs on 23/8/12.
//
//

#import "Utils.h"

@implementation Utils


+ (NSString*) stringForNumberOfPosts:(NSInteger)numberOfPosts{
    
    if (numberOfPosts < 0) {
        return @"";
    }
    if (numberOfPosts < 1000) {
        return [NSString stringWithFormat:@"%i",numberOfPosts];
    }
    if (numberOfPosts < 1000000) {
        return [NSString stringWithFormat:@"%ik",(int)numberOfPosts/1000];
    }
    
    if (numberOfPosts < 1000000000){
        return [NSString stringWithFormat:@"%iM",(int)numberOfPosts/1000000];
    }
    
    if (numberOfPosts < 1000000000000) {
        return [NSString stringWithFormat:@"%iB",(int)numberOfPosts/1000000000];
    }
    
    if (numberOfPosts < 1000000000000000) {
        return [NSString stringWithFormat:@"%lliT",(int)numberOfPosts/1000000000000];
    }

return @"NaN";
    
}

+ (NSString*) stringForTimeDifferenceWith:(NSDate*)date{
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval delta = [now timeIntervalSinceDate:date];
    //seconds
    NSString *prettyTimestamp;
    
    if (delta < 60) {
        prettyTimestamp = @"Less than a minute ago";
    } else if (delta < 120) {
        prettyTimestamp = @"one minute ago";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%d minutes ago", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"one hour ago";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%d hours ago", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {
        prettyTimestamp = @"one day ago";
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%d days ago", (int) floor(delta/86400.0) ];
    } else if (delta < ( 86400 * 7 * 2 ) ) {
            prettyTimestamp = [NSString stringWithFormat:@"one week ago"];
    } else if(delta < ( 86400 *30 )){
        prettyTimestamp = [NSString stringWithFormat:@"%d weeks ago", (int) floor(delta/(86400.0*7))];
    } else if(delta < ( 86400 *30 *2)){
        prettyTimestamp = [NSString stringWithFormat:@"one month ago" ];
    } else if(delta < ( 31556900)){
        prettyTimestamp = [NSString stringWithFormat:@"%d months ago", (int) floor(delta/(86400.0*7*30))];
    } else if(delta < ( 31556900*2)){
        prettyTimestamp = [NSString stringWithFormat:@"one year ago"];
    } else {
        prettyTimestamp = [NSString stringWithFormat:@"%d years ago", (int) floor(delta/(31556900.0))];
    }
        
    return prettyTimestamp;

}

@end
