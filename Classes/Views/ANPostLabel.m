/*
 Copyright (c) 2012 T. Chroma, M. Herzog, N. Pannuto, J.Pittman, R. Rottmann, B. Sneed, V. Speelman
 The AppApp source code is distributed under the The MIT License (MIT) license.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 Any end-user product or application build based on this code, must include the following acknowledgment:
 
 "This product includes software developed by the original AppApp team and its contributors", in the software
 itself, including a link to www.app-app.net.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
*/

#import "ANPostLabel.h"
#import "ANPostLinkButton.h"
#import "NSDictionary+SDExtensions.h"
#import "Hashtag.h"
#import "Mention.h"
#import "Link.h"


@implementation ANPostLabel

- (id)initWithAttributedString:(NSAttributedString*)string width:(CGFloat) aFloat
{
    if ((self = [super initWithAttributedString:string width:aFloat]) != NULL)
    {
        self.delegate = self;
        _enableLinks = YES;
        self.backgroundColor = [UIColor clearColor];
        self.drawDebugFrames = FALSE;
        self.userInteractionEnabled = YES;
        self.shouldDrawLinks=FALSE;
        
        
        
    }
    return(self);
}

- (void)setEnableLinks:(BOOL)enableLinks
{
    if (enableLinks == _enableLinks)
        return;
    
    _enableLinks = enableLinks;
    [self relayoutText];
}

- (void)executeTapHandler:(id)sender
{
    ANPostLinkButton *button = (ANPostLinkButton *)sender;
    _tapHandler(button.type, button.value);
}

- (void)executeLongPressHandler:(UILongPressGestureRecognizer *)longPressRecognizer
{
    if(longPressRecognizer.state == UIGestureRecognizerStateBegan)
    {
        ANPostLinkButton *button = (ANPostLinkButton *)longPressRecognizer.view;
        _longPressHandler(button.type, button.value);
    }
}


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame;
{
    if (!_enableLinks)
        return nil;
    
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];

    ANPostLinkButton *button = [[ANPostLinkButton alloc] initWithFrame:frame];
    button.minimumHitSize = CGSizeMake(22, 22);
    button.type = [attributes objectForKey:@"ANPostLabelAttributeType"];
    button.value = [attributes objectForKey:@"ANPostLabelAttributeValue"];
    button.attributedString = string;
    button.enabled = YES;
    button.userInteractionEnabled = YES;
    button.showsTouchWhenHighlighted = FALSE;
    button.GUID = identifier;

    
    NSMutableAttributedString *highlightedString = [string mutableCopy];
    
	NSRange range = NSMakeRange(0, highlightedString.length);
    
	NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:(__bridge id)[UIColor whiteColor].CGColor forKey:(id)kCTForegroundColorAttributeName];
    
    
	[highlightedString addAttributes:highlightedAttributes range:range];
    
	button.highlightedAttributedString = highlightedString;
    
    
    [button addTarget:self action:@selector(executeTapHandler:) forControlEvents:UIControlEventTouchUpInside];
           
    return button;
}

+ (void)addHashtags:(NSArray*)hashtags toString:(NSMutableAttributedString*)string{
    
    for (Hashtag *hashtag in hashtags)
    {
        
        NSUInteger pos = [[hashtag location]unsignedIntegerValue];
        NSUInteger len = [[hashtag length] unsignedIntegerValue];
        NSString *keyValue = [hashtag tag];
        NSRange range = { .location = pos, .length = len };
        NSString *type = @"hashtag";
        
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (__bridge id)[UIColor colorWithRed:102/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor, (__bridge NSString *)kCTForegroundColorAttributeName,
                                       (__bridge id)CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL),(__bridge NSString *)kCTFontAttributeName,
                                       type, @"ANPostLabelAttributeType",
                                       keyValue, @"ANPostLabelAttributeValue",
                                       [NSString guid], DTGUIDAttribute,
                                       keyValue, DTLinkAttribute,
                                       NULL];
        
        if (!(string.length < range.length + range.location)) {
            [string setAttributes:theAttributes range:range];
        }
    }
    
}

+ (void)addLinks:(NSArray*)links toString:(NSMutableAttributedString*)string{
    
    for (Link *link in links)
    {
        
        NSUInteger pos = [[link location]unsignedIntegerValue];
        NSUInteger len = [[link length] unsignedIntegerValue];
        NSString *keyValue = [link link];
        NSRange range = { .location = pos, .length = len };
        NSString *type = @"link";
        
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (__bridge id)[UIColor colorWithRed:102/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor, (__bridge NSString *)kCTForegroundColorAttributeName,
                                       (__bridge id)CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL),(__bridge NSString *)kCTFontAttributeName,
                                       type, @"ANPostLabelAttributeType",
                                       keyValue, @"ANPostLabelAttributeValue",
                                       [NSString guid], DTGUIDAttribute,
                                       keyValue, DTLinkAttribute,
                                       NULL];
        
        if (!(string.length < range.length + range.location)) {
            [string setAttributes:theAttributes range:range];
        }
    }
    
}

+ (void)addMentions:(NSArray*)mentions toString:(NSMutableAttributedString*)string{
    
    for (Mention *mention in mentions)
    {
        
        NSUInteger pos = [[mention location]unsignedIntegerValue];
        NSUInteger len = [[mention length] unsignedIntegerValue];
        NSString *keyValue = [[mention id]stringValue];
        NSRange range = { .location = pos, .length = len };
        NSString *type = @"name";
        
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (__bridge id)[UIColor colorWithRed:102/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor, (__bridge NSString *)kCTForegroundColorAttributeName,
                                       (__bridge id)CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL),(__bridge NSString *)kCTFontAttributeName,
                                       type, @"ANPostLabelAttributeType",
                                       keyValue, @"ANPostLabelAttributeValue",
                                       [NSString guid], DTGUIDAttribute,
                                       keyValue, DTLinkAttribute,
                                       NULL];
        
        if (!(string.length < range.length + range.location)) {
            [string setAttributes:theAttributes range:range];
        }
    }
    
}

+ (NSAttributedString*) attributedStringForPostData:(Post*) aPost{
    
    NSMutableString *text = [[aPost text] mutableCopy];
    if (!text || [text length] == 0)
        text = [@"[deleted post]" mutableCopy];
    
	NSMutableAttributedString *postString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray *hashtags = aPost.hashtags.objectEnumerator.allObjects;
    NSArray *links = aPost.links.objectEnumerator.allObjects;
    NSArray *mentions = aPost.mentions.allObjects.objectEnumerator.allObjects;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [postString addAttribute:(NSString*)kCTFontAttributeName
                       value:(__bridge id)ctFont
                       range:NSMakeRange(0, postString.length)];
    CFRelease(ctFont);
    
    
    [postString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)[UIColor colorWithRed:169/255. green:154/255. blue:186/255. alpha:1].CGColor
                       range:NSMakeRange(0, postString.length)];
    
    [ANPostLabel addHashtags:hashtags toString:postString];
    [ANPostLabel addLinks:links toString:postString];
    [ANPostLabel addMentions:mentions toString:postString];
    
    return postString;

    
}


@end
