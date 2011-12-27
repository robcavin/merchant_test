//
//  QMOverlayView.m
//  MerchantScanner
//
//  Created by Robert Cavin on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "QMOverlayView.h"

@implementation QMOverlayView
@synthesize cropRect;

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        self.image = [UIImage imageNamed:@"scan_bg.PNG"];
        self.cropRect = CGRectMake(28, 108, 264, 264);
    }
    return self;
}

- (void)setPoint:(CGPoint)point {
    
}

- (void) setPoints:(NSMutableArray*)pnts {
    
}

@end
