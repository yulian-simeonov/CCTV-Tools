//
//  ObjectSizeView.m
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import "ObjectSizeView.h"
#import "SettingsFirstLevel.h"
#import "CCTVToolsViewController.h"

@implementation ObjectSizeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            }
    return self;
}

-(void)initWithData:(CCTVToolsViewController*)parent
{
    m_parent = parent;
    // Initialization code
    if (ccdsizeList == nil) {
        NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"ccdsize.plist"];
        ccdsizeList = [[NSArray arrayWithContentsOfFile:finalPath] retain];
    }
    lblOCCD.text = [[ccdsizeList objectAtIndex:ccdIndex] objectForKey:@"name"];
    [btnObjectCalculate setBackgroundImage:[[UIImage imageNamed:@"whiteButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [btnObjectCalculate setBackgroundImage:[[UIImage imageNamed:@"blueButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [self setContentSize:self.frame.size];
    [self setClipsToBounds:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(BOOL)validateField:(UITextField*)field {
	if ([field.text length] == 0 || [field.text floatValue] <= 0) {
		return FALSE;
	}
	return TRUE;
}

-(void)updateFocalAndObject
{
    // Copy width, height and distance to focalView
    if (([lblOWidth.text compare:m_parent->vw_focalLength->txtFWidth.text] != NSOrderedSame && [lblOWidth.text compare:@"?"] != NSOrderedSame) ||
        ([lblOHeight.text compare:m_parent->vw_focalLength->txtFHeight.text] != NSOrderedSame && [lblOHeight.text compare:@"?"] != NSOrderedSame) ||
        [txtODistance.text compare:m_parent->vw_focalLength->txtFDistance.text] != NSOrderedSame) {
        
        m_parent->vw_focalLength->txtFWidth.text = ([lblOWidth.text length]==0 || [lblOWidth.text compare:@"?"]==NSOrderedSame) ? @"0" : lblOWidth.text;
        m_parent->vw_focalLength->txtFHeight.text = ([lblOHeight.text length]==0 || [lblOHeight.text compare:@"?"]==NSOrderedSame) ? @"0": lblOHeight.text;
        m_parent->vw_focalLength->txtFDistance.text = txtODistance.text;
        m_parent->vw_focalLength->lblFocalLength.text = @"?";
        m_parent->vw_focalLength->lblFSummary.text = @"";
    }
}

- (void)calculateObjectSize {
	
	if(! [self validateField:txtOLength]) {
		[txtOLength becomeFirstResponder];
	} else if(! [self validateField:txtODistance]) {
		[txtODistance becomeFirstResponder];
	} else {
		
		NSDictionary *imageSize = [ccdsizeList objectAtIndex:ccdIndex];
		float distance = [[txtODistance text] floatValue];
		float ccdWidth = [[imageSize objectForKey:@"width"] floatValue];
		float focalLength = [[txtOLength text] floatValue];
		float width = (distance * ccdWidth)/ focalLength;
		float height = (width * 3.0) / 4.0;
		
		NSLog(@"Focal Length W H :-> %f %f", width, height);
		[lblOWidth setText:[NSString stringWithFormat:@"%0.1f", width]];
		[lblOHeight setText:[NSString stringWithFormat:@"%0.1f", height]];
		
		if ([SettingsFirstLevel ShowSummary]) {
			NSString* unit = [SettingsFirstLevel IsUnitMeters]? @"meters": @"feet";
			[lblOSummary setText:[NSString stringWithFormat:@"At a distance of %0.1f %@, using a %0.1fmm lens you will see an object %0.1f %@ wide by %0.1f %@ high.",
								  distance, unit, focalLength, width, unit, height, unit]];
		}
	}
	[self updateFocalAndObject];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        txtODistance.text = txtOLength.text = @"0";
        lblOWidth.text = lblOHeight.text = @"?";
        [self updateFocalAndObject];
        lblOSummary.text = @"";
    }
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

-(void)clearResult
{
    lblOSummary.text = @"";
}

-(IBAction)objectButtonPressed {
    [txtFocused resignFirstResponder];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 256);
	[self calculateObjectSize];
}

-(IBAction)fieldFocused:(UITextField*)field {
	txtFocused = field;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 162 - self.frame.origin.y);
}

#pragma Touch
-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    
    [txtFocused resignFirstResponder];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 256);
	[super touchesBegan:touches withEvent:event];
}
@end
