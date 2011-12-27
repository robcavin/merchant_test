//
//  ScanViewController.m
//  MerchantScanner
//
//  Created by Robert Cavin on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScanViewController.h"
#import "QRCodeReader.h"
#import "QMOverlayView.h"
#import "SBJson.h"

#define SERVER_URL_STRING @"http://stage.qurious.mobi/api"


@implementation ScanViewController
@synthesize prizeText;
@synthesize prizeTitle;
@synthesize prizeImage;

@synthesize overlayView;
@synthesize mainView;

@synthesize resultsToDisplay;
@synthesize connectionData;
@synthesize scanButton;
@synthesize backgroundImage;
@synthesize problemButton;

@synthesize resultsValid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.resultsToDisplay= @"This is a test";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.resultsToDisplay= @"This is a test";
        self.resultsValid = FALSE;

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(willEnterFG) 
                                                     name:@"willEnterFG" 
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(enteredBG) 
                                                     name:@"enteredBG" 
                                                   object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [prizeText setText:resultsToDisplay];
    UIImage* frostedGlass = [UIImage imageNamed:@"frosted_glass_stretchable_12x18.PNG"];
    [scanButton setBackgroundImage:[frostedGlass stretchableImageWithLeftCapWidth:6 topCapHeight:9] forState:UIControlStateNormal];
    [problemButton setBackgroundImage:[frostedGlass stretchableImageWithLeftCapWidth:6 topCapHeight:9] forState:UIControlStateNormal];
    backgroundImage.image = [frostedGlass stretchableImageWithLeftCapWidth:6 topCapHeight:9];
    self.view = overlayView;
    resultsValid = FALSE;
    
    // Note - we can't put the performSegue here - doesn't seem to take effect until we're in view
}

// NOTE - This doesn't cover coming back from BG state
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!resultsValid) [self performSegueWithIdentifier:@"LaunchScanner" sender:self];
    resultsValid = FALSE;
}

// Watch for the global notifications 
- (void) enteredBG {
    self.view = overlayView;
    self.resultsValid = false;
}

- (void) willEnterFG {
    [self performSegueWithIdentifier:@"LaunchScanner" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Below does NOT work, as it complains about ZXingWidgetController being undefined.  What?? RDC
    //
    //if ([segue.identifier compare:@"LaunchScanner"] == NSOrderedSame) {
    
    if ([segue.destinationViewController isKindOfClass:[ZXingWidgetController class]]) {
        self.view = overlayView;
        NSLog(@"%@",segue.destinationViewController);
        ZXingWidgetController* widController = segue.destinationViewController;
        [widController finishInitWithDelegate:self showCancel:YES OneDMode:NO];
        widController.overlayView = (OverlayView*) [[QMOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
        NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
        widController.readers = readers;
        NSBundle *mainBundle = [NSBundle mainBundle];
        widController.soundToPlay =
        [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"caf"] isDirectory:NO];
    }
}

/*- (IBAction)scanPressed:(id)sender {
	
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    widController.readers = readers;
    NSBundle *mainBundle = [NSBundle mainBundle];
    widController.soundToPlay =
    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"caf"] isDirectory:NO];
    [self presentModalViewController:widController animated:YES];
}*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    self.resultsToDisplay = result;
    if (self.isViewLoaded) {
        [prizeText setText:resultsToDisplay];
        [prizeText setNeedsDisplay];
    }
    
    NSDictionary* queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"updateredemptionstate", @"command", 
                                 @"json",                  @"format", 
                                 result,                   @"redemption-code",
                                 nil];
    NSMutableArray* queryArray = [NSMutableArray array];
    for (NSString* key in queryParams) 
        [queryArray addObject:[key stringByAppendingFormat:@"=%@",[queryParams objectForKey:key]]];
    NSString* apiURL = [SERVER_URL_STRING stringByAppendingFormat:@"?%@",[queryArray componentsJoinedByString:@"&"]];
    NSLog(@"%@",apiURL);
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    self.resultsValid = TRUE;
    [self dismissModalViewControllerAnimated:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    [self.prizeText setText:[[response allHeaderFields] description]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!self.connectionData) self.connectionData = [NSMutableData dataWithData:data];
    else [self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString* response = [[NSString alloc] initWithData:self.connectionData encoding:NSUTF8StringEncoding];
    SBJsonParser* parser = [SBJsonParser new];
    NSDictionary* result = [parser objectWithData:self.connectionData];
    NSLog(@"%@",[result objectForKey:@"status"]);
    [self.prizeText setText:response];
    self.view = self.mainView;
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissModalViewControllerAnimated:YES];
}




@end
