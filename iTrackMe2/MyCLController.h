//
//  MyCLController.h
//  iTrackMe
//
//  Created by Tobias Carlander on 16/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//

@import Foundation;


@protocol MyCLControllerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end


/**
 The Core Location Interfaice
 
 */
@interface MyCLController : NSObject <CLLocationManagerDelegate> {
    /**
     The Cre Location Manager
     */
	CLLocationManager *locationManager;
    id delegate;
}
/**
 The Cre Location Manager
 */
@property (nonatomic, retain) CLLocationManager *locationManager;

/**
 The CL Delegate
 */

@property (unsafe_unretained) id  delegate;

/** 
 Is the CL running or not
 */

@property (nonatomic) BOOL running;

/**
 Location changed callback
 @param manager The CL Manager
 @param newLocation The New Location
 @param oldLocation The Old Location
 
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
/**
 On Failiur
 @param manager The CL Manager
 @param error The Error
 */
 
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

-(void)locationManagerStop;
-(void)locationManagerStart;                 
-(void) locationToggler;
@end
