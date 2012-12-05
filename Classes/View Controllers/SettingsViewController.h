//
//  SettingsViewController.h
//  Fudge
//
//  Created by Frederic Jacobs on 2/9/12.
//  Copyright (c) 2012 Frederic Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudEngine.h"

@interface SettingsViewController : UIViewController <UITextFieldDelegate, CloudAppLoginDelegate>{
    
    UIButton *cloudAppButton;
    
}


@end
