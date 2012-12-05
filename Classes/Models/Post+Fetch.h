//
//  Post+Fetch.h
//  Fudge
//
//  Created by Frederic Jacobs on 7/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "Post.h"

@interface Post (Fetch)

+ (Post *)postWithAppNetInfo:(ANPost *)postInfo
      inManagedObjectContext:(NSManagedObjectContext *)context
                    inStream:(Stream*)stream;
@end
