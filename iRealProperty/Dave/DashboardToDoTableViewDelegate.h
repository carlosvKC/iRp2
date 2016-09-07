//
//  @protocol DashboardToDoTableViewDelegate <NSObject>  DashboardToDoTableViewDelegate.h
//  MyDashboardCode
//
//  Created by David Baun on 4/8/14.
//  Copyright (c) 2014 None Yo Bizness. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DashboardToDoTableViewDelegate <NSObject>

    // The implementer of this protocol will receive this call from the TableView with the item that was chosen.
    -(void)toDoListSelectedItem:(NSString *)item;

    // The implementer of this protcol will receive this call from the TableView, expecting to receive a list of items for display.
    // -(NSArray *)tableViewItemsToDisplay;

@end