//
//  StorageView.h
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTVToolsViewController;
@interface StorageView : UIScrollView<UITableViewDataSource, UITableViewDelegate>
{
@public
    IBOutlet UITextField		*txtStgCompression;
	IBOutlet UITableView		*tblStgCodec;
	IBOutlet UISlider			*sldStgFrames;
	IBOutlet UILabel			*lblStgFrames;
	IBOutlet UISegmentedControl *segStgQuality;
	IBOutlet UISegmentedControl *segStgResolution;
	IBOutlet UITextField		*txtStgHours;
	IBOutlet UITextField		*txtStgCameras;
	IBOutlet UITextField		*txtStgDisk;
	IBOutlet UITextField		*txtStgDays;
	IBOutlet UILabel			*lblStgSummary;
    IBOutlet UIView *optionView;
    IBOutlet UIButton *btnStorageCalculate;
    
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
