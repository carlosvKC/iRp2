//
//  DBTableViewController.h
//  MyDashboardCode
//
//  Created by David Baun on 4/5/14.
//  Copyright (c) 2014 None Yo Bizness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardToDoTableViewDelegate.h"


@interface DashboardToDoTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
    // Allows a class make itself the recipient of calls from the TableViewController
    // with requests from the TableViewController for an NSArray of items to display,
    // as well as notifying the class with the chosen item after the user makes a choice.
    @property (nonatomic, weak) id <DashboardToDoTableViewDelegate> dashboardToDoDelegate;
    @property (nonatomic, weak) NSArray *listOfItems;
@end
