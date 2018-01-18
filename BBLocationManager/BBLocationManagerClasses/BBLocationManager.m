//
//  BBLocationManager.m
//
//  Created by Benzamin on 4/15/15.
//  Copyright (c) 2015 Benzamin. All rights reserved.
//

#import "BBLocationManager.h"
#import <CoreLocation/CLGeocoder.h>
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define BB_TIMESTAMP_DDMMYYYYHHMMSS @"dd-MM-YYYY HH:mm:ss"

static inline BOOL isEmptyString( NSString * _Null_unspecified str)
{
    if(str.length==0 || [str isKindOfClass:[NSNull class]] || [str isEqualToString:@""]|| [str isEqualToString:@"(null)"]||str==nil || [str isEqualToString:@"<null>"]){
        return YES;
    }
    return NO;
}


//This enum is only used to track what kind of work I need to do inside
//the method -locationManager:didUpdateLocations:
typedef enum : NSUInteger {
    LocationTaskTypeGetCurrentLocation,
    LocationTaskTypeGetContiniousLocation,
    LocationTaskTypeGetSignificantChangeLocation,
    LocationTaskTypeAddFenceToCurrentLocation,
    LocationTaskTypeGetGeoCodeAddress,
    LocationTaskTypeNone
} LocationTaskType;

@interface BBLocationManager()<CLLocationManagerDelegate, UIAlertViewDelegate>
{
    BOOL _didStartMonitoringRegion;
    CLLocationDistance _radiousParam;
    NSString *_identifierParam;
    
    
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *geofences;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property(nonatomic, copy) LocationUpdateBlock locationCompletionBlock;
@property(nonatomic, copy) GeoCodeUpdateBlock geocodeCompletionBlock;
@property(nonatomic, assign) LocationTaskType activeLocationTaskType;

@end

@implementation BBLocationManager

@synthesize delegate = _delegate;

#pragma mark - Public methods

+ (instancetype)sharedManager {
    static BBLocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(instancetype)init
{
    if(self == [super init])
    {
        // Initialize Location Manager
        self.locationManager = [[CLLocationManager alloc] init];
        
        // Configure Location Manager
        [self.locationManager setDelegate:self];
        
        //setting the default distance filter
        [self setDistanceFilter:100];//setting it default to 100 meters
        
        //initially lets guess its 100 meters
        [self setDesiredAcuracy:100];
        
        //[self getPermissionForStartUpdatingLocation];
        
        self.activeLocationTaskType = LocationTaskTypeNone;
//        self.lastKnownGeocodeAddress = @{};
//        self.lastKnownGeoLocation = @;
        
        self.geofences = [NSMutableArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
        
        _didStartMonitoringRegion = NO;
        _radiousParam = 0;
        _identifierParam = nil;

    }
    
    return self;
}

-(void)getPermissionForStartUpdatingLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    //******************* IMPORTANT FOR iOS 11 ***************************//
    // 1. For app "WHEN IN USE" location access, you need to add "NSLocationWhenInUseUsageDescription" in info.plist
    // 2. But if you need "ALWAYS" location access, you need BOTH "NSLocationWhenInUseUsageDescription" and "NSLocationAlwaysAndWhenInUseUsageDescription"
    //    in your info.plist, other wise it'll encounter error: "This app has attempted to access privacy-sensitive data without a usage description ..... "
    // Ref: https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services#topics
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
    {
        if ((status == kCLAuthorizationStatusNotDetermined) && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
        {
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) { //https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/request_always_authorization
                if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                    [self.locationManager performSelector:@selector(requestAlwaysAuthorization)];
                }
                else{
                    [[NSException exceptionWithName:@"[BBLocationManager] Fix needed for location permission key" reason:@"Your app's info.plist need both NSLocationWhenInUseUsageDescription and NSLocationAlwaysAndWhenInUseUsageDescription keys for asking 'Always usage of location' in iOS 11" userInfo:nil] raise];
                }
                
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) { //https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_when_in_use_authorization
                [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            } else {
                [[NSException exceptionWithName:@"[BBLocationManager] Fix needed for location permission key" reason:@"Your app's info.plist does not contain NSLocationWhenInUseUsageDescription and/or NSLocationAlwaysAndWhenInUseUsageDescription key required for iOS 11" userInfo:nil] raise];
            }
        }
        else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
            NSLog(@"[BBLocationManager] Location Permission Denied by user, prompt user to allow location permission.");
            NSString *title, *message;
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
                message = [NSString stringWithFormat:@"%@. %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"], @"To use background location you must turn on 'Always' in the Location Services Settings"];
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location Service is not enabled";
                message = [NSString stringWithFormat:@"%@. %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"], @"To use location you must turn on 'While Using the App' in the Location Services Settings"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            [alertView show];
        }
    }
    //before iOS 8, no permission was needed to access location
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        if ((status == kCLAuthorizationStatusNotDetermined) && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
        {
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                [self.locationManager performSelector:@selector(requestAlwaysAuthorization)];
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            } else {
                [[NSException exceptionWithName:@"[BBLocationManager] Location Permission Error" reason:@"Info.plist does not contain NSLocationWhenUse or NSLocationAlwaysUsageDescription key required for iOS 8" userInfo:nil] raise];
            }
        }
        else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
            NSLog(@"[BBLocationManager] Location Permission Denied by user, prompt user to allow location permission.");
            NSString *title, *message;
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
                message = [NSString stringWithFormat:@"%@. %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"], @"To use background location you must turn on 'Always' in the Location Services Settings"];
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location Service is not enabled";
                message = [NSString stringWithFormat:@"%@. %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"], @"To use location you must turn on 'While Using the App' in the Location Services Settings"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            [alertView show];
        }
    }

}

#pragma mark - AlerView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

#pragma mark - Public Methods

-(NSDictionary*)location
{
    if(!self.locationManager.location)
        return nil;
    
    NSDictionary *locationDict = @{BB_LATITUDE:[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude] , BB_LONGITUDE:[NSNumber numberWithDouble: self.locationManager.location.coordinate.longitude] , BB_ALTITUDE:[NSNumber numberWithDouble:self.locationManager.location.altitude]};
    return locationDict;
}

-(void)setDistanceFilter:(double)distanceFilter
{
    _distanceFilter = distanceFilter;
    [self.locationManager setDistanceFilter:distanceFilter];
}

-(void)setDesiredAcuracy:(double)desiredAcuracy
{
    _desiredAcuracy = desiredAcuracy;
    if(desiredAcuracy < 50.0f) //1 to 49 meters
    {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    else if(desiredAcuracy >= 50.0f && desiredAcuracy < 100.0f) //50 to 99 meters
    {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    }
    else if(desiredAcuracy >= 100.0f && desiredAcuracy < 500.0f) //100 to 499 meters
    {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    }
    else if(desiredAcuracy >= 500.0f && desiredAcuracy <= 1000.0f) //500 to 1000 meters
    {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
    }
    else //greater then 1000 meters 
    {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    }
}

-(NSArray*)getCurrentFences
{
    NSArray *existingArray = [[self.locationManager monitoredRegions] allObjects];
    
    NSMutableArray *existingFenceInfoArray = [NSMutableArray arrayWithCapacity:existingArray.count];
    for (CLCircularRegion *currentRegion in existingArray)
    {
        [existingFenceInfoArray addObject:[self fenceInfoForRegion:currentRegion fenceEventType:BBFenceEventTypeNone]];
    }
    if(existingFenceInfoArray.count == 0) return nil;
    
    return existingFenceInfoArray;
}

-(void)deleteCurrentFences
{
    NSArray *existingArray = [[self.locationManager monitoredRegions] allObjects];
    for (CLCircularRegion *currentRegion in existingArray)
    {
        //we only want to delete all the fences those we created
        NSRange startRange = [currentRegion.identifier rangeOfString:@"BB: "];
        if(startRange.location != NSNotFound) //commenting this as we want to delete all the fences for now
        {
            // Stop Monitoring Region
            [self.locationManager stopMonitoringForRegion:currentRegion];
            
            // Update list
            [self.geofences removeObject:currentRegion];
        }
    }

}

- (void)getCurrentLocationWithDelegate:(id)delegate
{
    self.delegate = delegate;
    self.activeLocationTaskType = LocationTaskTypeGetCurrentLocation;
    //dont get confused between [self startUpdatingLocation] and [self.locationManager startUpdatingLocation]...I got confused once, and paid the price :(
    [self startUpdatingLocation];
}

- (void)getCurrentLocationWithCompletion:(LocationUpdateBlock)completion
{
    self.locationCompletionBlock = completion;
    self.activeLocationTaskType = LocationTaskTypeGetCurrentLocation;
    [self startUpdatingLocation];
}

- (void)getCurrentGeocodeAddressWithDelegate:(id)delegate
{
    self.delegate = delegate;
    self.activeLocationTaskType = LocationTaskTypeGetGeoCodeAddress;
    [self startUpdatingLocation];
    
}

- (void)getCurrentGeoCodeAddressWithCompletion:(GeoCodeUpdateBlock)completion
{
    self.geocodeCompletionBlock = completion;
    self.activeLocationTaskType = LocationTaskTypeGetGeoCodeAddress;
    [self startUpdatingLocation];
}
-(void)getContiniousLocationWithDelegate:(id)delegate
{
    self.delegate = delegate;
    self.activeLocationTaskType = LocationTaskTypeGetContiniousLocation;
    [self startUpdatingLocation];
}

-(void)getSingificantLocationChangeWithDelegate:(id)delegate
{
    self.delegate = delegate;
    self.activeLocationTaskType = LocationTaskTypeGetSignificantChangeLocation;
    [self startUpdatingLocation];
}

-(void)stopGettingLocation
{
    if(self.activeLocationTaskType == LocationTaskTypeGetContiniousLocation)
    {
        [self.locationManager stopUpdatingLocation];
    }
    else if(self.activeLocationTaskType == LocationTaskTypeGetSignificantChangeLocation)
    {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
    self.activeLocationTaskType = LocationTaskTypeNone;
}

- (void)addGeofenceAtCurrentLocation
{
    [self addGeofenceAtCurrentLocationWithRadious:BB_DEFAULT_FENCE_RADIOUS];
}

- (void)addGeofenceAtCurrentLocationWithRadious:(CLLocationDistance)radious
{
    [self setDesiredAcuracy:radious];
    
    [self addGeofenceAtCurrentLocationWithRadious:radious withIdentifier:nil];
    
}

- (void)addGeofenceAtCurrentLocationWithRadious:(CLLocationDistance)radious withIdentifier:(NSString*)identifier
{
    //store the radious and identifier
    _radiousParam = radious;
    _identifierParam = identifier;

    // Update Helper
    _didStartMonitoringRegion = NO;
    
    // Start Updating Location, once we get a location, we'll add a fence
    self.activeLocationTaskType = LocationTaskTypeAddFenceToCurrentLocation;
    [self startUpdatingLocation];
}

- (void)addGeofenceAtlatitude:(double)latitude andLongitude:(double)longitude withRadious:(double)radious withIdentifier:(NSString*)identifier
{
    [self addGeofenceAtCoordinates:CLLocationCoordinate2DMake(latitude, longitude) withRadious:radious withIdentifier:identifier];
}

- (void)addGeofenceAtCoordinates:(CLLocationCoordinate2D)coordinate withRadious:(CLLocationDistance)radious withIdentifier:(NSString*)identifier
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self addGeofenceAtLocation:location withRadious:radious withIdentifier:identifier];
}

- (void)addGeofenceAtLocation:(CLLocation*)location withRadious:(CLLocationDistance)radious withIdentifier:(NSString*)identifier
{

    /*------------------first check if we already have these coordinates inside existing regions----------*/
    CLCircularRegion *currentRegion = [self isFenceExistsForCoordinates:location.coordinate];
    if(currentRegion != nil)
    {
        NSLog(@"[BBLocationManager] Fence already exist for area: %@ ---- inside: %@", identifier, currentRegion.identifier);
        if([self.delegate respondsToSelector:@selector(BBLocationManagerDidAddFence:)])
        {
            [self.delegate BBLocationManagerDidAddFence:[self fenceInfoForRegion:currentRegion fenceEventType:BBFenceEventTypeRepeated]];
        }
        return;
    }
    
    
    /*------------------if this coordinates doesnot already added to a geofence, start the fence---------------------*/

    //if there is a identifier provided, don't try to geocode the location
    if(!isEmptyString(identifier))
    {
        [self startMonitoringRegionWithCeter:location.coordinate radious:radious identifier:identifier];
    }
    
    //no identifier provided, try to geocode the location
    else
    {
        __block CLLocationCoordinate2D loc = location.coordinate;
        __block double rad = radious;
        
        if (!self.geocoder)
        {
            self.geocoder = [[CLGeocoder alloc] init];
        }
        BBLocationManager * __weak weakSelf = self;
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
            
            if ([placemarks count] > 0)
            {
                //got a adddress
                CLPlacemark *mark = (CLPlacemark*)[placemarks objectAtIndex:0];// read the most confident one
                NSString *name = mark.name ? mark.name : @"$" ;
                NSString *thoroughfare = mark.thoroughfare ? mark.thoroughfare : @"$" ;
                NSString *subLocality = mark.subLocality ? mark.subLocality : @"$" ;
                NSString *locality = mark.locality ? mark.locality : @"$" ;
                NSString *subAdministrativeArea = mark.subAdministrativeArea ? mark.subAdministrativeArea : @"$" ;
                NSString *administrativeArea = mark.administrativeArea ? mark.administrativeArea : @"$" ;
                NSString *postalcode = mark.postalCode ? mark.postalCode : @"$" ;
                NSString *ISOcountryCode = mark.ISOcountryCode ? mark.ISOcountryCode : @"$" ;
                
                NSString *address = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@",name, thoroughfare, subLocality, locality, subAdministrativeArea, administrativeArea, postalcode, ISOcountryCode];
                address = [address stringByReplacingOccurrencesOfString:@"$," withString:@""];
                
                [weakSelf startMonitoringRegionWithCeter:loc radious:rad identifier:!isEmptyString(address) ? address : [NSString stringWithFormat:@"%lf_%lf_%lf", loc.latitude, loc.longitude, rad]];
                
            }
            else
            {
                [weakSelf startMonitoringRegionWithCeter:loc radious:rad identifier:[NSString stringWithFormat:@"%lf_%lf_%lf", loc.latitude, loc.longitude, rad]];
            }
            
        }];
    
    }
}

- (void)getGeoCodeAtLocation:(CLLocation*)location
{
    if (!self.geocoder)
    {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    BBLocationManager * __weak weakSelf = self;
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
        
        if ([placemarks count] > 0)
        {
            //got a adddress
            
            CLPlacemark *mark = (CLPlacemark*)[placemarks objectAtIndex:0];// read the most confident one
            NSString *name = mark.name ? mark.name : @"" ;
            NSString *thoroughfare = mark.thoroughfare ? mark.thoroughfare : @"" ;
            NSString *locality = mark.locality ? mark.locality : @"" ;
            NSString *subAdministrativeArea = mark.subAdministrativeArea ? mark.subAdministrativeArea : @"" ;
            NSString *administrativeArea = mark.administrativeArea ? mark.administrativeArea : @"" ;
            NSString *postalcode = mark.postalCode ? mark.postalCode : @"" ;
            NSString *country = mark.country ? mark.country : @"" ;
            //NSLog(@"Updated Address:%@", mark.addressDictionary.description);
            
            weakSelf.lastKnownGeocodeAddress = @{BB_LATITUDE    : [NSNumber numberWithDouble:location.coordinate.latitude],
                                                 BB_LONGITUDE    : [NSNumber numberWithDouble:location.coordinate.longitude],
                                                 BB_ALTITUDE    : [NSNumber numberWithDouble:location.altitude],
                                                 BB_ADDRESS_NAME    : name,
                                                 BB_ADDRESS_STREET  : thoroughfare,
                                                 BB_ADDRESS_CITY    : locality,
                                                 BB_ADDRESS_STATE   : administrativeArea,
                                                 BB_ADDRESS_COUNTY  : subAdministrativeArea,
                                                 BB_ADDRESS_ZIPCODE : postalcode,
                                                 BB_ADDRESS_COUNTY  : country,
                                                 BB_ADDRESS_DICTIONARY: mark.addressDictionary
                                                 };
            
        }
        else
        {
            weakSelf.lastKnownGeocodeAddress = @{
                                                 BB_LATITUDE    : @0,
                                                 BB_LONGITUDE    : @0,
                                                 BB_ALTITUDE    : @0,
                                                 BB_ADDRESS_NAME    : @"Unknown",
                                                 BB_ADDRESS_STREET  : @"Unknown",
                                                 BB_ADDRESS_CITY    : @"Unknown",
                                                 BB_ADDRESS_STATE   : @"Unknown",
                                                 BB_ADDRESS_COUNTY  : @"Unknown",
                                                 BB_ADDRESS_ZIPCODE : @"Unknown",
                                                 BB_ADDRESS_COUNTY  : @"Unknown",
                                                 BB_ADDRESS_DICTIONARY: @{}
                                                 };
            
            
        }
        
        //send through delegate
        if([weakSelf.delegate respondsToSelector:@selector(BBLocationManagerDidUpdateGeocodeAdress:)])
        {
            [weakSelf.delegate BBLocationManagerDidUpdateGeocodeAdress:[NSDictionary dictionaryWithDictionary: weakSelf.lastKnownGeocodeAddress]];
        }
        if(weakSelf.geocodeCompletionBlock != nil)
        {
            self.geocodeCompletionBlock(error ? false : true, [NSDictionary dictionaryWithDictionary: weakSelf.lastKnownGeocodeAddress], error);
        }
        
        
    }];
    
}


-(void)addGeoFenceUsingFenceInfo:(BBFenceInfo*)fenceInfo
{
    CLLocationCoordinate2D coordinate = [self locationCoordinate2dFromFenceInfo:fenceInfo];
    [self addGeofenceAtCoordinates:coordinate withRadious:[[fenceInfo.fenceCoordinate objectForKey:BB_RADIOUS] doubleValue] withIdentifier:fenceInfo.fenceIDentifier];
}

-(void)deleteGeoFenceWithIdentifier:(NSString*)identifier
{
    NSArray *existingArray = [[self.locationManager monitoredRegions] allObjects];
    for (CLCircularRegion *currentRegion in existingArray)
    {
        NSRange startRange = [currentRegion.identifier rangeOfString:identifier];
        if(startRange.location != NSNotFound)
        {
            // Stop Monitoring Region
            [self.locationManager stopMonitoringForRegion:currentRegion];
            
            // Update list
            [self.geofences removeObject:currentRegion];
        }
    }

}

-(void)deleteGeoFence:(BBFenceInfo*)fenceInfo
{
    [self deleteGeoFenceWithIdentifier:[NSString stringWithFormat:@"BB: %@", fenceInfo.fenceIDentifier]];
}


#pragma mark -
#pragma mark - Internal Methods

- (void)startUpdatingLocation
{
    [self getPermissionForStartUpdatingLocation];
    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) {
        if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"])
        {
            BOOL hasLocationBackgroundMode = NO;
            NSArray *bgmodesArray = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
            for(NSString *str in bgmodesArray)
            {
                if([str isEqualToString:@"location"])
                {
                    hasLocationBackgroundMode = YES;
                    break;
                }
            }
            if(!hasLocationBackgroundMode)
            {
                [[NSException exceptionWithName:@"[BBLocationManager] UIBackgroundModes not enabled" reason:@"Your apps info.plist does not contain 'UIBackgroundModes' key with a 'location' string in it, which is required for background location access 'NSLocationAlwaysAndWhenInUseUsageDescription' for iOS 11 or 'NSLocationAlwaysUsageDescription' for iOS 10" userInfo:nil] raise];
            }
            else{
                if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
                {
                    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
                }
            }
        }
        else{
            [[NSException exceptionWithName:@"[BBLocationManager] UIBackgroundModes not enabled" reason:@"Your apps info.plist does not contain 'UIBackgroundModes' key with a 'location' string in it, which is required for background location access 'NSLocationAlwaysAndWhenInUseUsageDescription' for iOS 11 or 'NSLocationAlwaysUsageDescription' for iOS 10" userInfo:nil] raise];
        }

    }
    
    if(self.activeLocationTaskType == LocationTaskTypeGetSignificantChangeLocation)
    {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
}


-(void)startMonitoringRegionWithCeter:(CLLocationCoordinate2D)center radious:(CLLocationDistance)radious identifier:(NSString*)identifier
{
    CLRegion * region ;
    region = [[CLCircularRegion alloc] initWithCenter:center radius:radious identifier:[NSString stringWithFormat:@"BB: %@", identifier]];
    
    
    // Start Monitoring Region
    [self.locationManager startMonitoringForRegion:region];
    
    //update array
    [self.geofences addObject:region];
}

-(BBFenceInfo*)fenceInfoForRegion:(CLRegion*)fenceRegion fenceEventType:(BBFenceEventType)type
{
    CLCircularRegion *region = (CLCircularRegion*)fenceRegion;
    BBFenceInfo *info = [[BBFenceInfo alloc] init];
    info.eventTimeStamp = [self currentTimeStampWithFormat:BB_TIMESTAMP_DDMMYYYYHHMMSS];
    info.eventType = BB_GET_FENCE_EVENT_STRING(type);
    info.fenceIDentifier = region.identifier;
    info.fenceCoordinate = @{ BB_LATITUDE:[NSNumber numberWithDouble: region.center.latitude], BB_LONGITUDE:[NSNumber numberWithDouble: region.center.longitude], BB_RADIOUS:[NSNumber numberWithDouble: region.radius]};

    return info;
}

-(CLCircularRegion*)isFenceExistsForCoordinates:(CLLocationCoordinate2D)coordinate
{
    NSArray *existingArray = [[self.locationManager monitoredRegions] allObjects];
    for (CLCircularRegion *currentRegion in existingArray)
    {
        if([currentRegion containsCoordinate:coordinate])
        {
            return currentRegion;
        }
    }
    return nil;
    
}

-(CLLocationCoordinate2D)locationCoordinate2dFromFenceInfo:(BBFenceInfo*)fenceInfo
{
    return CLLocationCoordinate2DMake([[fenceInfo.fenceCoordinate objectForKey:BB_LATITUDE] doubleValue], [[fenceInfo.fenceCoordinate objectForKey:BB_LONGITUDE] doubleValue]);
}
#pragma mark - CLLocationManagerDelegate methods


#warning check out this one https://stackoverflow.com/questions/22292835/how-to-stop-multiple-times-method-calling-of-didupdatelocations-in-ios

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations && [locations count] >= 1)
    {
        // Fetch Current Location
        CLLocation *location = [locations lastObject];
        
        if(self.activeLocationTaskType == LocationTaskTypeGetGeoCodeAddress)
        {
            // Initialize Region/fence to Monitor
            [self getGeoCodeAtLocation:location];
            
            //stop getting/updating location data, means stop the GPS :)
            [self.locationManager stopUpdatingLocation];
            self.activeLocationTaskType = LocationTaskTypeNone;
        }

        
        else if(self.activeLocationTaskType == LocationTaskTypeAddFenceToCurrentLocation)
        {
            if(!_didStartMonitoringRegion)
            {
                // Update Helper
                _didStartMonitoringRegion = YES;
                
                
                // Initialize Region/fence to Monitor
                [self addGeofenceAtLocation:location withRadious:_radiousParam withIdentifier:_identifierParam];
                
                //stop getting/updating location data, means stop the GPS :)
                [self.locationManager stopUpdatingLocation];
                self.activeLocationTaskType = LocationTaskTypeNone;
            }
        }
        
        else if(self.activeLocationTaskType == LocationTaskTypeGetCurrentLocation)
        {
            NSDictionary *locationDict = @{BB_LATITUDE:[NSNumber numberWithDouble:location.coordinate.latitude] , BB_LONGITUDE:[NSNumber numberWithDouble: location.coordinate.longitude] , BB_ALTITUDE:[NSNumber numberWithDouble:location.altitude]};
            self.lastKnownGeoLocation = locationDict;
            
            if([self.delegate respondsToSelector:@selector(BBLocationManagerDidUpdateLocation:)])
            {
                [self.delegate BBLocationManagerDidUpdateLocation:locationDict];
            }
            if(self.locationCompletionBlock != nil)
            {
                self.locationCompletionBlock(true, locationDict, nil);
            }
            //stop getting/updating location data, means stop the GPS
            [self.locationManager stopUpdatingLocation];
            self.activeLocationTaskType = LocationTaskTypeNone;

            
        }
        else if((self.activeLocationTaskType == LocationTaskTypeGetContiniousLocation) || (self.activeLocationTaskType == LocationTaskTypeGetSignificantChangeLocation))
        {
            NSDictionary *locationDict = @{BB_LATITUDE:[NSNumber numberWithDouble:location.coordinate.latitude] , BB_LONGITUDE:[NSNumber numberWithDouble: location.coordinate.longitude] , BB_ALTITUDE:[NSNumber numberWithDouble:location.altitude]};
            self.lastKnownGeoLocation = locationDict;
            
            if([self.delegate respondsToSelector:@selector(BBLocationManagerDidUpdateLocation:)])
            {
                [self.delegate BBLocationManagerDidUpdateLocation:locationDict];
            }
        }
        else
        {
            self.activeLocationTaskType = LocationTaskTypeNone;
        }
        

        
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(BBLocationManagerDidUpdateLocation:)])
    {
        [self.delegate BBLocationManagerDidUpdateLocation:@{BB_LATITUDE:[NSNumber numberWithDouble:0.0f] , BB_LONGITUDE:[NSNumber numberWithDouble:0.0f] , BB_ALTITUDE:[NSNumber numberWithDouble:0.0f]}];
    }
    if(self.locationCompletionBlock != nil)
    {
        self.locationCompletionBlock(false, nil, error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    CLCircularRegion *theRegion = (CLCircularRegion*)region;
    if([self.delegate respondsToSelector:@selector(BBLocationManagerDidAddFence:)])
    {
        [self.delegate BBLocationManagerDidAddFence:[self fenceInfoForRegion:theRegion fenceEventType:BBFenceEventTypeAdded]];
    }


    /*NSString *str = [NSString stringWithFormat:@"Added region %@, lat-long-radious:%@", region.identifier,[NSString stringWithFormat:@"%.1f - %.1f - %f", region.center.latitude, region.center.longitude, region.radius]];
    [[[UIAlertView alloc] initWithTitle:@"Gefence Alert" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        //NSLog(str);*/
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    CLCircularRegion *theRegion = (CLCircularRegion*)region;
    if([self.delegate respondsToSelector:@selector(BBLocationManagerDidFailedFence:)])
    {
        [self.delegate BBLocationManagerDidFailedFence:[self fenceInfoForRegion:theRegion fenceEventType:BBFenceEventTypeFailed]];
    }
    

    /*NSString *str = [NSString stringWithFormat:@"Failed region %@, lat-long-radious:%@", region.identifier,[NSString stringWithFormat:@"%.1f - %.1f - %f", region.center.latitude, region.center.longitude, region.radius]];
    [[[UIAlertView alloc] initWithTitle:@"Gefence Alert" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    NSLog(str);*/
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    CLCircularRegion *theRegion = (CLCircularRegion*)region;
    if([self.delegate respondsToSelector:@selector(BBLocationManagerDidEnterFence:)])
    {
        [self.delegate BBLocationManagerDidEnterFence:[self fenceInfoForRegion:theRegion fenceEventType:BBFenceEventTypeEnterFence]];
    }
    

    /*NSString *str = [NSString stringWithFormat:@"Entered region %@, lat-long-radious:%@", theRegion.identifier,[NSString stringWithFormat:@"%.1f - %.1f - %f", theRegion.center.latitude, theRegion.center.longitude, theRegion.radius]];
    [[[UIAlertView alloc] initWithTitle:@"Gefence Alert" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    [BBUtility initiateLocalNotification:str withDate:[NSDate date] badgeCount:1 withEventType:@"Region-Enter"];
    NSLog(str);*/
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    CLCircularRegion *theRegion = (CLCircularRegion*)region;
    if([self.delegate respondsToSelector:@selector(BBLocationManagerDidExitFence:)])
    {
        [self.delegate BBLocationManagerDidExitFence:[self fenceInfoForRegion:theRegion fenceEventType:BBFenceEventTypeExitFence]];
    }
    
/*    NSString *str = [NSString stringWithFormat:@"Exit region %@, lat-long-radious:%@", theRegion.identifier,[NSString stringWithFormat:@"%.1f - %.1f - %f", theRegion.center.latitude, theRegion.center.longitude, theRegion.radius]];
    [[[UIAlertView alloc] initWithTitle:@"Gefence Alert" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    [BBUtility initiateLocalNotification:str withDate:[NSDate date] badgeCount:1 withEventType:@"Region-exit"];
    NSLog(str);*/
    
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside)
    {
        //NSLog(@"[BBLocationManager] Entered Region - %@", region.identifier);
    }
    else if(state == CLRegionStateOutside)
    {
        //NSLog(@"[BBLocationManager] Exited Region - %@", region.identifier);
    }
    else{
        //NSLog(@"[BBLocationManager] Unknown state  Region - %@", region.identifier);
    }
    
}

#pragma mark -
#pragma mark - Helper Functions.
- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}

+ (BOOL)locationPermission
{
    BOOL isPermitted = YES;
    
    if(![CLLocationManager locationServicesEnabled])
    {
        //You need to enable Location Services
        return NO;
    }
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        //Region monitoring is not available for this Class;
    }
    
    
    CLAuthorizationStatus locationPermission = [CLLocationManager authorizationStatus];
    
    if ((locationPermission == kCLAuthorizationStatusRestricted) || (locationPermission == kCLAuthorizationStatusDenied)) {
        isPermitted = NO;
    }
    
    if (isPermitted && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && locationPermission == kCLAuthorizationStatusNotDetermined) {
        isPermitted = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"];
    }
    
    return isPermitted;
}

-(void)dealloc
{
    
}

-(NSString*)currentTimeStampWithFormat:(NSString*)format
{
    NSDateFormatter *dateFormattter = [[NSDateFormatter alloc] init];
    
    //[dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    [dateFormattter setDateFormat:format];
    
    return [dateFormattter stringFromDate:[NSDate date]];
}


@end

@implementation BBFenceInfo

- (NSDictionary *)dictionary
{
    return @{ BB_FENCE_EVENT_TYPE_KEY         : self.eventType ? _eventType : [NSNull null],
              BB_FENCE_EVENT_TIMESTAMP_KEY    : self.eventTimeStamp ? _eventTimeStamp : [NSNull null],
              BB_FENCE_IDENTIFIER_KEY         : self.fenceIDentifier ? _fenceIDentifier : [NSNull null],
              BB_FENCE_COORDINATE_KEY         : self.fenceCoordinate ? _fenceCoordinate : [NSNull null] };
    
}
@end

