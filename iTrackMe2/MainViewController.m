//
//  MainViewController.m
//  iTrackMe2
//
//  Created by Tobias Carlander on 17/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController
@synthesize TheMap;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize flipsidePopoverController = _flipsidePopoverController;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationController = [[MyCLController alloc] init];
    locationController.delegate = self;
    [locationController.locationManager startUpdatingLocation];
    locationController.running = TRUE;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTheMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text =  [NSString stringWithFormat:@"%g %g",location.coordinate.latitude,location.coordinate.longitude] ;
    [TheMap setShowsUserLocation:YES];
    MKCoordinateRegion region;
	region.center=location.coordinate;
    MKCoordinateSpan span;
	span.latitudeDelta=.005;
	span.longitudeDelta=.005;
	region.span=span;
    
	[TheMap setRegion:region animated:TRUE];
    
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
}
- (IBAction)locationToggle:(id)sender{
    if (locationController.running){
        [locationController locationManagerStop];
        [statusLabel setTitle:@"Start" forState:UIControlStateNormal] ; 
        
    }else{
        [locationController locationManagerStart];
        [statusLabel setTitle:@"Stop" forState:UIControlStateNormal] ; 

    }
}


- (IBAction)uploadPhoto:(id)sender{
    
}

@end
