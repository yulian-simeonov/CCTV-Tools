//
//  FocalLengthView.m
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import "FocalLengthView.h"
#import "SettingsFirstLevel.h"
#import "CCTVToolsViewController.h"

@implementation FocalLengthView

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
    if (ccdsizeList == nil) {
        NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"ccdsize.plist"];
        ccdsizeList = [[NSArray arrayWithContentsOfFile:finalPath] retain];
    }
    lblFCCD.text = [[ccdsizeList objectAtIndex:ccdIndex] objectForKey:@"name"];
    [btnFocalCalculate setBackgroundImage:[[UIImage imageNamed:@"whiteButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [btnFocalCalculate setBackgroundImage:[[UIImage imageNamed:@"blueButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
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

-(void)updateFocalAndObject
{
    // Copy length and distance to objectView
    if (([lblFocalLength.text compare:m_parent->vw_objectSize->txtOLength.text] != NSOrderedSame && [lblFocalLength.text compare:@"?"] != NSOrderedSame) ||
        [txtFDistance.text compare:m_parent->vw_objectSize->txtODistance.text] != NSOrderedSame) {
        
        m_parent->vw_objectSize->txtOLength.text = ([lblFocalLength.text length]==0 || [lblFocalLength.text compare:@"?"]==NSOrderedSame) ? @"0" : lblFocalLength.text;
        m_parent->vw_objectSize->txtODistance.text = txtFDistance.text;
        m_parent->vw_objectSize->lblOWidth.text = m_parent->vw_objectSize->lblOHeight.text = @"?";
        m_parent->vw_objectSize->lblOSummary.text = @"";
    }
}

-(IBAction)OnTextChanged:(id)sender
{
    UITextField* txt = (UITextField*)sender;
    if(txt.tag == 0)
        txtFHeight.text = [NSString stringWithFormat:@"%.2f", [txt.text floatValue] * 3 / 4];
    else
        txtFWidth.text = [NSString stringWithFormat:@"%.2f", [txt.text floatValue] * 4 / 3];
}

-(BOOL)validateField:(UITextField*)field {
	if ([field.text length] == 0 || [field.text floatValue] <= 0) {
		return FALSE;
	}
	return TRUE;
}

- (void)calculateFocalLength {
	
	if(! [self validateField:txtFWidth]) {
		[txtFWidth becomeFirstResponder];
	} else if(! [self validateField:txtFHeight]) {
		[txtFHeight becomeFirstResponder];
	} else if(! [self validateField:txtFDistance]) {
		[txtFDistance becomeFirstResponder];
	} else {
		NSDictionary *imageSize = [ccdsizeList objectAtIndex:ccdIndex];
		float distance = [[txtFDistance text] floatValue];
		float ccdWidth = [[imageSize objectForKey:@"width"] floatValue];
		float ccdHeight = [[imageSize objectForKey:@"height"] floatValue];
		float width = [[txtFWidth text] floatValue];
		float height = [[txtFHeight text] floatValue];
		float focalLengthW = (distance * ccdWidth)/ width;
		float focalLengthH = (distance * ccdHeight)/ height;
		
		NSLog(@"Focal Length W H :-> %f %f", focalLengthW, focalLengthH);
		
		[lblFocalLength setText:[NSString stringWithFormat:@"%0.1f", focalLengthW]];
        
		if ([SettingsFirstLevel ShowSummary]) {
			NSString* unit = [SettingsFirstLevel IsUnitMeters]? @"meters": @"feet";
			[lblFSummary setText:[NSString stringWithFormat:@"You will need a %0.1fmm lens to view an area %0.1f %@ wide by %0.1f %@ high from a distance of %0.1f %@.",
								  focalLengthW, width, unit, height, unit, distance, unit]];
		}
	}
	[self updateFocalAndObject];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        txtFDistance.text = txtFWidth.text = txtFHeight.text = @"0";
        lblFocalLength.text = @"?";
        [self updateFocalAndObject];
        lblFSummary.text = @"";
    }
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

-(void)clearResult
{
    lblFSummary.text = @"";
}

-(IBAction)focalButtonPressed {
    [txtFocused resignFirstResponder];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 256);
	[self calculateFocalLength];
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
