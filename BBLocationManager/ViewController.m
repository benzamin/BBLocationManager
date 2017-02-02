//
//  ViewController.m
//  BBLocationManager
//
//  Created by Benzamin Basher on 1/29/17.
//  Copyright © 2017 Benzamin Basher. All rights reserved.
//

#import "ViewController.h"
#import "BBLocationManager.h"


@interface ViewController () <BBLocationManagerDelegate> //use this if you want to get response from delegate not from block
@property(nonatomic, weak) IBOutlet UITextView *logTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BBLocationManager *manager = [BBLocationManager sharedManager];
    manager.delegate = self; //not mandatory here, just to get the delegate calls
}

-(IBAction)showAllGeoFences:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    
    NSArray *geoFences = [manager getCurrentFences];
    for (BBFenceInfo *geofence in geoFences)
    {
        NSString *txt = [NSString stringWithFormat:@"Geofence '%@' is Active at Coordinates: %@:%@ with %@ meter radious", geofence.fenceIDentifier, [geofence.fenceCoordinate objectForKey:BB_LATITUDE],[geofence.fenceCoordinate objectForKey:BB_LONGITUDE], [geofence.fenceCoordinate objectForKey:BB_RADIOUS]];
        NSLog(@"%@", txt);
        [self logtext:txt];
    }
    if(geoFences.count == 0) [self logtext:@"No Geofence is added currently"];
}

-(IBAction)addFenceGeoatCurrentLocation:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    manager.delegate = self;
    [manager addGeofenceAtCurrentLocationWithRadious:100];
    //[manager addGeofenceAtCoordinates:CLLocationCoordinate2DMake(59.331981f, 18.068435f) withRadious:100 withIdentifier:nil];
    
}

-(IBAction)removeAllGeofence:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    
    NSArray *geoFences = [manager getCurrentFences];
    
    for (BBFenceInfo *geofence in geoFences)
    {
        [manager deleteGeoFenceWithIdentifier:geofence.fenceIDentifier];
    }
    [self logtext:@"All Geofences deleted!"];
}

-(IBAction)getCurrentLocation:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getCurrentLocationWithCompletion:^(BOOL success, NSDictionary *latLongAltitudeDictionary, NSError *error) {
        
        [self logtext:[NSString stringWithFormat:@"Current Location: %@", latLongAltitudeDictionary.description]];
    }];
    //[manager getCurrentLocationWithDelegate:self]; //can be used
}

-(IBAction)getCurrentGeoFence:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getCurrentGeoCodeAddressWithCompletion:^(BOOL success, NSDictionary *addressDictionary, NSError *error) {
        [self logtext:[NSString stringWithFormat:@"Current Location GeoCode/Address: %@", addressDictionary.description]];
    }];
    //[manager getCurrentLocationWithDelegate:self]; //can be used
}


-(void)logtext:(NSString*)text
{
    self.logTextView.text = text;
}

#pragma mark - BBLocationManagerDelegate

-(void)BBLocationManagerDidAddFence:(BBFenceInfo *)fenceInfo
{
    NSString *text = [NSString stringWithFormat:@"Added GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
}

-(void)BBLocationManagerDidFailedFence:(BBFenceInfo *)fenceInfo
{
    NSString *text = [NSString stringWithFormat:@"Failed to add GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
}


-(void)BBLocationManagerDidEnterFence:(BBFenceInfo *)fenceInfo
{
    NSString *text = [NSString stringWithFormat:@"Entered GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
    [[[UIAlertView alloc] initWithTitle:@"Enter Fence" message:text delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}


-(void)BBLocationManagerDidExitFence:(BBFenceInfo *)fenceInfo
{
    NSString *text =[NSString stringWithFormat:@"Exit GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
    [[[UIAlertView alloc] initWithTitle:@"Exit Fence" message:text delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}


-(void)BBLocationManagerDidUpdateLocation:(NSDictionary *)latLongAltitudeDictionary
{
    NSLog(@"Current Location: %@", latLongAltitudeDictionary.description);
}


-(void)BBLocationManagerDidUpdateGeocodeAdress:(NSDictionary *)addressDictionary
{
     NSLog(@"Current Location GeoCode/Address: %@", addressDictionary.description);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
