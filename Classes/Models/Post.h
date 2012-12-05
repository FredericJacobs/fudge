//
//  Post.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/12/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hashtag, Link, Mention, Stream, User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * height298;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * replies_count;
@property (nonatomic, retain) NSNumber * repost_count;
@property (nonatomic, retain) NSNumber * stars_count;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * thread_id;
@property (nonatomic, retain) NSSet *hashtags;
@property (nonatomic, retain) NSSet *inStream;
@property (nonatomic, retain) NSSet *links;
@property (nonatomic, retain) NSSet *mentions;
@property (nonatomic, retain) User *posted_by;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addHashtagsObject:(Hashtag *)value;
- (void)removeHashtagsObject:(Hashtag *)value;
- (void)addHashtags:(NSSet *)values;
- (void)removeHashtags:(NSSet *)values;

- (void)addInStreamObject:(Stream *)value;
- (void)removeInStreamObject:(Stream *)value;
- (void)addInStream:(NSSet *)values;
- (void)removeInStream:(NSSet *)values;

- (void)addLinksObject:(Link *)value;
- (void)removeLinksObject:(Link *)value;
- (void)addLinks:(NSSet *)values;
- (void)removeLinks:(NSSet *)values;

- (void)addMentionsObject:(Mention *)value;
- (void)removeMentionsObject:(Mention *)value;
- (void)addMentions:(NSSet *)values;
- (void)removeMentions:(NSSet *)values;

@end
