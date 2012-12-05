//
//  Post+ReplyToUsernames.h
//  Fudge
//
//  Created by Frederic Jacobs on 9/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "Post.h"

@interface Post (ReplyToUsernames)

- (NSString*) mentionsStrings ;

@end
