//
//  BBLocationManager.h
//  SDK_iOS_DATA
//
//  Created by Benzamin on 4/15/15.
//  Copyright (c) 2015 Benzamin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BBFenceInfo.h"

#define BB_DEFAULT_FENCE_RADIOUS 100.0f
#define BB_LATITUDE @"latitude"
#define BB_LONGITUDE @"longitude"
#define BB_ALTITUDE @"altitude"
#define BB_RADIOUS @"BBRadious"

#define BB_ADDRESS_NAME @"address_name"         // eg. Apple Inc.
#define BB_ADDRESS_STREET @"address_street"     // street name, eg. Infinite Loop
#define BB_ADDRESS_CITY @"address_city"         // city, eg. Cupertino
#define BB_ADDRESS_STATE @"address_state"       // state, eg. CA
#define BB_ADDRESS_COUNTY @"address_county"     // county, eg. Santa Clara
#define BB_ADDRESS_ZIPCODE @"address_zipcode"   // zip code, eg. 95014
#define BB_ADDRESS_COUNTRY @"address_country"   // eg. United States
#define BB_ADDRESS_DICTIONARY @"address_full_dictionary"  //total "addressDictionary" of "CLPlacemark" object


typedef void(^LocationUpdateBlock)(BOOL success, NSDictionary *locationDictionary, NSError *error);
typedef void(^GeoCodeUpdateBlock)(BOOL success, NSDictionary *geoCodeDictionary, NSError *error);

@protocol BBLocationManagerDelegate <NSObject>

/**
 *   Gives an BBFenceInfo Object of a Fence just added
 */
-(void)BBLocationManagerDidAddFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an BBFenceInfo Object of a Fence just failed to monitor
 */
-(void)BBLocationManagerDidFailedFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an BBFenceInfo Object of Entered Fence
 */
-(void)BBLocationManagerDidEnterFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an BBFenceInfo Object of Exited Fence
 */
-(void)BBLocationManagerDidExitFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an Location Dictionary using keys BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE
*/
-(void)BBLocationManagerDidUpdateLocation:(NSDictionary *)latLongAltitudeDictionary;


/**
 *   Gives an Dictionary using current geocode or adress information with BB_ADDRESS_ keys
 */
-(void)BBLocationManagerDidUpdateGeocodeAdress:(NSDictionary *)addressDictionary;


@end

@interface BBLocationManager : NSObject
{
    
    __weak id <BBLocationManagerDelegate> _delegate;
}

@property (nonatomic, weak) id <BBLocationManagerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *lastKnownGeocodeAddress;
@property (nonatomic, strong) NSDictionary *lastKnownGeoLocation;



/**
 *   Returns a singeton(static) instance of the BBLocationManager
 *   <p>
 *   Returns a singeton(static) instance of the BBLocationManager
 *   </p>
 *   @return singeton(static) instance of the BBLocationManager
 */
+ (id)sharedManager;


/**
 *   Returns location permission status
 *   <p>
 *   Returns wheather location is permitted or not by the user
 *   </p>
 *   @param
 *   @return true or false based on permission given or not
 */
+ (BOOL)locationPermission;

/**
 *   Prompts user for location permission
 *   <p>
 *   If user havn't seen any permission requests yet, calling this method will ask user for location permission
 *   For knowing permission status, call the @locationPermission method
 *   </p>
 *   @param
 *   @return
 */
-(void)getPermissionForStartUpdatingLocation;

/**
 *   Gives an Array of dictionary formatted BBFenceInfo which are currently active
 *   <p>
 *   Gives an Array of dictionary formatted BBFenceInfo which are currently active
 *   </p>
 *   @param
 *   @return an Array of dictionary formatted BBFenceInfo
 */
- (NSArray*)getCurrentFences;

/**
 *   Delete all the fences which are currently active.
 *   <p>
 *   Those fences we created and are currently active, delete all of'em.
 *   </p>
 *   @param
 *   @return
 */
-(void)deleteCurrentFences;

/**
 *   Returns current location through the BBLocationManagerDelegate
 *   <p>
 *   Gives location of device using delegate BBLocationManagerDidUpdateLocation:
 *   </p>
 *   @param class where the location will be delivered, which implements BBLocationManagerDelegate
 *   @return gives an Dictionary using keys BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE
 */
- (void)getCurrentLocationWithDelegate:(id)delegate;


/**
 *   Returns current location
 *   <p>
 *   Gives location of device using the completion block
 *   </p>
 *   @param A block which will be called when the location is updated
 *   @return
 */
- (void)getCurrentLocationWithCompletion:(LocationUpdateBlock)completion;


/**
 *   Returns current location's geocode address
 *   <p>
 *   Gives the currents location's geocode addres using BBLocationManagerDelegate, uses Apple's own geocode API to get teh current address
 *   </p>
 *   @return BBLocationManagerDidUpdateGeocodeAdress is called when the location and geocode is updated
 */
- (void)getCurrentGeocodeAddressWithDelegate:(id)delegate;

/**
 *   Returns current location's geocode address
 *   <p>
 *   Gives the currents location's geocode addres using given block, uses Apple's own geocode API to get teh current address
 *   </p>
 *   @return Callback block is called when the location and geocode is updated
 */
- (void)getCurrentGeoCodeAddressWithCompletion:(GeoCodeUpdateBlock)completion;

/**
 *   Adds a geofence at the current location
 *   <p>
 *   First updates current location of the device, and then add it as a Geofence. Optionally also tries to determine the Geocode/Address. Default radios of the fence is set to 100 meters
 *   </p>
 *   <p>
 *   Checks if there is already a fence exists in this coordinate, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, reverse geocoding method may fail for too many request in small amount of time.
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */

- (void)addGeofenceAtCurrentLocation;

/**
 *   Adds a geofence at the current location with a radious
 *   <p>
 *   First updates current location of the device, and then add it as a Geofence. Optionally also tries to determine the Geocode/Address. Also sets the radious of the fence with given value
 *   </p>
 *   <p>
 *   Checks if there is already a fence exists in this coordinate, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, reverse geocoding method may fail for too many request in small amount of time.
 *   @param radious: The radious for the fence
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */
- (void)addGeofenceAtCurrentLocationWithRadious:(CLLocationDistance)radious;

/**
 *   Adds a geofence at given latitude/longitude, radious and indentifer.
 *   <p>
 *   Checks if there is already a fence exists in this coordinate, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, always deliver Identifier value, otherwise the reverse geocoding method may fail for too many request in small amount of time.
 *   @param latitude: The latitude where to add the fence
 *   @param longitude: The longitude where to add the fence
 *   @param radious: The radious for the fence
 *   @param identifier: The name of the fence. If the indentifier is nil, this method will try to use geocode to determine the address of this coordinate and use it as identifer. WARNING: When using this method for adding multiple fence at once, always deliver Identifier value
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */

- (void)addGeofenceAtlatitude:(double)latitude andLongitude:(double)longitude withRadious:(double)radious withIdentifier:(NSString*)identifier;


/**
 *   Adds a geofence at given latitude/longitude, radious and indentifer.
 *   <p>
 *   Checks if there is already a fence exists in this coordinate, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, always deliver Identifier value, otherwise the reverse geocoding method may fail for too many request in small amount of time.
 *   @param latitude: The latitude where to add the fence
 *   @param longitude: The longitude where to add the fence
 *   @param radious: The radious for the fence
 *   @param identifier: The name of the fence. If the indentifier is nil, this method will try to use geocode to determine the address of this coordinate and use it as identifer. WARNING: When using this method for adding multiple fence at once, always deliver Identifier value
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */
- (void)addGeofenceAtCurrentLocationWithRadious:(CLLocationDistance)radious withIdentifier:(NSString*)identifier;

/**
 *   Adds a geofence at given coordinate, radious and indentifer.
 *   <p>
 *   Checks if there is already a fence exists in this coordinate, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, always deliver Identifier value, otherwise the reverse geocoding method may fail for too many request in small amount of time.
 *   @param coordinate: The coordinate as CLLocationCoordinate2D where to add the fence
 *   @param radious: The radious for the fence
 *   @param identifier: The name of the fence. If the indentifier is nil, this method will try to use geocode to determine the address of this coordinate and use it as identifer. WARNING: When using this method for adding multiple fence at once, always deliver Identifier value
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */
- (void)addGeofenceAtCoordinates:(CLLocationCoordinate2D)coordinate withRadious:(CLLocationDistance)radious withIdentifier:(NSString*)identifier;

/**
 *   Adds a geofence at given location, radious and indentifer.
 *   <p>
 *   Checks if there is already a fence exists in this location, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, always deliver Identifier value, otherwise the reverse geocoding method may fail for too many request in small amount of time.
 *   @param location: The location where to add the fence
 *   @param radious: The radious for the fence
 *   @param identifier: The name of the fence. If the indentifier is nil, this method will try to use geocode to determine the address of this coordinate and use it as identifer. WARNING: When using this method for adding multiple fence at once, always deliver Identifier value
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */
- (void)addGeofenceAtLocation:(CLLocation*)location withRadious:(CLLocationDistance)radious withIdentifier:(NSString*)identifier;

/**
 *   Adds a geofence at a location, radious and indentifer using the FenceInfo object
 *   <p>
 *   Checks if there is already a fence exists in this location, if so, fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeRepeated event.
 *   </p>
 *   @warning When using this method for adding multiple fence at once, always deliver Identifier value, otherwise the reverse geocoding method may fail for too many request in small amount of time.
 *   @param fenceInfo: The location where to add the fence
 *   @return fires delegate BBLocationManagerDidAddFence: with a BBFenceEventTypeAdded event.
 */

-(void)addGeoFenceUsingFenceInfo:(BBFenceInfo*)fenceInfo;


/**
 *   Deletes a geofence at a location, using the FenceInfo object
 *   <p>
 *   It searches for the  identifiers of the added fences based on fenceInfo, and deletes the desired one.
 *   </p>
 *   @param fenceInfo: The location where to add the fence
 */

-(void)deleteGeoFence:(BBFenceInfo*)fenceInfo;

/**
 *   Deletes a geofence with a identifier
 *   <p>
 *   It searches for the  identifiers of the added fences, and deletes the desired one.
 *   </p>
 *   @param identifier: The identifier of the geofence need to be deleted
 */
-(void)deleteGeoFenceWithIdentifier:(NSString*)identifier;

@end
