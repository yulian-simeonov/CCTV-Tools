//
//  DurationView.h
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTVToolsViewController;
@interface DurationView : UIScrollView<UITableViewDataSource, UITableViewDelegate>
{
@public
    IBOutlet UITextField		*txtDurCompression;
	IBOutlet UITableView		*tblDurCodec;
	IBOutlet UISlider			*sldDurFrames;
	IBOutlet UILabel			*lblDurFrames;
	IBOutlet UISegmentedControl *segDurQuality;
	IBOutlet UISegmentedControl *segDurResolution;
	IBOutlet UITextField		*txtDurHours;
	IBOutlet UITextField		*txtDurCameras;
	IBOutlet UITextField		*txtDurDisk;
	IBOutlet UITextField		*txtDurDays;
	IBOutlet UILabel			*lblDurSummary;
    IBOutlet UIView *optionView;
    IBOutlet UIButton *btnDurationCalculate;
    
    NSArray		*codecList;
    int         m_oldSelectedRow;
	NSArray		*qualityList;
    NSArray		*palResolutionList;
    NSArray		*ntscResolutionList;
    CCTVToolsViewController* m_parent;
    UITextField *txtFocused;
}
-(void)initWithData:(CCTVToolsViewController*)parent;
- (void)updateResolutionSegment;
-(void)sliderChangedStorage:(NSInteger)value;
@end
