//
//  Location.h
//  iTrackMe2
//
//  Created by Tobias Carlander on 23/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@import Foundation;
@import CoreData;


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * Altitude;
@property (nonatomic, retain) NSNumber * Angle;
@property (nonatomic, retain) NSString * Comment;
@property (nonatomic, retain) NSDate * DateOccured;
@property (nonatomic, retain) NSString * IconID;
@property (nonatomic, retain) NSNumber * Latitude;
@property (nonatomic, retain) NSNumber * Longitude;
@property (nonatomic, retain) NSNumber * Speed;
@property (nonatomic, retain) NSString * TripID;
@property (nonatomic, retain) NSNumber * uploaded;

@end
