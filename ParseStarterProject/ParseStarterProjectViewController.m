//
//  ParseStarterProjectViewController.m
//  ParseStarterProject
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import "ParseStarterProjectViewController.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>

@interface ParseStarterProjectViewController()

@property (nonatomic, strong) NSArray *userActivities;

@end

@implementation ParseStarterProjectViewController

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![PFUser currentUser]) {
        [self toggleLogin:YES];
    } else {
        [self toggleLogin:NO];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)toggleLogin:(BOOL)showLogin{
    if (showLogin) {
        self.loginButton.hidden = NO;
        self.addActivityButton.hidden = YES;
        self.activityDescText.hidden = YES;
        self.activitiesTableView.hidden = YES;
        self.getActivitiesButton.hidden = YES;
    } else {
        self.loginButton.hidden = YES;
        self.addActivityButton.hidden = NO;
        self.activityDescText.hidden = NO;
        self.activitiesTableView.hidden = NO;
        self.getActivitiesButton.hidden = NO;
    }
}

#pragma mark - Networking

- (IBAction)loginButtonTapped:(id)sender {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [self toggleLogin:NO];
        }
    }];
}

- (IBAction)addActivityTapped:(id)sender {
    if ([self.activityDescText.text length] > 0) {
        PFObject *activity = [PFObject objectWithClassName:@"Activity"];
        activity[@"description"] = self.activityDescText.text;
        PFUser *user = [PFUser currentUser];
        activity[@"associatedUser"] = user;
        [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.activityDescText.text = @"";
                [[[UIAlertView alloc] initWithTitle:@"Activity Created Successfully"
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"Sweet!", nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Activity Failed to Create"
                                            message:[error localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Bummer man...", nil] show];
            }
        }];
    }
}

- (IBAction)getActivitiesTapped:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    PFUser *user = [PFUser currentUser];
    // Make sure we only get the activities associated with the current user
    [query whereKey:@"associatedUser" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.userActivities = activities;
            [self.activitiesTableView reloadData];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Activity Failed to Get Activities"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Bummer man...", nil] show];
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userActivities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.activitiesTableView dequeueReusableCellWithIdentifier:@"activityCellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"activityCellIdentifier"];
    }
    cell.textLabel.text = [[self.userActivities objectAtIndex:indexPath.row] objectForKey:@"description"];
    return cell;
}

@end
