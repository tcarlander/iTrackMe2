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
@synthesize managedObjectContext = __managedObjectContext;
@synthesize popoverController;
@synthesize managedObjectModel =  __managedObjectModel;




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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    locationController = [[MyCLController alloc] init];
    locationController.delegate = self;
    [locationController.locationManager startUpdatingLocation];
    locationController.running = TRUE;
    if (__managedObjectContext == nil) 
    { 
        __managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] ; 
        NSLog(@"After managedObjectContext: %@",  __managedObjectContext);
    }
    if (__managedObjectModel==nil) {
        
        __managedObjectModel = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectModel] ; 
        NSLog(@"After managedObjectContext: %@",  __managedObjectModel);
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
    BOOL ran =NO;
    if (!locationController.running){
        [locationController locationToggler];
        ran = YES;
    }
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    BOOL ok = [UIImagePickerController isSourceTypeAvailable:type];
    if (!ok) {
        NSLog(@"alas");
        return; }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = type;
    picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:type];
    picker.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        NSLog(@"iPadding");
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popoverController = popover;
        [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        //        [(UIBarButtonItem *)sender setEnabled:NO];
    }else{
        
        [self presentModalViewController:picker animated:YES];
    }
    if(ran){
        [locationController locationToggler];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"Popped %@", myImage.size.width);
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    // Dismiss the image selection and close the program
    
    [picker dismissModalViewControllerAnimated:YES];
    NSLog(@"Dissmissed picker");    
    
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)Controller{
    
    NSLog(@"Dissmissed picker"); 
    popoverController=nil;
    
}


- (void)addEvent
{
    
    CLLocation *location = locationController.locationManager.location;
    Location *dLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[self managedObjectContext]];
    CLLocationCoordinate2D coordinate = [location coordinate];
    [dLocation setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
    [dLocation setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
    [dLocation setDateOccured:[NSDate date]];
    [dLocation setAltitude:[NSNumber numberWithDouble:location.altitude]];
    [dLocation setAngle:[NSNumber numberWithDouble:location.course]];
    [dLocation setComment:@""];
    [dLocation setIconID:@"1"];
    [dLocation setSpeed:[NSNumber numberWithDouble:location.speed]];
    [dLocation setUploaded:[NSNumber numberWithInt:0]];
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        // Handle the error.
    }else{
        NSLog(@"Added");
    }
    
}

-(void)doData
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    
    
    
    dispatch_async(myQueue, ^{[self sendData];
    });

}

-(void)sendData
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init] ;
    [moc setPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator]];
//    NSManagedObjectContext *moc =[self managedObjectContext];
    NSManagedObjectModel *mom = [[moc persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *fetchRequest = [ mom fetchRequestTemplateForName:@"GetAllNotUploaded"];
    NSError *error = nil;
    NSManagedObject *ob;
    NSArray *fobjects = [moc executeFetchRequest:fetchRequest error:&error];

    
    for ( ob in fobjects) 
    {
       
            Location *dLocation = (Location *) ob;
            if([self pushObject:dLocation]){
                              [dLocation setUploaded:[NSNumber numberWithInt:1]];
                              NSLog(@"Uploaded %@",[NSString stringWithFormat:@"%@", dLocation.Latitude]);
            }
            
        
        
    }
    if (![moc save:&error]) {
    }else{
        NSLog(@"Saved");
    }
}

-(BOOL)pushObject:(Location *)location
{
    // construct url and send it to server
    // /trackme/requests.php?a=upload&u=wgonzalez&p=wfpdubai&lat=25.18511038&long=55.29178735&do=2011-2-3%2013:12:3&tn=wgonzalez&alt=7&ang=&sp=&db=8
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSString * userName = appDelegate.userName;
    NSString * baseURL = appDelegate.serverURL;
    NSString * latitde = [NSString stringWithFormat:@"%@", location.Latitude];
    NSString * longitude = [NSString stringWithFormat:@"%@", location.Longitude];
    NSString * altitude = [NSString stringWithFormat:@"%@", location.Altitude];
    NSString * angle = [NSString stringWithFormat:@"%@", location.Angle];
    NSString * datedone = [dateFormatter stringFromDate:location.DateOccured];   
    
    NSString * fullUrl = [NSString stringWithFormat:@"%@requests.php?a=upload&u=%@&p=wfpdubai&lat=%@&long=%@&do=%@&tn=%@&alt=%@&ang=&sp=&db=8"
                          ,baseURL,userName,latitde,longitude,datedone,userName,altitude,angle];
    fullUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"%@",fullUrl);
    NSURL * serverUrl =  [NSURL URLWithString:fullUrl];
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:serverUrl
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:6.0];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.


        return TRUE;
        
    } else {
        // Inform the user that the connection failed.
        return FALSE;
    }
    return TRUE;
}

- (IBAction)takePhoto:(id)sender {
    [self doData];
}

- (IBAction)tagLocation:(id)sender {
}
@end
