//
//  ObjectSizeView.h
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTVToolsViewController;
@interface ObjectSizeView : UIScrollView
{
@public
	IBOutlet UILabel	 *lblOCCD;
	IBOutlet UITextField *txtODistance;
	IBOutlet UITextField *txtOLength;
	IBOutlet UITextField *lblOWidth;
	IBOutlet UITextField *lblOHeight;
	IBOutlet UILabel	 *lblOSummary;
    IBOutlet UIButton *btnObjectCalculate;
    
    NSArray   *ccdsizeList;
    NSInteger ccdIndex;
    CCTVToolsViewController* m_parent;
    UITextField *txtFocused;
}

-(void)initWithData:(CCTVToolsViewController*)parent;
@end
