//
//  BBLocationManager.h
//
//  Created by Benzamin on 4/15/15.
//  Copyright (c) 2015 Benzamin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define BB_FENCE_EVENT_TYPE_KEY @"BBeventType"
#define BB_FENCE_EVENT_TIMESTAMP_KEY @"BBeventTimeStamp"
#define BB_FENCE_IDENTIFIER_KEY @"BBfenceIDentifier"
#define BB_FENCE_COORDINATE_KEY @"BBfenceCoordinate"

#define BB_GET_FENCE_EVENT_STRING(fenceEventTypeEnum) [@[ @"BBFenceEventAdded", @"BBFenceEventRemoved",@"BBFenceEventFailed", @"BBFenceEventRepeated", @"BBFenceEventEnterFence",@"BBFenceEventExitFence", @"BBFenceEventNone"] objectAtIndex:(fenceEventTypeEnum)]

typedef enum : NSUInteger {
    BBFenceEventTypeAdded,
    BBFenceEventTypeRemoved,
    BBFenceEventTypeFailed,
    BBFenceEventTypeRepeated,
    BBFenceEventTypeEnterFence,
    BBFenceEventTypeExitFence,
    BBFenceEventTypeNone
} BBFenceEventType;

@interface BBFenceInfo : NSObject


@property(nonatomic, assign) NSString *eventType;
@property(nonatomic, strong) NSString *eventTimeStamp;
@property(nonatomic, strong) NSString *fenceIDentifier;
@property(nonatomic, strong) NSDictionary *fenceCoordinate;//uses BB_LATITUDE,  BB_LONGITUDE, BB_RADIOUS to wrap data

- (NSDictionary*)dictionary;



@end


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
@required
/**
 *   Gives an Location Dictionary using keys "latitude", "longitude" and "altitude". You can use these macros: BB_LATITUDE, BB_LONGITUDE and BB_ALTITUDE.
 *   Sample output dictionary @{ @"latitude" : 23.6850, "longitude" : 90.3563, "altitude" : 10.4604}
 */
-(void)BBLocationManagerDidUpdateLocation:(NSDictionary *)latLongAltitudeDictionary;

@optional
/**
 *   Gives an BBFenceInfo Object of the Fence which just added
 */
-(void)BBLocationManagerDidAddFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an BBFenceInfo Object of the Fence which just failed to monitor
 */
-(void)BBLocationManagerDidFailedFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an BBFenceInfo Object of a Fence just entered
 */
-(void)BBLocationManagerDidEnterFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an BBFenceInfo Object of a Exited Fence
 */
-(void)BBLocationManagerDidExitFence:(BBFenceInfo *)fenceInfo;


/**
 *   Gives an Dictionary using current geocode or adress information with BB_ADDRESS_* keys
 */
-(void)BBLocationManagerDidUpdateGeocodeAdress:(NSDictionary *)addressDictionary;


@end

@interface BBLocationManager : NSObject
{
    
    __weak id <BBLocationManagerDelegate> _delegate;
}

/**
 *  The delegate, using this the location events are fired.
 */
@property (nonatomic, weak) id <BBLocationManagerDelegate> delegate;

/**
 *  The last known Geocode address determinded, will be nil if there is no geocode was requested.
 */
@property (nonatomic, strong) NSDictionary *lastKnownGeocodeAddress;

/**
 *  The last known location received. Will be nil until a location has been received. Returns an Dictionary using keys BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE
 */
@property (nonatomic, strong) NSDictionary *lastKnownGeoLocation;

/**
 *  Similar to lastKnownLocation, The last location received. Will be nil until a location has been received. Returns an Dictionary using keys BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE
 */
@property (nonatomic, strong) NSDictionary *location;

/**
*   The desired location accuracy in meters. Default is 100 meters.
 *<p>
 *The location service will try its best to achieve
    your desired accuracy. However, it is not guaranteed. To optimize
    power performance, be sure to specify an appropriate accuracy for your usage scenario (eg, use a large accuracy value when only a coarse location is needed). Set it to 0 to achieve the best possible accuracy.
 *</p>
*/
@property(nonatomic, assign) double desiredAcuracy;

/**
 *  Specifies the minimum update distance in meters. Client will not be notified of movements of less
    than the stated value, unless the accuracy has improved. Pass in 0 to be
    notified of all movements. By default, 100 meters is used.
 */
@property(nonatomic, assign) double distanceFilter;

/**
 *   Returns a singeton(static) instance of the BBLocationManager
 *   <p>
 *   Returns a singeton(static) instance of the BBLocationManager
 *   </p>
 *   @return singeton(static) instance of the BBLocationManager
 */
+ (instancetype)sharedManager;


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
 *   Returns current location through the BBLocationManagerDelegate, can be adjusted using the desiredAcuracy and distanceFilter properties.
 *   <p>
 *   Gives location of device using delegate BBLocationManagerDidUpdateLocation:
 *   </p>
 *   @param class where the location will be delivered, which implements BBLocationManagerDelegate
 *   @return gives an Dictionary using keys BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE
 */
- (void)getCurrentLocationWithDelegate:(id)delegate;


/**
 *   Returns current location, can be adjusted using the desiredAcuracy and distanceFilter properties.
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
 *   Returns current location continiously through BBLocationManagerDidUpdateLocation method, can be adjusted using the desiredAcuracy and distanceFilter properties.
 *   <p>
 *   Gives the current location continiously until the -stopGettingLocation is called
 *   </p>
 *   @return Callback block is called when the location and geocode is updated
 */
-(void)getContiniousLocationWithDelegate:(id)delegate;

/**
 *   Start monitoring significant location changes.  The behavior of this service is not affected by the desiredAccuracy
    or distanceFilter properties. Returns location if user's is moved significantly, through BBLocationManagerDidUpdateLocation delegate call. Gives the significant location change continiously until the -stopGettingLocation is called
 *  <p>
 *  Apps can expect a notification as soon as the device moves 500 meters or more from its previous notification. It should not expect notifications more frequently than once every 5 minutes. If the device is able to retrieve data from the network, the location manager is much more likely to deliver notifications in a timely manner. (from Apple Doc)
 *  </p>
 */
-(void)getSingificantLocationChangeWithDelegate:(id)delegate;


/**
 *   Stops updating location for Continious or Significant changes
 *   <p>
 *   Use this method to stop accessing and getting the location data continiously. If you've called -getContiniousLocationWithDelegate: or -getSingificantLocationChangeWithDelegate: method before, call -stopGettingLocation method to stop that.
 *   </p>
*/
-(void)stopGettingLocation;

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
