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
@synthesize myQueue;



- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) 
    {
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
    [locationController locationManagerStart];
    if (__managedObjectContext == nil) 
    { 
        __managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] ; 
    }
    if (__managedObjectModel==nil) 
    {
        __managedObjectModel = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectModel] ; 
    }
    [NSTimer scheduledTimerWithTimeInterval:4
                                     target:self
                                   selector:@selector(doData:)
                                   userInfo:nil
                                    repeats:NO];
    myQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
}

- (void)viewDidUnload
{
    [self setTheMap:nil];
    [self setUploadPhotoButton:nil];
    [self setCameraButton:nil];
    [self setStartStopButton:nil];
    precisionLable = nil;
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)locationUpdate:(CLLocation *)location 
{
    CLLocationAccuracy accuracy = location.horizontalAccuracy;
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    NSDate *timeStamp = location.timestamp;
    
    locationLabelLat.text =  [NSString stringWithFormat:@"Lat:%g",latitude] ;
    locationLabelLong.text = [NSString stringWithFormat:@"Long: %g",longitude] ;
    locationLabelTime.text = [NSString stringWithFormat:@"Last Update: %@",timeStamp] ;
    precisionLable.text =    [NSString stringWithFormat:@"±%.0fm",accuracy];

    MKCoordinateRegion region;
	region.center=location.coordinate;
    MKCoordinateSpan span;
	span.latitudeDelta=.005;
	span.longitudeDelta=.005;
	region.span=span;
    [self addEvent];
	[TheMap setRegion:region animated:TRUE];
    
}

- (void)locationError:(NSError *)error 
{
    locationLabelLat.text = [error description];
}

- (IBAction)locationToggle:(id)sender
{
    
    if (!locationController.running)
    {
        startStopButton.title=@"Stop"; 
        [TheMap setShowsUserLocation:YES];
    }else{
        startStopButton.title=@"Start"; 
        [TheMap setShowsUserLocation:NO];
    }
    [locationController locationToggler];
}


- (IBAction)uploadPhoto:(UIBarButtonItem *)sender
{
    BOOL ran = FALSE;
    if (!locationController.running)
    {
        [locationController locationToggler];
        ran = YES;
    }

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) 
    {
        return; 
    }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(BOOL)pushImageToServer:(UIImage *)imageToPost
{
    NSString * userName = appDelegate.userName;
    NSString * baseURL = appDelegate.serverURL;
    // Send the dragon to the server....
    //image data now contains image
    // create request
    //TODO:: Make smaller image
    
    UIImage *smallImage = [self imageWithImage:imageToPost scaledToSize:CGSizeMake(290, 390)];
    
    NSString * description = @"Sim Description";
    CLLocation *location = locationController.locationManager.location;
    CLLocationCoordinate2D coordinate = [location coordinate];

    NSString * latitude = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * longitude = [NSString stringWithFormat:@"%f",coordinate.longitude];

    NSData *imageData = UIImagePNGRepresentation(smallImage);
    
    NSString *urlString = [NSString stringWithFormat:@"%@incident/",baseURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    //NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@\r\n",boundary];
   // [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];//
    NSMutableData *body = [NSMutableData data];
    // file
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"image\"; filename=\"%@.png\"\r\n", userName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",userName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",description] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"POINT(%@ %@)", longitude, latitude] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Image Return String: %@", returnString);
    
    return NO;
}


- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    BOOL saved = NO;
    [picker dismissModalViewControllerAnimated:YES];
    UIImage * myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (myImage) {
        saved = [self pushImageToServer:myImage];
         NSLog(@"Popped %c", saved);
    }else{
        NSLog(@"Popped %@", myImage);
    }
    //Do Image save

    
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
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    Location *dLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[self managedObjectContext]];
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
    dispatch_async([self myQueue], ^{   
        [self sendData];
    });
    
}

-(void)doData:(NSTimer *)timer{}

-(void)sendData
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init] ;
    [moc setPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator]];
    NSManagedObjectModel *mom = [[moc persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *fetchRequest = [ mom fetchRequestTemplateForName:@"GetAllNotUploaded"];
    NSFetchRequest *deleteRequest = [mom fetchRequestTemplateForName:@"GetAllUploaded"];
    NSLog(@"%@",deleteRequest);
    
    NSError *error = nil;
    //NSManagedObject *ob;
    NSArray *fobjects = [moc executeFetchRequest:fetchRequest error:&error];
    for ( Location *dLocation in fobjects) 
    {
        //Location *dLocation = (Location *) ob;

        if([self pushObject:dLocation])
        {
            [dLocation setUploaded:[NSNumber numberWithInt:1]];
            
           
            NSLog(@"%@",dLocation.uploaded);
            // Location * xLoc =
        }
    }
    [moc  save:&error];
    fobjects = [moc executeFetchRequest:deleteRequest error:&error];
    for ( Location *dLocation in fobjects)
    {
        //Location *dLocation = (Location *) ob;
        NSManagedObject *eventToDelete = [moc objectWithID:dLocation.objectID];
        [eventToDelete.managedObjectContext deleteObject:eventToDelete];
        

    }
    [moc  save:&error];
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
    NSString * fullUrl = [NSString stringWithFormat:@"%@requests.php?a=upload&u=%@&p=wfpdubai&lat=%@&long=%@&do=%@&tn=%@&alt=%@&ang=%@&sp=&db=8"
                          ,baseURL,userName,latitde,longitude,datedone,userName,altitude,angle];
    fullUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"%@",fullUrl);
    NSURL * serverUrl =  [NSURL URLWithString:fullUrl];
    NSURLRequest *theRequest=[
                              NSURLRequest requestWithURL:serverUrl
                                              cachePolicy:NSURLCacheStorageNotAllowed
                                          timeoutInterval:5
                              ];
    NSError *error = nil;
    NSURLResponse  *response = nil;
    NSData *dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    NSString * stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];    
    if ([stringReply isEqualToString:@"Result:0"] || [stringReply isEqualToString:@"Result:2"] ) {
        return TRUE;
    } else {
        return FALSE;
    }
    return TRUE;
}

- (IBAction)takePhoto:(id)sender {
  //  [self doData];    
}

- (IBAction)tagLocation:(id)sender {
    
    
}



@end



