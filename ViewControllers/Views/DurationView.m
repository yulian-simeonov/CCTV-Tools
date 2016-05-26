//
//  DurationView.m
//  CCTVTools
//
//  Created by     on 10/29/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import "DurationView.h"
#import "SettingsFirstLevel.h"
#import "CCTVToolsViewController.h"

@implementation DurationView

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
    [segDurQuality setSelectedSegmentIndex:1];
    [segDurResolution setSelectedSegmentIndex:0];
    UIColor *colorBorder = [[UIColor alloc] initWithRed:.60 green:.60 blue:.60 alpha:1];
    optionView.layer.borderColor = [colorBorder CGColor];
    [colorBorder release];
    
    [self sliderChangedStorage:[SettingsFirstLevel IsTvSystemPAL]? 12: 15];
    [self updateResolutionSegment];
    [self updateQualitySegment];
    [self updateCompression];

    [btnDurationCalculate setBackgroundImage:[[UIImage imageNamed:@"whiteButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [btnDurationCalculate setBackgroundImage:[[UIImage imageNamed:@"blueButton_i.png"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
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

-(void)updateQualitySegment
{
	// TODO: Assert the length
	for (NSInteger index=0; index < 3; ++index) {
		NSDictionary *quality = [qualityList objectAtIndex:index];
		[segDurQuality setTitle:[quality objectForKey:@"name"] forSegmentAtIndex:index];
	}
}

- (void)updateResolutionSegment
{
	NSArray *resolutionList = ([SettingsFirstLevel IsTvSystemPAL])? palResolutionList: ntscResolutionList;
	for (NSInteger index=0; index < 3; ++index) {
		NSDictionary *resolution = [resolutionList objectAtIndex:index];
		[segDurResolution setTitle:[resolution objectForKey:@"name"] forSegmentAtIndex:index];
	}
}

-(void)updateCompression
{
	// get codec name
	NSInteger index = m_oldSelectedRow;
	NSString *codec = [[codecList objectAtIndex:index] objectForKey:@"name"];
	
	// get quality
	index = [segDurQuality selectedSegmentIndex];
	NSString *quality = [[qualityList objectAtIndex:index] objectForKey:@"name"];
	
	// get frames
	NSInteger frames = sldDurFrames.value;
	
	// get resolution
	index = [segDurResolution selectedSegmentIndex];
	NSArray *resolutionList = ([SettingsFirstLevel IsTvSystemPAL])? palResolutionList: ntscResolutionList;
	NSString *resolution = [[resolutionList objectAtIndex:index] objectForKey:@"shortname"];
	
	NSString *compression = [NSString stringWithFormat:@"%@, %@, %dfps, %@", codec, quality, frames, resolution];

    if ([txtDurCompression.text compare:compression] != NSOrderedSame) {
        [self tableView:m_parent->vw_storage->tblStgCodec didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:m_parent->vw_storage->m_oldSelectedRow inSection:0]];
        [m_parent->vw_storage->segStgResolution setSelectedSegmentIndex:[segDurResolution selectedSegmentIndex]];
        [m_parent->vw_storage->segStgQuality setSelectedSegmentIndex:[segDurQuality selectedSegmentIndex]];
        [self sliderChangedStorage:sldDurFrames.value];
        [self clearResults];
    }

	txtDurCompression.text = compression;
}

-(void)updateHoursAndCameras
{
    // Copy hours and cameras to storageView
    if (([txtDurDays.text compare:m_parent->vw_storage->txtStgDays.text] != NSOrderedSame && [txtDurDays.text compare:@"?"] != NSOrderedSame) ||
        [txtDurHours.text compare:m_parent->vw_storage->txtStgHours.text] != NSOrderedSame ||	[txtDurCameras.text compare:m_parent->vw_storage->txtStgCameras.text] != NSOrderedSame) {
        m_parent->vw_storage->txtStgHours.text = txtDurHours.text;
        m_parent->vw_storage->txtStgCameras.text = txtDurCameras.text;
        m_parent->vw_storage->txtStgDays.text = ([txtDurDays.text length]==0 || [txtDurDays.text compare:@"?"]==NSOrderedSame)? @"0": txtDurDays.text;
        m_parent->vw_storage->txtStgDisk.text = @"?";
        m_parent->vw_storage->lblStgSummary.text = @"";
    }
}

-(BOOL)validateField:(UITextField*)field {
	if ([field.text length] == 0 || [field.text floatValue] <= 0) {
		return FALSE;
	}
	return TRUE;
}

-(void)calculateStorageAndDuration
{
    if(! [self validateField:txtDurHours]) {
        [txtDurHours becomeFirstResponder];
        return;
    } else if(! [self validateField:txtDurCameras]) {
        [txtDurCameras becomeFirstResponder];
        return;
    } else if (![self validateField:txtDurDisk]) {
        [txtDurDisk becomeFirstResponder];
        return;
    }

	NSInteger segResolutionIndex = [segDurResolution selectedSegmentIndex];
	NSDictionary *resolution = ([SettingsFirstLevel IsTvSystemPAL])? [palResolutionList objectAtIndex:segResolutionIndex]:
    [ntscResolutionList objectAtIndex:segResolutionIndex];
	NSInteger pixels = [[resolution objectForKey:@"height"] intValue] * [[resolution objectForKey:@"width"] intValue];
	
	NSInteger frames = [lblDurFrames.text intValue];
	
	NSInteger codecIndex = m_oldSelectedRow;
	float codec = [[[codecList objectAtIndex:codecIndex] objectForKey:@"multiplier"] floatValue];
	
	NSInteger segQualityIndex = [segDurQuality selectedSegmentIndex];
	float quality = [[[qualityList objectAtIndex:segQualityIndex] objectForKey:@"multiplier"] floatValue];
	
	NSInteger cameras = [txtDurCameras.text intValue];
	NSInteger hours = [txtDurHours.text intValue];
	
	long double totalBytes = (hours * 3600) * codec * pixels * 0.041472 * quality * frames * cameras;
	totalBytes = totalBytes / 1024 / 1024 / 1024; // convert to Gb
	
	
    NSInteger disk = [txtDurDisk.text intValue];
    NSLog(@"storage-per-day: %0.2Lf, days: %0.2Lf", totalBytes, disk/totalBytes );
    txtDurDays.text = [NSString stringWithFormat:@"%d", (NSInteger)(disk/totalBytes)];
    if ([SettingsFirstLevel ShowSummary]) {
        NSString *summary = [NSString stringWithFormat:@"You will need %0.2LfGb storage per day and your drive of %dGb will store %d days of footage",
                             totalBytes, disk, (NSInteger)(disk/totalBytes)];
        lblDurSummary.text = summary;
    }
	[self updateHoursAndCameras];
}

-(IBAction)durationButtonPressed
{
    [txtFocused resignFirstResponder];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 256);
	[optionView setHidden:YES];
	[self calculateStorageAndDuration];
}

-(IBAction)durationCompression
{
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
	NSLog(@"got list item: %@", cell.textLabel.text );
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
	NSInteger value = sldDurFrames.value;
	[self sliderChangedStorage:value];
}

-(void)sliderChangedStorage:(NSInteger)value
{
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
    
    sldDurFrames.maximumValue = [[frames objectAtIndex:[frames count]-1] intValue];
    sldDurFrames.value = value;
    lblDurFrames.text = [NSString stringWithFormat:@"%.0f", sldDurFrames.value];
	
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
        txtDurHours.text = txtDurCameras.text = txtDurDisk.text = @"0";
        txtDurDays.text = @"?";
        [self updateHoursAndCameras];
        lblDurSummary.text = @"";
	}
	
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

-(void)clearResults
{
    txtDurDays.text = @"?";
}

-(IBAction)fieldFocused:(UITextField*)field {
	txtFocused = field;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 162 - self.frame.origin.y);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
	// Hours shouldn't be greater than 24
	if (textField == txtDurHours) {
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
