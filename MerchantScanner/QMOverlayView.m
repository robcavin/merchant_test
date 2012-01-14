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
@synthesize animationView;
@synthesize instructions;

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];

    if (self) {

        // Determine if we are on a device that scales images before display (i.e. iphone4)
        CGFloat scale = [[UIScreen mainScreen] scale];

        // Set up static background image
        UIImage* scanBGImage = [UIImage imageNamed:@"scanner.png"];  // Automagically chooses 2x res version if needed
        NSString* scanBGPlist = (scale > 1) ? @"scanner-hd" : @"scanner"; 
        NSMutableDictionary* bgImageSizes = [[NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:scanBGPlist ofType:@"plist"]] objectForKey:@"frames"];
        [bgImageSizes removeObjectForKey:@"splash_bkgrd.png"];
        [bgImageSizes removeObjectForKey:@"logo_light.png"];
        
        // Create a canvas the size of the current screen and draw the sub images into it
        UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width*scale, self.bounds.size.height*scale));
        for (NSString* imageName in [bgImageSizes allKeys]) {
            CGSize sourceSize = CGSizeFromString([[bgImageSizes objectForKey:imageName] objectForKey:@"spriteSourceSize"]);
            CGRect textRect = CGRectFromString([[bgImageSizes objectForKey:imageName] valueForKey:@"textureRect"]);
            CGRect spriteRect = CGRectFromString([[bgImageSizes objectForKey:imageName] valueForKey:@"spriteColorRect"]);
            int x_offset = (sourceSize.width - self.bounds.size.width*scale)/2; // 
            int y_offset = (sourceSize.height - self.bounds.size.height*scale)/2;
            spriteRect.origin.x -= x_offset;
            spriteRect.origin.y -= y_offset;
            if ([imageName isEqualToString:@"logo.png"]) {
                spriteRect.origin.y -= 185 * scale;
            }
            
            UIImage* sprite = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([scanBGImage CGImage],textRect)];
            [sprite drawInRect:spriteRect];
        }
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        

        // Set up overlay animation
        UIImage* srcImage = [UIImage imageNamed:@"scanning.png"];
        NSString* srcPlist = (scale > 1) ? @"scanning-hd" : @"scanning"; 
        NSDictionary* imageSizes = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:srcPlist ofType:@"plist"]] objectForKey:@"frames"];
        NSMutableArray* animationImages = [NSMutableArray arrayWithCapacity:[[imageSizes allKeys] count]];

        // For the animation, we split the source image into a collection of sprite images, each the full screen size
        for (NSString* imageName in [imageSizes allKeys]) {
            CGSize sourceSize = CGSizeFromString([[imageSizes objectForKey:imageName] objectForKey:@"spriteSourceSize"]);
            CGRect textRect = CGRectFromString([[imageSizes objectForKey:imageName] valueForKey:@"textureRect"]);
            CGRect spriteRect = CGRectFromString([[imageSizes objectForKey:imageName] valueForKey:@"spriteColorRect"]);
            int x_offset = (sourceSize.width - self.bounds.size.width*scale)/2;
            int y_offset = (sourceSize.height - self.bounds.size.height*scale)/2;
            spriteRect.origin.x -= x_offset;
            spriteRect.origin.y -= y_offset - (0.5*scale); // Seems like the center is 1px off.  Crappy hardcoded adjustment            
            UIImage* sprite = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([srcImage CGImage],textRect)];
            UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width*scale, self.bounds.size.height*scale));
            [sprite drawInRect:spriteRect];
            [animationImages addObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
        
        // Set up the animation overlay
        self.animationView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:animationView];
        self.animationView.animationDuration = 1.1;
        self.animationView.animationImages = animationImages;
        [self.animationView startAnimating];
        
        
        // Set up instructions on the bottom
        self.instructions = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        [self addSubview:instructions];
        instructions.center = CGPointMake(160, 450);
        instructions.textAlignment = UITextAlignmentCenter;
        instructions.backgroundColor = [UIColor clearColor];
        instructions.textColor = [UIColor whiteColor];
        instructions.numberOfLines = 2;
        instructions.text = @"Scan a Qurious Redemption Code";
        
        // The crop rect is used to limit the screen space the QR code scanner scans.  This is roughly a square around the scanner circle
        self.cropRect = CGRectMake(28, 108, 264, 264);
    }

    return self;
}

// The funcitons below are called by the ZXing widget.  The built in overlay adds squares over the alignment pattern, 
//  but this is pretty lame in practice.  We just don't do anything here
- (void)setPoint:(CGPoint)point {
}

- (void) setPoints:(NSMutableArray*)pnts {
}

@end
