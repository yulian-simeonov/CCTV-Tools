//
//  CCTVToolsViewController.h
//  CCTVTools
//
//  Created by Mac HDD on 9/4/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "FocalLengthView.h"
#import "ObjectSizeView.h"
#import "StorageView.h"
#import "DurationView.h"
#import "SlideMenu.h"

#import "SettingsFirstLevel.h"

@interface CCTVToolsViewController : UIViewController <UITextFieldDelegate, SettingsFirstLevelDelegate>
{
	NSArray		*calculatorsList;
    int ccdIndex;
	NSInteger lastOffsetX;
	NSInteger lastOffsetY;
	SystemSoundID soundID;
    UIView* m_curView;
    
    IBOutlet UIView* vw_main;
    SlideMenu* slideMenu;
    BOOL m_shownMenu;
@public
    FocalLengthView* vw_focalLength;
    ObjectSizeView* vw_objectSize;
    StorageView* vw_storage;
    DurationView* vw_duration;
}

-(void)ChangeView:(int)idx;
-(IBAction)OnMenu:(id)sender;
@end

