//
//  FocalLengthView.h
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTVToolsViewController;

@interface FocalLengthView : UIScrollView<UITextFieldDelegate>
{
@public
	IBOutlet UILabel	 *lblFCCD;
	IBOutlet UITextField *txtFDistance;
	IBOutlet UITextField *txtFWidth;
	IBOutlet UITextField *txtFHeight;
	IBOutlet UITextField *lblFocalLength;
	IBOutlet UILabel     *lblFSummary;
    IBOutlet UIButton *btnFocalCalculate;
    
    NSArray   *ccdsizeList;
    NSInteger ccdIndex;
    CCTVToolsViewController* m_parent;
    UITextField *txtFocused;
}

-(void)initWithData:(CCTVToolsViewController*)parent;
@end
