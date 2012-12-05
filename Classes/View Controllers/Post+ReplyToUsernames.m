//
//  Post+ReplyToUsernames.m
//  Fudge
//
//  Created by Frederic Jacobs on 9/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "Post+ReplyToUsernames.h"
#import "User.h"
#import "AppDotNetSyncingEngine.h"
#import "Mention.h"

@implementation Post (ReplyToUsernames)

- (NSString*) mentionsStrings{
    
    NSMutableArray *usernames = [NSMutableArray array];
    
    NSLog(@"Array %@", usernames);
    
    [usernames addObject:self.posted_by.username];

    for (Mention *mention in self.mentions.objectEnumerator.allObjects) {
        NSString *substring = [self.text substringWithRange:NSMakeRange([mention.location unsignedIntValue], [mention.length unsignedIntValue])];
        [usernames addObject:[substring substringWithRange:NSMakeRange(1, substring.length-1)]];
    }
    
    
    NSString *mentions = @"";

    for (int i=0; i < [usernames count]; i++){
        
        NSString *string = [usernames objectAtIndex:i];
        
        if ([string isEqualToString:[[AppDotNetSyncingEngine sharedManager]username]]){
            [usernames removeObject:string];
            i -- ;
        }
    }

    for (NSString *string in usernames){
        mentions = [mentions stringByAppendingString:[NSString stringWithFormat:@"@%@ ", string]];
    }
    
    return mentions;

}

@end
