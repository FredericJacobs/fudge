//
//  StreamTableViewCell.h
//  Tapp
//
//  Created by Frederic Jacobs on 22/8/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANPostLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "SmoothLineView.h"

@interface StreamTableViewCell : UITableViewCell{
    UIButton *fullName;
    UIButton *username;
    UILabel *time;
    ANPostLabel *post;
    UIButton *reply;
    UIImageView *profilePicture;
    UIImageView *cellBackGroundImage;
    CAGradientLayer *gradientOverlay ;
    SmoothLineView *highlightLine;
    UIImageView *canvas;
}
- (void) resizeForFrame:(CGRect)frame;
- (void) resizeForDiscussionViewFrame:(CGRect)frame;

@property (nonatomic,retain) UIButton *fullName;
@property (nonatomic,retain) UIImageView *canvas;
@property (nonatomic,retain) UIButton *username;
@property (nonatomic,retain) UILabel *time;
@property (nonatomic,retain) ANPostLabel *post;
@property (nonatomic,retain) UIButton *reply;
@property (nonatomic,retain) UIImageView *profilePicture;
@property (nonatomic,retain) SmoothLineView *highlightLine;
@property (nonatomic,retain) CAGradientLayer *gradientOverlay ;


@end
