//
//  ScanWebRootViewController.h
//  MerchantScanner
//
//  Created by Robert Cavin on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"

@interface ScanWebRootViewController : UIViewController  <ZXingDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate,UIWebViewDelegate> {
        
    BOOL resultsValid;              // Indicates the scan result is valid, so don't toss the scanner back over the view
}

@property (strong, nonatomic) IBOutlet UIWebView* webView;
@property (strong, nonatomic) IBOutlet UIView* mainView;
@property (strong, nonatomic) UIView* overlayView;
@property (strong, nonatomic) IBOutlet UILabel* waitingLabel;
@property (nonatomic, assign) BOOL resultsValid;

- (IBAction)scanButtonPressed:(id)sender;
@end
