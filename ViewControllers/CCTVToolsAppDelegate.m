//
//  CCTVToolsAppDelegate.m
//  CCTVTools
//
//  Created by Mac HDD on 9/4/10.
//  Copyright AUCOM Surveillance 2010. All rights reserved.
//

#import "CCTVToolsAppDelegate.h"
#import "CCTVToolsViewController.h"

@implementation CCTVToolsAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    CCTVToolsViewController* vw = [[CCTVToolsViewController alloc] initWithNibName:@"CCTVToolsViewController" bundle:nil];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vw];
    nav.navigationBarHidden = YES;
    [window setRootViewController:nav];
    [window makeKeyAndVisible];
	[vw release];
    [nav release];
	return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
