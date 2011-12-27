//
//  QMTextView.h
//  MerchantScanner
//
//  Created by Robert Cavin on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMTextView : UIImageView {
@private
    UITextView* textView;
}
@property (strong,nonatomic) UITextView* textView;
@end
