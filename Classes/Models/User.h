//
//  User.h
//  Fudge
//
//  Created by Frederic Jacobs on 5/12/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * coverPictureURL;
@property (nonatomic, retain) NSNumber * follower_count;
@property (nonatomic, retain) NSNumber * following_count;
@property (nonatomic, retain) NSNumber * followingHim;
@property (nonatomic, retain) NSNumber * followsMe;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSDate * joined_date;
@property (nonatomic, retain) NSNumber * muted;
@property (nonatomic, retain) NSNumber * posts_count;
@property (nonatomic, retain) NSString * profilePictureURL;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *author;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAuthorObject:(Post *)value;
- (void)removeAuthorObject:(Post *)value;
- (void)addAuthor:(NSSet *)values;
- (void)removeAuthor:(NSSet *)values;

@end
