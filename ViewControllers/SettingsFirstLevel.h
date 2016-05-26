//
//  SettingsFirstLevel.h
//  CCTVTools
//
//  Created by Faiq Kazi on 14/10/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsSecondLevel.h"
#import "AboutViewController.h"

@protocol SettingsFirstLevelDelegate;

@interface SettingsFirstLevel : UITableViewController {
	
	NSArray *sectionNames;
	NSArray	*ccdsizeList;
	
	AboutViewController *about;
	UISwitch *swtSummary;
	UISegmentedControl *segTvSystem;
	
	UISegmentedControl *segUnits;
	SettingsSecondLevel *tblCCD;
	
	NSIndexPath* ccdsizeListPath;
	
	UIBarButtonItem* cancelButton;
	UIBarButtonItem* saveButton;
}

- (void)setCCDSizeList:(NSArray*)list;

// Getter accessor for settings
+ (BOOL)ShowSummary;
+ (NSInteger)CCDIndex;
+ (BOOL)IsUnitMeters;
+ (BOOL)IsTvSystemPAL;

@property (nonatomic, assign) id <SettingsFirstLevelDelegate> delegate;

@end

@protocol SettingsFirstLevelDelegate
- (void)settingsFirstLevelDidFinish:(SettingsFirstLevel *)controller;
@end
