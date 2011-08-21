//
//  MainViewController.m
//  iTrackMe2
//
//  Created by Tobias Carlander on 17/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController
@synthesize uploadPhotoButton;
@synthesize cameraButton;
@synthesize startStopButton;
@synthesize TheMap;
@synthesize managedObjectContext = _managedObjectContext;



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
    if (_managedObjectContext == nil) 
    { 
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] ; 
        NSLog(@"After managedObjectContext: %@",  _managedObjectContext);
    }
}

- (void)viewDidUnload
{
    [self setTheMap:nil];
    [self setUploadPhotoButton:nil];
    [self setCameraButton:nil];
    [self setStartStopButton:nil];
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

- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text =  [NSString stringWithFormat:@"%g %g",location.coordinate.latitude,location.coordinate.longitude] ;
    MKCoordinateRegion region;
	region.center=location.coordinate;
    MKCoordinateSpan span;
	span.latitudeDelta=.005;
	span.longitudeDelta=.005;
	region.span=span;
    [self addEvent];
	[TheMap setRegion:region animated:TRUE];
    
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
}
- (IBAction)locationToggle:(id)sender{

    if (!locationController.running){
        startStopButton.title=@"Stop"; 
        [TheMap setShowsUserLocation:YES];
    }else{
        startStopButton.title=@"Start"; 
        [TheMap setShowsUserLocation:NO];
    }
    [locationController locationToggler];
}


- (IBAction)uploadPhoto:(id)sender{
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    BOOL ok = [UIImagePickerController isSourceTypeAvailable:type];
    if (!ok) {
        NSLog(@"alas");
        return; }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = type;
    picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:type];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    
}

- (void)addEvent
{

    CLLocation *location = locationController.locationManager.location;
    Location *dLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:_managedObjectContext];
    CLLocationCoordinate2D coordinate = [location coordinate];
    [dLocation setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
    [dLocation setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
    [dLocation setDateOccured:[NSDate date]];
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        // Handle the error.
    }else{
        NSLog(@"Saved to DB");
    }
}

- (IBAction)takePhoto:(id)sender {
}

- (IBAction)tagLocation:(id)sender {
}
@end
