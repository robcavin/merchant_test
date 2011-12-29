//
//  ScanViewController.h
//  MerchantScanner
//
//  Created by Robert Cavin on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"

@interface ScanViewController : UIViewController <ZXingDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate> {
    IBOutlet UITextView *prizeText;    
    IBOutlet UIButton* scanButton;
    IBOutlet UIView* mainView;
    IBOutlet UIView* overlayView;
    IBOutlet UIImageView* prizeImage;
    IBOutlet UILabel* prizeTitle;
    IBOutlet UIImageView* backgroundImage;
    IBOutlet UIButton* problemButton;

    NSString *resultsToDisplay;
    NSMutableData* connectionData;
    BOOL resultsValid;
}

@property (strong, nonatomic) IBOutlet UITextView *prizeText;
@property (strong, nonatomic) NSString *resultsToDisplay;
@property (strong, nonatomic) NSMutableData *connectionData;
@property (strong, nonatomic) IBOutlet UIButton* scanButton;
@property (strong, nonatomic) IBOutlet UIView* mainView;
@property (strong, nonatomic) IBOutlet UIView* overlayView;
@property (strong, nonatomic) IBOutlet UIImageView* prizeImage;
@property (strong, nonatomic) IBOutlet UILabel* prizeTitle;
@property (strong, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (strong, nonatomic) IBOutlet UIButton* problemButton;
@property (strong, nonatomic) IBOutlet UILabel* waitingLabel;

@property (nonatomic, assign) BOOL resultsValid;

//- (IBAction)scanPressed:(id)sender;

@end

