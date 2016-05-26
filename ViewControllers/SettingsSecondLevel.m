//
//  SettingsSecondLevel.m
//  CCTVTools
//
//  Created by Faiq Kazi on 12/11/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import "SettingsSecondLevel.h"

@implementation SettingsSecondLevel

@synthesize checkedIndex;
@synthesize rowList;

#pragma mark -
#pragma mark Core Events

- (void)viewDidUnload
{
    self.rowList = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [rowList release];
    [super dealloc];
}

#pragma mark -
#pragma mark Setter (accessor) Methods

- (void)setRowList:(NSArray*)optionlist checkedIndex:(NSInteger)index {

	self.rowList = optionlist;
	checkedIndex = index;
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rowList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CheckMarkCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CheckMarkCellIdentifier] autorelease];
    }
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[rowList objectAtIndex:row] objectForKey:@"name"];
    cell.accessoryType = (row == checkedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	if (row == self.checkedIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int newRow = [indexPath row];
    int oldRow = checkedIndex;
    
    if (newRow != oldRow)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:checkedIndex inSection:0]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;

		checkedIndex = newRow;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
