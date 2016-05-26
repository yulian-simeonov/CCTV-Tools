//
//  SettingsSecondLevel.h
//  CCTVTools
//
//  Created by Faiq Kazi on 12/11/10.
//  Copyright 2010 AUCOM Surveillance. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsSecondLevel : UITableViewController {
	
    NSArray		*rowList;	
	NSInteger   checkedIndex;
}

- (void)setRowList:(NSArray*)optionlist checkedIndex:(NSInteger)index;

@property (nonatomic, readonly) NSInteger checkedIndex;
@property (nonatomic, retain) NSArray *rowList;
@end
