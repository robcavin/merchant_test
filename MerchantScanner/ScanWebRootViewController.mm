//
//  ScanWebRootViewController.m
//  MerchantScanner
//
//  Created by Robert Cavin on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScanWebRootViewController.h"
#import "QRCodeReader.h"
#import "QMOverlayView.h"
#import "SBJson.h"

#define SERVER_URL_STRING @"http://qurious.mobi/r/"

@implementation ScanWebRootViewController
@synthesize overlayView;
@synthesize waitingLabel;
@synthesize mainView;
@synthesize webView;
@synthesize resultsValid;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        // Custom initialization
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


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {        
        // Custom initialization
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


//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
-(void) launchScanner {    
    // Below does NOT work, as it complains about ZXingWidgetController being undefined.  What?? RDC
    //
    //if ([segue.identifier compare:@"LaunchScanner"] == NSOrderedSame) {
    
    //    if ([segue.destinationViewController isKindOfClass:[ZXingWidgetController class]]) {
    //self.view = overlayView;
    self.overlayView.hidden = false;
    //ZXingWidgetController* widController = segue.destinationViewController;
    ZXingWidgetController* widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:NO OneDMode:NO];
    //[widController finishInitWithDelegate:self showCancel:YES OneDMode:NO];
    widController.overlayView = (OverlayView*) [[QMOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    widController.readers = readers;
    NSBundle *mainBundle = [NSBundle mainBundle];
    widController.soundToPlay =
        [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"caf"] isDirectory:NO];
    widController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:widController animated:YES];
    //    }
}


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;

    // When we first launch, we will always want to toss up the scanner first.  
    self.waitingLabel.text = @"Launching Scanner";
    self.overlayView.hidden = false;
    resultsValid = FALSE;  // Indicates the scanner has not yet returned valid results
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // NOTE - If we have multiple tabs, we might need to implement something like the below
    // Doesn't seem to trigger on coming back from background?
    if (!resultsValid) [self launchScanner]; //[self performSegueWithIdentifier:@"LaunchScanner" sender:self];
    
    resultsValid = FALSE;  // Reset the valid indicator after the view has appear
}


// Watch for the global notifications 
- (void) enteredBG {
    [self dismissModalViewControllerAnimated:NO];
    self.waitingLabel.text = @"Launching Scanner";
    self.overlayView.hidden = false;
    self.resultsValid = false;
}

- (void) willEnterFG {
    if (self.isViewLoaded && self.view.window) [self launchScanner]; //[self performSegueWithIdentifier:@"LaunchScanner" sender:self];
}


- (void) failedWithErrorMessage:(NSString*)message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error Redeeming Code" 
                                                        message:message
                                                       delegate:self 
                                              cancelButtonTitle:@"Retry"
                                              otherButtonTitles:nil];
    [alertView show];
    
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
   
    self.resultsValid = TRUE;
    self.waitingLabel.text = @"Loading Results";
    
    [self dismissModalViewControllerAnimated:NO];

    // Verify url pattern
    if ([result compare:SERVER_URL_STRING options:NSCaseInsensitiveSearch range:(NSRange){0,22}] != NSOrderedSame) {
        [self failedWithErrorMessage:[NSString stringWithFormat:@"The scanned string %@ does not contain a valid Qurious code.",result]];
    } else {
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:result]];        
        [self.webView loadRequest:request];
    }
}

- (IBAction) scanButtonPressed:(id)sender {
    [self launchScanner];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.overlayView.hidden = true;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self failedWithErrorMessage:[error description]];
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.waitingLabel setText:@"Launching Scanner"];
        self.overlayView.hidden = false;
        self.resultsValid = false;
        [self launchScanner];//[self performSegueWithIdentifier:@"LaunchScanner" sender:self];
    }
}


- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissModalViewControllerAnimated:YES];
}


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

@end
