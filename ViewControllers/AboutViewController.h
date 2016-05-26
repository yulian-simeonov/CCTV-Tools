//
//  AboutViewController.h
//  CCTVTools
//
//  Created by Faiq Kazi on 14/10/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate> {
	
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIWebView *aboutView;
}

@end
