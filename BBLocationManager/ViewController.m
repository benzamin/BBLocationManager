//
//  ViewController.m
//  BBLocationManager
//
//  Created by Benzamin Basher on 1/29/17.
//  Copyright © 2017 Benzamin Basher. All rights reserved.
//

#import "ViewController.h"
#import "BBLocationManager.h"

@interface BBLocationManager ()

//**********HACKY WAY to delete the fences, overriding private method, used here for debug purpose only******************//
-(void)deleteGeoFenceWithIdentifier:(NSString*)identifier;
@end

@interface ViewController () //<BBLocationManagerDelegate> //use this if you want to get response from delegate not from block

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)showAllGeoFences:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    
    NSArray *geoFences = [manager getCurrentFences];
    for (BBFenceInfo *geofence in geoFences)
    {
        NSLog(@"Geofence '%@' is Active at Coordinates: %@:%@ with %@ meter radious", geofence.fenceIDentifier, [geofence.fenceCoordinate objectForKey:BB_LATITUDE],[geofence.fenceCoordinate objectForKey:BB_LONGITUDE], [geofence.fenceCoordinate objectForKey:BB_RADIOUS]);
        
    }
}

-(IBAction)addFenceGeoatCurrentLocation:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
     
    if([BBLocationManager locationPermission])
    {
        [manager addGeofenceAtCurrentLocationWithRadious:30];
        [manager addGeofenceAtCoordinates:CLLocationCoordinate2DMake(59.331981f, 18.068435f) withRadious:100 withIdentifier:nil];
    }
    
    
}

-(IBAction)removeAllGeofence:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    
    NSArray *geoFences = [manager getCurrentFences];
    
    for (BBFenceInfo *geofence in geoFences)
    {
        //hacky method call :)
        [manager deleteGeoFenceWithIdentifier:geofence.fenceIDentifier];
    }
}

-(IBAction)getCurrentLocation:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getCurrentLocationWithCompletion:^(BOOL success, NSDictionary *locationDictionary, NSError *error) {
        NSLog(@"Location Updated: %@", locationDictionary.description);
    }];
    //[manager getCurrentLocationWithDelegate:self]; //can be used
}

-(IBAction)getCurrentGeoFence:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getCurrentGeoCodeAddressWithCompletion:^(BOOL success, NSDictionary *locationDictionary, NSError *error) {
        NSLog(@"Location GeoFence Address: %@", locationDictionary.description);
    }];
    //[manager getCurrentLocationWithDelegate:self]; //can be used
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
