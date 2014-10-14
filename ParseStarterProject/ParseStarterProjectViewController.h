//
//  ParseStarterProjectViewController.h
//  ParseStarterProject
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParseStarterProjectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *addActivityButton;
@property (weak, nonatomic) IBOutlet UITextField *activityDescText;
@property (weak, nonatomic) IBOutlet UIButton *getActivitiesButton;
@property (weak, nonatomic) IBOutlet UITableView *activitiesTableView;

- (IBAction)loginButtonTapped:(id)sender;
- (IBAction)addActivityTapped:(id)sender;
- (IBAction)getActivitiesTapped:(id)sender;

@end
