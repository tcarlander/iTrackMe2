//
//  MainViewController.h
//  iTrackMe2
//
//  Created by Tobias Carlander on 17/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MyCLController.h"
#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, MyCLControllerDelegate>{
    MyCLController *locationController;
    IBOutlet UILabel *locationLabel;
    IBOutlet UIButton *statusLabel;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;


- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

- (IBAction)showInfo:(id)sender;
- (IBAction)locationToggle:(id)sender;

@end
