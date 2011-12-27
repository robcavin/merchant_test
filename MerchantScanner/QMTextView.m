//
//  QMTextView.m
//  MerchantScanner
//
//  Created by Robert Cavin on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "QMTextView.h"

@implementation QMTextView
@synthesize textView;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    //- (id) initWithFrame:(CGRect)frame {
    //    self = [super initWithFrame:frame];
    self.image = [[UIImage imageNamed:@"frosted_glass_stretchable_12x18.PNG"] stretchableImageWithLeftCapWidth:6 topCapHeight:9];
    self.textView = [[UITextView alloc] initWithFrame:self.bounds];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor whiteColor];
    self.textView.text = @"Lorem ipsum salty tarts";
    [self addSubview:textView];
    return self;
}

@end

