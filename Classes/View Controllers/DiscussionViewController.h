//
//  DiscussionViewController.h
//  Fudge
//
//  Created by Frederic Jacobs on 29/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//
#import "AppNetStreamTableView.h"
#import "ANSession.h"

@interface DiscussionViewController : AppNetStreamTableView{
    
    ANResourceID threadID;
    ANResourceID thePostID;
    BOOL firstLoad;

}
- (id)initWithDiscussionID:(ANResourceID)discussionID AndPostID:(ANResourceID)postID;
 
@end
