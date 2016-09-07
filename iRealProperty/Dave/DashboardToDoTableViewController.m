//
//  DBTableViewController.m
//  MyDashboardCode
//
//  Created by David Baun on 4/5/14.
//  Copyright (c) 2014 None Yo Bizness. All rights reserved.
//

#import "DashboardToDoTableViewController.h"




@interface DashboardToDoTableViewController ()

    // I believe that putting stuff here makes it private, and therefore only accessible in this class.
    // @property (nonatomic, weak) id <DashboardToDoTableViewDelegate> delegateForChosenToDoItem;

@end




@implementation DashboardToDoTableViewController

    - (id)init
    {
        self = [super initWithStyle:UITableViewStylePlain];
        if (self)
        {

        }
        
        return self ;
    }


    - (id)initWithStyle:(UITableViewStyle)style
    {
        return [self init];
    }



    - (void)viewDidLoad
    {
        [super viewDidLoad];

        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
    }


    - (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }



    #pragma mark - Table view data source

    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        // Return the number of sections.
        return 1;
    }

    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        // Return the number of rows in the section.
        if (self.listOfItems == nil)
        {
            return 1;
        }
        else
        {
            return [self.listOfItems count];
        }
    }

    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        
        // Configure the cell...
        [cell  textLabel].text = [self.listOfItems objectAtIndex:[indexPath row]];
        cell.textLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
        
        return cell;
    }


    #pragma mark - Table view delegate

    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
     
        // Obtain the cell that the user selected, so we can pull info off of it to return to the
        // class interested in that info via the DashboardToDoTableViewDelegate
        
        UITableViewCell *theSelectedCell =  [tableView cellForRowAtIndexPath:indexPath];
        
        if (([self dashboardToDoDelegate]) && ([[self dashboardToDoDelegate] respondsToSelector:@selector(toDoListSelectedItem:)]))
        {
            [[self dashboardToDoDelegate] toDoListSelectedItem:[theSelectedCell textLabel].text];
        }
        
        // Navigation logic may go here. Create and push another view controller.
        /*
         ￼ *detailViewController = [[￼ alloc] initWithNibName:@"￼" bundle:nil];
         // ...
         // Pass the selected object to the new view controller.
         [self.navigationController pushViewController:detailViewController animated:YES];
         */
    }

@end
































