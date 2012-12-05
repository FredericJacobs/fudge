//
//  Post+Fetch.m
//  Fudge
//
//  Created by Frederic Jacobs on 7/10/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "Post+Fetch.h"
#import "User.h"
#import "Hashtag.h"
#import "Mention.h"
#import "Link.h"
#import "ANEntity.h"
#import "Stream.h"
#import "ANPostLabel.h"
#import "AppDelegate.h"

@implementation Post (Fetch)

+ (Post *)postWithAppNetInfo:(ANPost *)postInfo
      inManagedObjectContext:(NSManagedObjectContext *)context inStream:(Stream*)stream{
    
    Post *post = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    NSNumber *idNumber = [[NSNumber alloc]initWithInt:postInfo.ID];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", idNumber];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        post = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
        post.id = idNumber;
        post.created_at = postInfo.createdAt;
        post.replies_count = [NSNumber numberWithLongLong:postInfo.numberOfReplies];
        post.repost_count = [NSNumber numberWithLongLong:postInfo.numberOfReposts];
        post.stars_count = [NSNumber numberWithLongLong:postInfo.numberOfStars];
        post.text = postInfo.text;
        post.thread_id = [NSNumber numberWithLongLong:postInfo.threadID];
        
        [self setHeightForPost:post];
        
        [post addInStreamObject:stream];
        
        
        // Adding entities
        
        for (ANEntity *hashtag in postInfo.entities.tags) {
            
            Hashtag *aHashtag = [NSEntityDescription insertNewObjectForEntityForName:@"Hashtag" inManagedObjectContext:context];
            
            aHashtag.length = [NSNumber numberWithInt:hashtag.range.length];
            aHashtag.location = [NSNumber numberWithInt:hashtag.range.location];
            aHashtag.tag = hashtag.name;
            aHashtag.inPost = post;
            
        }
        
        for (ANEntity *mention in postInfo.entities.mentions) {
            
            Mention *aMention =  [NSEntityDescription insertNewObjectForEntityForName:@"Mention" inManagedObjectContext:context];
            aMention.length = [NSNumber numberWithInt:mention.range.length];
            aMention.location = [NSNumber numberWithInt:mention.range.location];
            aMention.id = [NSNumber numberWithInt:mention.userID];
            aMention.inPost = post;

        }
        
        for (ANEntity *link in postInfo.entities.links) {
            
            Link *aLink = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:context];
            aLink.length = [NSNumber numberWithInt:link.range.length];
            aLink.location = [NSNumber numberWithInt:link.range.location];
            aLink.link = [link.URL absoluteString];
            aLink.inPost = post;
        }
        
        // Completing informations about the author
        
        NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        NSNumber *idNumber = [[NSNumber alloc]initWithInt:postInfo.user.ID];
        userRequest.predicate = [NSPredicate predicateWithFormat:@"userID = %@", idNumber];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userID" ascending:YES];
        
        userRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:userRequest error:&error];
        
        // Two possible outcomes, user already exists in the database, or doesn't
        
        if ([matches count] == 1) {
            
            User *user = nil;
            
            user = [matches objectAtIndex:0];
            user.bio = postInfo.user.userDescription.text;
            user.fullname = postInfo.user.name;
            user.follower_count = [NSNumber numberWithInt:postInfo.user.counts.followers];
            user.following_count = [NSNumber numberWithInt:postInfo.user.counts.following];
            user.followingHim = [NSNumber numberWithBool:postInfo.user.youFollow];
            user.followsMe = [NSNumber numberWithBool:postInfo.user.followsYou];
            user.username = postInfo.user.username;
            user.joined_date = postInfo.user.createdAt;
            user.muted = [NSNumber numberWithBool:postInfo.user.youMuted];
            user.posts_count = [NSNumber numberWithInt:postInfo.user.counts.posts];
            user.coverPictureURL = [postInfo.user.coverImage.URL absoluteString];
            user.profilePictureURL = [postInfo.user.avatarImage.URL absoluteString];
            post.posted_by = user;
            
        }
        else if ([matches count] == 0){
            
            // if he doesn't we fill everything in
            NSLog(@"No match, creating user");
            User *user = nil;
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            user.fullname = postInfo.user.name;
            user.userID = [NSNumber numberWithInt:postInfo.user.ID];
            user.bio = postInfo.user.userDescription.text;
            user.follower_count = [NSNumber numberWithInt:postInfo.user.counts.followers];
            user.following_count = [NSNumber numberWithInt:postInfo.user.counts.following];
            user.followingHim = [NSNumber numberWithBool:postInfo.user.youFollow];
            user.followsMe = [NSNumber numberWithBool:postInfo.user.followsYou];
            user.username = postInfo.user.username;
            user.joined_date = postInfo.user.createdAt;
            user.muted = [NSNumber numberWithBool:postInfo.user.youMuted];
            user.posts_count = [NSNumber numberWithInt:postInfo.user.counts.posts];
            user.coverPictureURL = [postInfo.user.coverImage.URL absoluteString];
            user.profilePictureURL = [postInfo.user.avatarImage.URL absoluteString];
            post.posted_by = user;
            
        }
        
        else{
            
            NSLog(@"Duplicate Users : Shouldn't happen");
        }
        
        
        // Missing users, links, mentions and hashtags
        
    }
    else {
        post = [matches lastObject];
        
        post.replies_count = [NSNumber numberWithLongLong:postInfo.numberOfReplies];
        post.repost_count = [NSNumber numberWithLongLong:postInfo.numberOfReposts];
        post.stars_count = [NSNumber numberWithLongLong:postInfo.numberOfStars];

        
        for (Stream *aStream in post.inStream.objectEnumerator.allObjects) {
    
            if ([stream.identifier isEqualToString:aStream.identifier ] && [stream.type isEqualToString:aStream.type]) {
                // Already set stream
            }
            
            else {
                [post addInStreamObject:stream];
            }   
    
        }
        
        //should update post with post info
    }
    
    return post;
}

+ (void) setHeightForPost:(Post*)post {
    
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:[ANPostLabel attributedStringForPostData:post] width:298];
    
    AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    contentView.frame = CGRectMake(-300, 0, 298, 100);
    
    [myAppDelegate.theRootViewController.view addSubview:contentView];
    
    [contentView relayoutText];
    
    CGFloat height = contentView.frame.size.height;
    
    [contentView removeFromSuperview];
    
    post.height298 = [NSNumber numberWithFloat:height];
    
}


@end
