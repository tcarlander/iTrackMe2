//
//  MyCLController.m
//  iTrackMe
//
//  Created by Tobias Carlander on 16/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//
// Toby
#import "MyCLController.h"

@implementation MyCLController

@synthesize locationManager;
@synthesize  delegate = _delegate;
@synthesize running;


- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self; // send loc updates to myself
        self.locationManager.distanceFilter = 10;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    [self.delegate locationUpdate:newLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

-(void)locationManagerStop

{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    running = FALSE;
}
-(void)locationManagerStart

{
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];    
    running = TRUE;
}

-(void) locationToggler{
    if (!self.running){
        [self locationManagerStart];
    }else{
        [self locationManagerStop];
    }
}


@end