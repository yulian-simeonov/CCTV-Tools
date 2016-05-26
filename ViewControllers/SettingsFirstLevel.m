//
//  SettingsFirstLevel.m
//  CCTVTools
//
//  Created by Faiq Kazi on 14/10/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import "SettingsFirstLevel.h"

// Private properties
@interface SettingsFirstLevel()

+ (BOOL)GetBoolSetting:(NSString *)key defaultValue:(BOOL)value;
+ (NSInteger)GetIntSetting:(NSString *)key defaultValue:(NSInteger)value;

@property (nonatomic, retain) NSArray *sectionNames;
@property (nonatomic, retain) NSArray *ccdsizeList;

@property (nonatomic, retain) AboutViewController *about;
@property (nonatomic, retain) UISwitch *swtSummary;
@property (nonatomic, retain) UISegmentedControl *segTvSystem;
@property (nonatomic, retain) UISegmentedControl *segUnits;
@property (nonatomic, retain) SettingsSecondLevel *tblCCD;

@property (nonatomic, retain) NSIndexPath *ccdsizeListPath;

@property (nonatomic, retain) UIBarButtonItem* cancelButton;
@property (nonatomic, retain) UIBarButtonItem* saveButton;

@end


@implementation SettingsFirstLevel

@synthesize delegate;

@synthesize sectionNames;
@synthesize ccdsizeList;

@synthesize about;
@synthesize swtSummary;
@synthesize segTvSystem;
@synthesize segUnits;
@synthesize tblCCD;

@synthesize ccdsizeListPath;

@synthesize cancelButton;
@synthesize saveButton;


#pragma mark -
#pragma mark Core Events

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// Section Names
	self.sectionNames = [[NSArray alloc] initWithObjects:@"", @"General", @"Focal/Object", nil];
	
	// About
	self.about = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	
	// Summary
    self.swtSummary = [[UISwitch alloc] initWithFrame:CGRectZero];
	[swtSummary setOn:[SettingsFirstLevel ShowSummary]];

	// Tv System
	NSArray *tvSystem = [[NSArray alloc] initWithObjects:@"PAL", @"NTSC", nil];
	self.segTvSystem = [[UISegmentedControl alloc] initWithItems:tvSystem];
	segTvSystem.segmentedControlStyle = UISegmentedControlStyleBar;
	[segTvSystem setSelectedSegmentIndex:([SettingsFirstLevel IsTvSystemPAL])? 0: 1];
	[tvSystem release];

	// Measurement Unit
	NSArray *units = [[NSArray alloc] initWithObjects:@"Meters", @"Feet", nil];	
	self.segUnits = [[UISegmentedControl alloc] initWithItems:units];
	segUnits.segmentedControlStyle = UISegmentedControlStyleBar;
	[segUnits setSelectedSegmentIndex:([SettingsFirstLevel IsUnitMeters])? 0: 1];
	[units release];

	// CCDSize List
    self.tblCCD = [[SettingsSecondLevel alloc] initWithStyle:UITableViewStyleGrouped];
	[tblCCD setRowList:ccdsizeList checkedIndex:[SettingsFirstLevel CCDIndex]];
	tblCCD.title = @"CCD Size";
						 
	self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton:)];
	self.navigationItem.leftBarButtonItem = self.cancelButton;

	self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton:)];	
	self.navigationItem.rightBarButtonItem = self.saveButton;
	
    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated {
	
	// Reload the 'CCD Size' cell data
	UITableViewCell *cell = [[self.tableView cellForRowAtIndexPath:ccdsizeListPath] retain];
	NSString *selected = [[[ccdsizeList objectAtIndex:tblCCD.checkedIndex] objectForKey:@"name"] retain];
	if ([selected compare:cell.detailTextLabel.text] != NSOrderedSame) {
		NSArray *array = [[NSArray alloc] initWithObjects:ccdsizeListPath, nil];
		[self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
		[array release];
	}
	[selected release];
	[cell release];
	
	[super viewDidAppear:animated];
}

- (void)viewDidUnload {

	self.about = nil;
	self.swtSummary = nil;
	self.segTvSystem = nil;
	self.segUnits = nil;
	self.tblCCD = nil;
	
	self.sectionNames = nil;
	self.ccdsizeList = nil;
	
	self.ccdsizeListPath = nil;
	
	self.cancelButton = nil;
	self.saveButton = nil;
	
    [super viewDidUnload];
}

- (void)dealloc {
	
	[self.about release];
	[self.swtSummary release];
	[self.segTvSystem release];
	[self.segUnits release];
	[self.tblCCD release];
	
	[self.sectionNames release];
	[self.ccdsizeList release];
	
	[self.ccdsizeListPath release];
	
	[self.cancelButton release];
	[self.saveButton release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Setter (accessor) Methods

- (void)setCCDSizeList:(NSArray*)list {
	self.ccdsizeList = list;
}

#pragma mark -
#pragma mark Action buttons

- (void)cancelButton:(id)sender {
	
	[self.delegate settingsFirstLevelDidFinish:self];
}

- (void)saveButton:(id)sender {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Save settings for show summary
	[defaults setBool:[swtSummary isOn] forKey:@"ShowSummary"];
	
	// Save settings for tv system
	[defaults setBool:([segTvSystem selectedSegmentIndex]==0)? YES: NO forKey:@"IsTvSystemPAL"];

	// Save settings for measurement unit
	[defaults setBool:([segUnits selectedSegmentIndex]==0)? YES: NO forKey:@"IsUnitMeters"];	
	
	// Save settings for ccd size
	[defaults setInteger:tblCCD.checkedIndex forKey:@"CCDIndex"];	
	
	[self.delegate settingsFirstLevelDidFinish:self];	
}

#pragma mark -
#pragma mark Setting Getter (accessor) Methods

+ (NSInteger)CCDIndex {
	return [SettingsFirstLevel GetIntSetting:@"CCDIndex" defaultValue:1];	
}

+ (BOOL)IsTvSystemPAL {
	return [SettingsFirstLevel GetBoolSetting:@"IsTvSystemPAL" defaultValue:TRUE];	
}

+ (BOOL)IsUnitMeters {
	return [SettingsFirstLevel GetBoolSetting:@"IsUnitMeters" defaultValue:TRUE];	
}

+ (BOOL)ShowSummary {	
	return [SettingsFirstLevel GetBoolSetting:@"ShowSummary" defaultValue:TRUE];
}

+ (BOOL)GetBoolSetting:(NSString *)key defaultValue:(BOOL)value {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL keyValue = value;
	if ([defaults stringForKey:key]) {
		keyValue = [defaults boolForKey:key];
	}
	NSLog(@"setting %@: %d", key, keyValue);	
	
	return keyValue;	
}

+ (NSInteger)GetIntSetting:(NSString *)key defaultValue:(NSInteger)value {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSInteger keyValue = value;
	if ([defaults stringForKey:key]) {
		keyValue = [defaults integerForKey:key];
	}
	NSLog(@"setting %@: %d", key, keyValue);	
	
	return keyValue;	
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return 1;
			break;			
		case 1:
			return 2;
			break;
		case 2:
			return 2;
			break;
		default:
			NSLog(@"WARNING: section: %d is invalid", section);
			break;
	}
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [sectionNames objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *FirstLevelCell= @"FirstLevelCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: 
                             FirstLevelCell];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier: FirstLevelCell] autorelease];
    }
	cell.accessoryType  = UITableViewCellAccessoryNone;

    // Configure the cells
	//
	switch ([indexPath section]) {
			
		case 0:
			switch ([indexPath row]) {
				case 0:	{
					cell.textLabel.text = @"About";
					cell.detailTextLabel.text = @"CCTV Tools";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;			
					}
					break;
					
				default:
					NSLog(@"WARNING: section:%d row:%d is invalid", [indexPath section], [indexPath row]);
					break;					
			}
			break;
			
		case 1:
			switch ([indexPath row]) {
				case 0:	{
					[cell addSubview:swtSummary];
					cell.textLabel.text = @"Summary";
					cell.accessoryView = swtSummary;
					}
					break;
				
				case 1: {
					[cell addSubview:segTvSystem];
					cell.textLabel.text = @"TV System";
					cell.accessoryView = segTvSystem;			
					}
					break;
				
				default:
					NSLog(@"WARNING: section:%d row:%d is invalid", [indexPath section], [indexPath row]);
					break;
			}		
			break;
		
		case 2:
			switch ([indexPath row]) {
				
				case 0: {
					[cell addSubview:segUnits];
					cell.textLabel.text = @"Measurement";
					cell.accessoryView = segUnits;			
					}
					break;
				
				case 1: {
					self.ccdsizeListPath = indexPath;
					cell.textLabel.text = tblCCD.title;
					cell.detailTextLabel.text = [[ccdsizeList objectAtIndex:tblCCD.checkedIndex] objectForKey:@"name"];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;			
					}
					break;
				
				default:
					NSLog(@"WARNING: section:%d row:%d is invalid", [indexPath section], [indexPath row]);
					break;
			}
			break;
		
		default:
			NSLog(@"WARNING: section:%d is invalid", [indexPath section]);
			break;
	}
	
    return cell;
}

#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch ([indexPath section]) {
	case 0:
		if ([indexPath row] == 0) {
			[self.navigationController pushViewController:about animated:YES];
		}
		break;
		
	case 2:
		if ([indexPath row] == 1) {
			[self.navigationController pushViewController:tblCCD animated:YES];
		}
		break;
		
	default:
		break;
	}
}

@end
