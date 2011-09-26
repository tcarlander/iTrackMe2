//
//  MyCLController.h
//  iTrackMe
//
//  Created by Tobias Carlander on 16/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyCLControllerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end



@interface MyCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    id delegate;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (unsafe_unretained) id  delegate;
@property (nonatomic) BOOL running;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

-(void)locationManagerStop;
-(void)locationManagerStart;                 
-(void) locationToggler;
@end
