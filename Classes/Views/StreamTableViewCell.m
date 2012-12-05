//
//  StreamTableViewCell.m
//  Tapp
//
//  Created by Frederic Jacobs on 22/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import "StreamTableViewCell.h"

@implementation StreamTableViewCell
@synthesize reply,fullName, username, profilePicture, time,post,highlightLine, gradientOverlay, canvas;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Setting Globals that don't need to change with any cell.
    
        UIFont *helveticaBold14 = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        UIFont *helvetica14 = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImage *cellBackgroundImageSource = [[UIImage imageNamed:@"post-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        cellBackGroundImage = [[UIImageView alloc]initWithImage:cellBackgroundImageSource];
        cellBackGroundImage.frame = self.frame;
        cellBackGroundImage.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:cellBackGroundImage];
        
        highlightLine = [[SmoothLineView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
        
        highlightLine.lineWidth = 0.5;
        highlightLine.lineColor =  [UIColor colorWithRed:49/255. green:40/255. blue:58/255. alpha:1];
        
        [self addSubview:highlightLine];
            
        gradientOverlay = [CAGradientLayer layer];
        
        gradientOverlay.colors = [NSArray arrayWithObjects: (id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor, nil];
        
        gradientOverlay.frame = self.frame;
        
        //set its opacity from 0 ~ 1
        gradientOverlay.opacity = 0.075;
        //add it as sublayer of self.layer (it will be over the layer with the background image
        [self.layer addSublayer:gradientOverlay];
        
        UIColor *shadowColor = [UIColor colorWithRed:23/255. green:15/255. blue:28/255. alpha:1];
        // Setting the placeholders for the rest of the content
        
        self.fullName = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fullName.frame = CGRectMake(53, 10, 0, 0);
        
        [self.fullName setTitleColor:[UIColor colorWithRed:207/255. green:197/255. blue:218/255. alpha:1] forState:UIControlStateNormal];
        self.fullName.titleLabel.font = helveticaBold14;
        
        [self addSubview:self.fullName];
        
        [[self.fullName layer] setShadowOffset:CGSizeMake(0, -1)];
        [[self.fullName layer] setShadowColor:[shadowColor CGColor]];
        [[self.fullName layer] setShadowOpacity:1];
        [[self.fullName layer] setShadowRadius:0];
        
        self.username = [UIButton buttonWithType:UIButtonTypeCustom];
        self.username.frame = CGRectMake(53, 28, 200, 20);
        [self.username setTitleColor:[UIColor colorWithRed:126/255. green:81/255. blue:174/255. alpha:1] forState:UIControlStateNormal];
        self.username.titleLabel.font = helvetica14;
        
        [self addSubview:self.username];
        
        [[self.username layer] setShadowOffset:CGSizeMake(0, -1)];
        [[self.username layer] setShadowColor:[shadowColor CGColor]];
        [[self.username layer] setShadowOpacity:1];
        [[self.username layer] setShadowRadius:0];
        
        self.time = [[UILabel alloc] init];
        self.time.textColor = [UIColor colorWithRed:95/255. green:51/255. blue:142/255. alpha:1];
        self.time.font = helvetica14;
        self.time.backgroundColor = [UIColor clearColor];
        
        [[self.time layer] setShadowOffset:CGSizeMake(0, -1)];
        [[self.time layer] setShadowColor:[shadowColor CGColor]];
        [[self.time layer] setShadowOpacity:1];
        [[self.time layer] setShadowRadius:0];
        
        [self addSubview:self.time];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 32, 32)];
        self.profilePicture.clipsToBounds = YES;
        
        self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
        self.profilePicture.layer.cornerRadius = 2;
        
        self.canvas = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"avatar-overlay-32.png"]];
        self.canvas.frame = CGRectMake(9, 9, 36, 36);
        
        [self addSubview:self.profilePicture];
        [self addSubview:self.canvas];
            
        self.reply = [UIButton buttonWithType:UIButtonTypeCustom];
        self.reply.frame = CGRectMake(self.frame.size.width - 49, 10, 39, 34);
        [self.reply setImage:[UIImage imageNamed:@"post-reply-default.png"] forState:UIControlStateNormal];
        [self.reply setImage:[UIImage imageNamed:@"post-reply-active.png"] forState:UIControlStateSelected];
        [self.reply setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.reply];
        
    }
    return self;
}

- (void) resizeForFrame:(CGRect)frame{
    [cellBackGroundImage setFrame:frame];
    gradientOverlay.frame = frame;
    [self.fullName sizeToFit];
    [self.username sizeToFit];
    self.time.frame = CGRectMake((53+self.username.frame.size.width +5), 27, 209-self.username.frame.size.width, 20);
}

- (void) resizeForDiscussionViewFrame:(CGRect)frame {
    
    highlightLine.frame = CGRectMake(0, frame.origin.y, 320, 0.5);
    self.fullName.frame = CGRectMake(53, frame.origin.y+10, 0, 0);
    
    self.username.frame = CGRectMake(53, frame.origin.y+ 28, 200, 20);
    self.profilePicture.frame = CGRectMake(11, frame.origin.y+11, 32, 32);
    
    self.canvas.frame = CGRectMake(9, frame.origin.y + 9, 36, 36);
    
    self.reply.frame = CGRectMake(self.frame.size.width - 49, 10, 39, 34);
    
    [cellBackGroundImage setFrame:frame];
    gradientOverlay.frame = frame;
    [self.fullName sizeToFit];
    [self.username sizeToFit];
    self.time.frame = CGRectMake((63+self.username.frame.size.width +5), frame.origin.y
                                 +27, 209-self.username.frame.size.width, 20);
    
}


@end
