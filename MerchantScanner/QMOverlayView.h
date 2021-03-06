//
//  QMOverlayView.h
//  MerchantScanner
//
//  Created by Robert Cavin on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMOverlayView : UIImageView {
    CGRect cropRect;
    UIImageView* animationView;
    UILabel* instructions;
}

@property (nonatomic, assign) CGRect cropRect;
@property (strong, nonatomic) UIImageView* animationView;
@property (strong, nonatomic) UILabel* instructions;

- (id)initWithFrame:(CGRect)theFrame;
- (void)setPoint:(CGPoint)point;
- (void) setPoints:(NSMutableArray*)pnts;

@end

