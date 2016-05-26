//
//  StorageView.m
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import "StorageView.h"
#import "SettingsFirstLevel.h"
#import "CCTVToolsViewController.h"

@implementation StorageView

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
    if (codecList == nil) {
		NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"codecs.plist"];
		codecList = [[NSArray arrayWithContentsOfFile:finalPath] retain];
	}
    
    if (qualityList == nil) {
        NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"quality.plist"];
        qualityList = [[NSArray arrayWithContentsOfFile:finalPath] retain];
    }
    if (palResolutionList == nil) {
        NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resolution_pal.plist"];
        palResolutionList = [[NSArray arrayWithContentsOfFile:finalPath] retain];
    }
    
    if (ntscResolutionList == nil) {
        NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resolution_ntsc.plist"];
        ntscResolutionList = [[NSArray arrayWithContentsOfFile:finalPath] retain];
    }
    
    [optionView setHidden:YES];
    m_oldSelectedRow = 0;
    [segStgQuality setSelectedSegmentIndex:1];
    [segStgResolution setSelectedSegmentIndex:0];
    optionView.layer.borderWidth = 2;
    UIColor *colorBorder = [[UIColor alloc] initWithRed:.60 green:.60 blue:.60 alpha:1];
    optionView.layer.borderColor = [colorBorder CGColor];
    [colorBorder release];
    
    [self sliderChangedStorage:[SettingsFirstLevel IsTvSystemPAL]? 12: 15];
    [self updateResolutionSegment];
    [self updateQualitySegment];
    [self updateCompression];
    
    [btnStorageCalculate setBackgroundImage:[[UIImage imageNamed:@"whiteButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [btnStorageCalculate setBackgroundImage:[[UIImage imageNamed:@"blueButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    [tblStgCodec reloadData];
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

-(void)updateCompression
{
	// get codec name
	NSInteger index = m_oldSelectedRow;
	NSString *codec = [[codecList objectAtIndex:index] objectForKey:@"name"];
	
	// get quality
	index = [segStgQuality selectedSegmentIndex];
	NSString *quality = [[qualityList objectAtIndex:index] objectForKey:@"name"];
	
	// get frames
	NSInteger frames = sldStgFrames.value;
	
	// get resolution
	index = [segStgResolution selectedSegmentIndex];
	NSArray *resolutionList = ([SettingsFirstLevel IsTvSystemPAL])? palResolutionList: ntscResolutionList;
	NSString *resolution = [[resolutionList objectAtIndex:index] objectForKey:@"shortname"];
	
	NSString *compression = [NSString stringWithFormat:@"%@, %@, %dfps, %@", codec, quality, frames, resolution];

    if ([txtStgCompression.text compare:compression] != NSOrderedSame)
    {
        [self tableView:m_parent->vw_duration->tblDurCodec didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:m_parent->vw_duration->m_oldSelectedRow inSection:0]];
        [m_parent->vw_duration->segDurResolution setSelectedSegmentIndex:[segStgResolution selectedSegmentIndex]];
        [m_parent->vw_duration->segDurQuality setSelectedSegmentIndex:[segStgQuality selectedSegmentIndex]];
        [self sliderChangedStorage:sldStgFrames.value];
        [self clearResults];
    }

	txtStgCompression.text = compression;
}

-(void)updateQualitySegment
{
	// TODO: Assert the length
	for (NSInteger index=0; index < 3; ++index) {
		NSDictionary *quality = [qualityList objectAtIndex:index];
		[segStgQuality setTitle:[quality objectForKey:@"name"] forSegmentAtIndex:index];
	}
}

-(void)updateHoursAndCameras
{
    // Copy hours and cameras to durationView
    if (([txtStgDisk.text compare:m_parent->vw_duration->txtDurDisk.text] != NSOrderedSame && [txtStgDisk.text compare:@"?"] != NSOrderedSame) ||
        [txtStgHours.text compare:m_parent->vw_duration->txtDurHours.text] != NSOrderedSame ||	[txtStgCameras.text compare:m_parent->vw_duration->txtDurCameras.text] != NSOrderedSame) {
        m_parent->vw_duration->txtDurHours.text = txtStgHours.text;
        m_parent->vw_duration->txtDurCameras.text = txtStgCameras.text;
        m_parent->vw_duration->txtDurDisk.text = ([txtStgDisk.text length]==0 || [txtStgDisk.text compare:@"?"]==NSOrderedSame)? @"0": txtStgDisk.text;
        m_parent->vw_duration->txtDurDays.text = @"?";
        m_parent->vw_duration->lblDurSummary.text = @"";
    }
}

- (void)updateResolutionSegment
{
	// TODO: Assert the length
	NSArray *resolutionList = ([SettingsFirstLevel IsTvSystemPAL])? palResolutionList: ntscResolutionList;
	for (NSInteger index=0; index < 3; ++index) {
		NSDictionary *resolution = [resolutionList objectAtIndex:index];
		[segStgResolution setTitle:[resolution objectForKey:@"name"] forSegmentAtIndex:index];
	}
}

-(void)calculateStorageAndDuration{
	
    if(! [self validateField:txtStgHours]) {
        [txtStgHours becomeFirstResponder];
        return;
    } else if(! [self validateField:txtStgCameras]) {
        [txtStgCameras becomeFirstResponder];
        return;
    } else if (![self validateField:txtStgDays]) {
        [txtStgDays becomeFirstResponder];
        return;
    }

	NSInteger segResolutionIndex = [segStgResolution selectedSegmentIndex];
	NSDictionary *resolution = ([SettingsFirstLevel IsTvSystemPAL])? [palResolutionList objectAtIndex:segResolutionIndex]:
    [ntscResolutionList objectAtIndex:segResolutionIndex];
	NSInteger pixels = [[resolution objectForKey:@"height"] intValue] * [[resolution objectForKey:@"width"] intValue];
	
	NSInteger frames = [lblStgFrames.text intValue];
	
	NSInteger codecIndex = m_oldSelectedRow;
	float codec = [[[codecList objectAtIndex:codecIndex] objectForKey:@"multiplier"] floatValue];
	
	NSInteger segQualityIndex = [segStgQuality selectedSegmentIndex];
	float quality = [[[qualityList objectAtIndex:segQualityIndex] objectForKey:@"multiplier"] floatValue];
	
	NSInteger cameras = [txtStgCameras.text intValue];
	NSInteger hours = [txtStgHours.text intValue];
	
	long double totalBytes = (hours * 3600) * codec * pixels * 0.041472 * quality * frames * cameras;
	totalBytes = totalBytes / 1024 / 1024 / 1024; // convert to Gb
	
    NSInteger days = [txtStgDays.text intValue];
    NSLog(@"storage-per-day: %0.2Lf, disk: %0.2Lf", totalBytes, days*totalBytes );
    txtStgDisk.text = [NSString stringWithFormat:@"%0.1Lf", days*totalBytes];
    if ([SettingsFirstLevel ShowSummary]) {
        NSString *summary = [NSString stringWithFormat:@"You will need %0.2LfGb storage per day and %d days will need %0.2LfGb disk space",
                             totalBytes, days, days * totalBytes];
        lblStgSummary.text = summary;
    }
	
	[self updateHoursAndCameras];
}

-(IBAction)storageButtonPressed {
    [txtFocused resignFirstResponder];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 256);
	[optionView setHidden:YES];
	[self calculateStorageAndDuration];
}

-(IBAction)storageCompression {
	
	[self updateResolutionSegment];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:optionView cache:YES];
	[optionView setHidden:NO];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [codecList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CheckMarkCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CheckMarkCellIdentifier] autorelease];
    }
    NSUInteger row = [indexPath row];
	NSDictionary *codec = [codecList objectAtIndex:row];
    cell.textLabel.text = [codec objectForKey:@"name"];
    cell.accessoryType = (row == m_oldSelectedRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_oldSelectedRow inSection:0]];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    m_oldSelectedRow = indexPath.row;
}

-(IBAction)framesSliderChanged {
	NSInteger value = sldStgFrames.value;
	[self sliderChangedStorage:value];
}

-(BOOL)validateField:(UITextField*)field {
	if ([field.text length] == 0 || [field.text floatValue] <= 0) {
		return FALSE;
	}
	return TRUE;
}

-(void)sliderChangedStorage:(NSInteger)value {
	
	NSArray *frames = nil;
	if ([SettingsFirstLevel IsTvSystemPAL]) {
		frames = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"6", @"12", @"25", nil];
	}
	else {
		frames = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"7", @"15", @"30", nil];
	}
	NSLog(@"before nearest value: %d", value);
	value = [self findNearestNumber:value selections:frames];
	NSLog(@"after nearest value: %d", value);
    
    sldStgFrames.maximumValue = [[frames objectAtIndex:[frames count]-1] intValue];
    sldStgFrames.value = value;
    lblStgFrames.text = [NSString stringWithFormat:@"%.0f", sldStgFrames.value];

	[frames release];
}

-(NSInteger)findNearestNumber:(NSInteger)number selections:(NSArray*)array {
    
	for (int index=0; index < [array count]-1; ++index) {
		
		NSInteger lowerBound = [[array objectAtIndex:index] intValue];
		NSInteger upperBound = [[array objectAtIndex:index+1] intValue];
		
		if (number <= lowerBound ) {
			return lowerBound;
		}
		else if (number == upperBound) {
			return upperBound;
		}
		else if (number < upperBound) {
			float half = (upperBound+lowerBound)/2;
			NSLog(@"nearest to half value: %.2f", half);
			number = (number < half)? lowerBound: upperBound;
			return number;
		}
	}
	
	// maximum value
	return [[array objectAtIndex:[array count]-1] intValue];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	
	if (event.type == UIEventSubtypeMotionShake) {
        txtStgHours.text = txtStgCameras.text = txtStgDisk.text = @"0";
        txtStgDays.text = @"?";
        [self updateHoursAndCameras];
        lblStgSummary.text = @"";
	}
	
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

-(void)clearResults
{
    txtStgDisk.text = @"?";
}

-(IBAction)fieldFocused:(UITextField*)field {
	txtFocused = field;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 162 - self.frame.origin.y);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
	// Hours shouldn't be greater than 24
	if (textField == txtStgHours) {
		NSString *hours = [textField.text stringByAppendingString:string];
		if ([hours intValue] > 24) {
			return NO;
		}
	}
    return YES;
}

#pragma Touch
-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    
    // get all touches on the screen
    NSSet *allTouches = [event allTouches];
	//NSSet *allTouches = [event touchesForView:storageView];
    
    // compare the number of touches on the screen
    switch ([allTouches count])
    {
        case 1: {
			// get info of the touch
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			if (touch.view != optionView) {
				[optionView setHidden:YES];
                [txtFocused resignFirstResponder];
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 256);
			}
			break;
		}
	}
    
	[super touchesBegan:touches withEvent:event];
}
@end
