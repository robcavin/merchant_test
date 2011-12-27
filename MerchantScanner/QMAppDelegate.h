//
//  QMAppDelegate.h
//  MerchantScanner
//
//  Created by Robert Cavin on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanViewController.h"

@interface QMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ScanViewController *controller;

@end
