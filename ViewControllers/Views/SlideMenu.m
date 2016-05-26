//
//  SlideMenu.m
//  CCTVTools
//
//  Created by     on 11/1/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import "SlideMenu.h"
#import "CCTVToolsViewController.h"

@implementation SlideMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)initWithData:(CCTVToolsViewController*)parent
{
    m_parent = parent;
    menus[0] = @"Focal Length";
    menus[1] = @"Object Size";
    menus[2] = @"Storage";
    menus[3] = @"Duration";
    menus[4] = @"Setting";
    menus[5] = @"Help";
    [tbl_menu reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"TagsIdentifier%d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = menus[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size: 16.0];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_parent ChangeView:indexPath.row];
    [m_parent OnMenu:nil];
}
@end
