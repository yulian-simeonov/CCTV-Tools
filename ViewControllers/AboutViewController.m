//
//  AboutViewController.m
//  CCTVTools
//
//  Created by Faiq Kazi on 14/10/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import "AboutViewController.h"

// Private properties
@interface AboutViewController()

@property (nonatomic, retain) UIActivityIndicatorView* activityView;
@property (nonatomic, retain) UIWebView* aboutView;

@end

@implementation AboutViewController

@synthesize activityView;
@synthesize aboutView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	UIColor *color = [[UIColor alloc] initWithRed:.80 green:.80 blue:.80 alpha:1];
	[self.view setBackgroundColor:color];
	[color release];
	
	aboutView.delegate = self;
	
    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	self.activityView = nil;
	self.aboutView = nil;
	
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {

	[activityView startAnimating];
	NSString*	version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://app.webmonkeys.com.au/cctvtools.aspx?ver=%@", version]];
	[aboutView loadRequest:[NSURLRequest requestWithURL:url]];
	
	[super viewDidAppear:animated];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	// load with default image
    NSString *path = [[NSBundle mainBundle] pathForResource:@"defaultAbout.png" ofType:nil];
	if (!path) {
		NSLog(@"Error defaultAbout.png is missing");
		[activityView stopAnimating];
		return;
	}
	
    NSURL *url = [NSURL fileURLWithPath:path];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
		
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView setOpaque:NO];	
	webView.hidden = FALSE;
		
	[activityView stopAnimating];
}

- (void)dealloc {

	[activityView release];
	[aboutView release];	
    [super dealloc];
}


@end
