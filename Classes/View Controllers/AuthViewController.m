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

#import "AuthViewController.h"
#import "Common.h"
#import "AppDotNetSyncingEngine.h"
#import "ANSession.h"
#import "ANUser.h"
#import "FXLabel.h"
#import "AppDelegate.h"


@implementation AuthViewController
@synthesize authWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"AuthViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *redirectURI = @"https://alpha.app.net/fudge";
    NSString *scopes = @"stream write_post follow messages email";
    NSString *authURLstring = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri=%@&scope=%@&adnview=appstore", kAppDotNetClientID, redirectURI, scopes];
    NSURL *authURL = [NSURL URLWithString:[authURLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authURL];
    // remove all cached responses
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // set an empty cache
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    // remove the cache for a particular request
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [authWebView loadRequest:request];
    
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar-background.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.navigationController.navigationBar setBackgroundImage:gradientImage44
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
       
    FXLabel *navBarTitleLabel = [[FXLabel alloc]initWithFrame:CGRectMake(60, (44/2 - [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight /2 ), 200, [UIFont fontWithName:@"HelveticaNeue-Bold" size:18].lineHeight)];
    [self.navigationController.navigationBar addSubview:navBarTitleLabel];
    
    navBarTitleLabel.text = @"Authenticate";
    navBarTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    navBarTitleLabel.textColor = [UIColor colorWithRed:169/255. green:154/255. blue:186/255. alpha:1];
    navBarTitleLabel.backgroundColor = [UIColor clearColor];
    navBarTitleLabel.shadowColor = [UIColor blackColor];
    navBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    navBarTitleLabel.shadowBlur=0;
    navBarTitleLabel.shadowOffset= CGSizeMake(0, -1);
    navBarTitleLabel.gradientStartColor = [UIColor whiteColor];
    navBarTitleLabel.gradientEndColor = [UIColor clearColor];
    navBarTitleLabel.gradientStartPoint = CGPointMake(0, 0.3);
    navBarTitleLabel.gradientEndPoint = CGPointMake(0, 0.8);
    navBarTitleLabel.numberOfLines = 1;
    [navBarTitleLabel clipsToBounds];
    
    
    
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSArray *components = [[request URL].absoluteString  componentsSeparatedByString:@"#"];
    
    if([components count]) {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            
            if([[component componentsSeparatedByString:@"="] count] > 1) {
                [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
            }
        }
        
        if([parameters objectForKey:@"access_token"])
        {
            
            NSString *token = [parameters objectForKey:@"access_token"];
            
            ANSession.defaultSession.accessToken = token;
            [ANSession.defaultSession userWithID:ANMeUserID completion:^(ANResponse *response, ANUser * user, NSError * error) {
                
                ANUser *me = user;
                
                
                [[AppDotNetSyncingEngine sharedManager]loginWithUsername:[me username] AndToken:token];
                
                ANSession.defaultSession.accessToken = [[AppDotNetSyncingEngine sharedManager]token];
                [[ANSession defaultSession]userWithUsername:[[AppDotNetSyncingEngine sharedManager]username] completion:^(ANResponse *response, ANUser *user, NSError *error){
                    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lli",user.ID] forKey:@"user_id"];
                }];
                
                AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                
                [delegate callBack];
                
            }];
        }
    }
    
    return YES;
}

-(IBAction)dismissAuthenticationViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
