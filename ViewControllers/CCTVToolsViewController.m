//
//  CCTVToolsViewController.m
//  CCTVTools
//
//  Created by Mac HDD on 9/4/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import "CCTVToolsViewController.h"
#import "CCTVToolsAppDelegate.h"

@implementation CCTVToolsViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	if (calculatorsList == nil) {
		NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"calculators.plist"];
		calculatorsList = [NSArray arrayWithContentsOfFile:finalPath];
		[calculatorsList retain];
	}
    
	ccdIndex = [SettingsFirstLevel CCDIndex];

    NSArray* xib;
    xib = [[NSBundle mainBundle] loadNibNamed:@"FocalLengthView" owner:self options:nil];
    vw_focalLength = [(FocalLengthView*)[xib objectAtIndex:0] retain];
    [vw_focalLength initWithData:self];
    vw_focalLength.layer.zPosition = -1;
    
    xib = [[NSBundle mainBundle] loadNibNamed:@"ObjectSizeView" owner:self options:nil];
    vw_objectSize = [(ObjectSizeView*)[xib objectAtIndex:0] retain];
    [vw_objectSize initWithData:self];
    
    xib = [[NSBundle mainBundle] loadNibNamed:@"StorageView" owner:self options:nil];
    vw_storage = [(StorageView*)[xib objectAtIndex:0] retain];
    [vw_storage initWithData:self];
    
    xib = [[NSBundle mainBundle] loadNibNamed:@"DurationView" owner:self options:nil];
    vw_duration = [(DurationView*)[xib objectAtIndex:0] retain];
    [vw_duration initWithData:self];
    
    xib = [[NSBundle mainBundle] loadNibNamed:@"SlideMenu" owner:self options:nil];
    slideMenu = (SlideMenu*)[xib objectAtIndex:0];
    [slideMenu initWithData:self];
    [slideMenu setFrame:CGRectMake(-slideMenu.frame.size.width, 0, slideMenu.frame.size.width, slideMenu.frame.size.height)];
    [self.view addSubview:slideMenu];
    m_shownMenu = false;
}

-(void)viewWillAppear:(BOOL)animated
{
    UINavigationController* nav = (UINavigationController*)APP.window.rootViewController;
    nav.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

//// Callbacks / delegates

- (void)settingsFirstLevelDidFinish:(SettingsFirstLevel *)controller {

	[vw_storage updateResolutionSegment];
    [vw_duration updateResolutionSegment];
	[vw_storage sliderChangedStorage:vw_storage->sldStgFrames.value];
	[vw_duration sliderChangedStorage:vw_duration->sldDurFrames.value];
	
	ccdIndex = [SettingsFirstLevel CCDIndex];
	vw_focalLength->lblFCCD.text = vw_objectSize->lblOCCD.text = [[vw_focalLength->ccdsizeList objectAtIndex:ccdIndex] objectForKey:@"name"];
		
	[self dismissModalViewControllerAnimated:YES];
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)settingsButtonPressed {

	SettingsFirstLevel *firstLevel = [[SettingsFirstLevel alloc] initWithStyle:UITableViewStyleGrouped];
	[firstLevel setCCDSizeList:vw_focalLength->ccdsizeList];
	firstLevel.title = @"Settings";
	firstLevel.delegate = self;

	UINavigationController *controller = [[UINavigationController alloc] initWithNibName:@"NavigationControl" bundle:nil];
	controller.navigationBar.barStyle = UIBarStyleBlack;
	[controller pushViewController:firstLevel animated:YES];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;	 
	[self presentModalViewController:controller animated:YES];
    
	[controller release];
	[firstLevel release];
}

-(IBAction)aboutButtonPressed {

}

-(IBAction)OnMenu:(id)sender
{
    [ UIView beginAnimations:nil context:vw_main];
    [ UIView beginAnimations:nil context:slideMenu];
    [ UIView setAnimationDelegate: self ];
    [ UIView setAnimationDuration:0.6f ];
    if (m_shownMenu)
    {
        vw_main.frame = CGRectMake(0, 0, vw_main.frame.size.width, vw_main.frame.size.height);
        slideMenu.frame = CGRectMake(-slideMenu.frame.size.width, 0, slideMenu.frame.size.width, slideMenu.frame.size.height);
        m_shownMenu = false;
    }
    else
    {
        vw_main.frame = CGRectMake(slideMenu.frame.size.width, 0, vw_main.frame.size.width, vw_main.frame.size.height);
        slideMenu.frame = CGRectMake(0, 0, slideMenu.frame.size.width, slideMenu.frame.size.height);
        m_shownMenu = true;
    }
    [UIView commitAnimations];
}
#pragma mark UISegmentedControl Value changed

-(IBAction)calculatorChanged:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [self ChangeView:btn.tag];
}

-(void)ChangeView:(int)idx
{
    switch (idx) {
		case 0:
			m_curView = vw_focalLength;
			break;
		case 1:
            m_curView = vw_objectSize;
			break;
		case 2:
			m_curView = vw_storage;
			break;
		case 3:
            m_curView = vw_duration;
			break;
        case 4:
            [self settingsButtonPressed];
            return;
        case 5:            
            return;
		default:
			break;
	}
    UINavigationController* nav = (UINavigationController*)APP.window.rootViewController;
    nav.navigationBarHidden = NO;
    UIViewController* vw = [[UIViewController alloc] init];
    [vw setView:m_curView];
    [m_curView setFrame:CGRectMake(0, 40, m_curView.frame.size.width, 256)];
    [self.navigationController pushViewController:vw animated:YES];
    [vw release];
}
@end
