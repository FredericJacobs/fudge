//
//  DiscussionTableViewCell.m
//  Fudge
//
//  Created by Frederic Jacobs on 1/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "DiscussionTableViewCell.h"

@implementation DiscussionTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    // Setting Globals that don't need to change with any cell.
    
    cellBackGroundImage.frame = CGRectMake(0, 0, 0, 0);
     
    highlightLine.frame = CGRectMake(10, 0, 300, 0.5);

    gradientOverlay.frame = self.frame;
    self.fullName.frame = CGRectMake(63, 10, 0, 0);
    
    self.username.frame = CGRectMake(63, 28, 200, 20);
    self.profilePicture.frame = CGRectMake(21, 11, 32, 32);

    self.canvas.frame = CGRectMake(19, 9, 36, 36);
    
    self.reply.frame = CGRectMake(261, 10, 39, 34);
    
    return self;
}

- (void) resizeForFrame:(CGRect)frame{
    [cellBackGroundImage setFrame:frame];
    gradientOverlay.frame = frame;
    [self.fullName sizeToFit];
    [self.username sizeToFit];
    self.time.frame = CGRectMake((63+self.username.frame.size.width +5), 27, 209-self.username.frame.size.width, 20);
}



@end
