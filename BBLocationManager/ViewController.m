//
//  ViewController.m
//  BBLocationManager
//
//  Created by Benzamin Basher on 1/29/17.
//  Copyright © 2017 Benzamin Basher. All rights reserved.
//

#import "ViewController.h"
#import "BBLocationManager.h"
#import <MapKit/MapKit.h>

@interface ViewController () <BBLocationManagerDelegate> //use this if you want to get response from delegate not from block
@property(nonatomic, weak) IBOutlet UITextView *logTextView;
@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) MKPointAnnotation *annotation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BBLocationManager *manager = [BBLocationManager sharedManager];
    manager.delegate = self; //not mandatory here, just to get the delegate calls
    
    [self.mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.mapView.layer.cornerRadius = 6.0f;
    self.annotation = [[MKPointAnnotation alloc] init];
    
}

-(IBAction)showAllGeoFences:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    
    NSArray *geoFences = [manager getCurrentFences];
    NSString *allFencetxt = @"All fences: ";
    for (BBFenceInfo *geofence in geoFences)
    {
        NSString *txt = [NSString stringWithFormat:@"Geofence '%@' is Active at Coordinates: %@:%@ with %@ meter radious \n", geofence.fenceIDentifier, [geofence.fenceCoordinate objectForKey:BB_LATITUDE],[geofence.fenceCoordinate objectForKey:BB_LONGITUDE], [geofence.fenceCoordinate objectForKey:BB_RADIOUS]];
        NSLog(@"%@", txt);
        allFencetxt = [allFencetxt stringByAppendingString:txt];
    }
    [self logtext:allFencetxt];
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
        [self showInMapsWithDictionary:latLongAltitudeDictionary title:@"Current Location"];
    }];
    //[manager getCurrentLocationWithDelegate:self]; //can be used
}

-(IBAction)getCurrentGeoCodeAddress:(id)sender
{
    
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getCurrentGeoCodeAddressWithCompletion:^(BOOL success, NSDictionary *addressDictionary, NSError *error) {
        //access the dict using BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE
        [self logtext:[NSString stringWithFormat:@"Current Location GeoCode/Address: %@", addressDictionary.description]];
        [self showInMapsWithDictionary:addressDictionary title:@"Geocode/Address"];
    }];
    //[manager getCurrentLocationWithDelegate:self]; //can be used
}

-(IBAction)getContiniousLocation:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getContiniousLocationWithDelegate:self];
}

-(IBAction)getSignificantLocationChange:(id)sender
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getSingificantLocationChangeWithDelegate:self];
}

-(IBAction)stopGettingLocation
{
    BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager stopGettingLocation];
}

-(void)showInMapsWithDictionary:(NSDictionary*)locationDict title:(NSString*)title
{
    CLLocationCoordinate2D infiniteLoopCoordinate = CLLocationCoordinate2DMake([locationDict[BB_LATITUDE] floatValue], [locationDict[BB_LONGITUDE] floatValue]);
    
    [self.annotation setCoordinate:infiniteLoopCoordinate];
    [self.annotation setTitle:title];;
    [self.mapView addAnnotation:self.annotation];
    
    self.mapView.region = MKCoordinateRegionMakeWithDistance(infiniteLoopCoordinate, 3000.0f, 3000.0f);

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
    [self showInMapsWithDictionary:fenceInfo.fenceCoordinate title:@"Added GeoFence"];
}

-(void)BBLocationManagerDidFailedFence:(BBFenceInfo *)fenceInfo
{
    NSString *text = [NSString stringWithFormat:@"Failed to add GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
    [self showInMapsWithDictionary:fenceInfo.fenceCoordinate title:@"Failed GeoFence"];
}


-(void)BBLocationManagerDidEnterFence:(BBFenceInfo *)fenceInfo
{
    NSString *text = [NSString stringWithFormat:@"Entered GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
    [self showLocalNotification:[NSString stringWithFormat:@"Enter Fence %@", text] withDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [self showInMapsWithDictionary:fenceInfo.fenceCoordinate title:@"Enter GeoFence"];
}


-(void)BBLocationManagerDidExitFence:(BBFenceInfo *)fenceInfo
{
    NSString *text =[NSString stringWithFormat:@"Exit GeoFence: %@", fenceInfo.dictionary.description];
    NSLog(@"%@", text);
    [self logtext:text];
    [self showLocalNotification:[NSString stringWithFormat:@"Exit Fence %@", text] withDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [self showInMapsWithDictionary:fenceInfo.fenceCoordinate title:@"Exit GeoFence"];
}


-(void)BBLocationManagerDidUpdateLocation:(NSDictionary *)latLongAltitudeDictionary
{
    NSLog(@"Current Location: %@", latLongAltitudeDictionary.description);
    [self logtext:[NSString stringWithFormat:@"Current Location: %@ at time: %@", latLongAltitudeDictionary.description, NSDate.date.description]];
    [self showInMapsWithDictionary:latLongAltitudeDictionary title:@"Current Location"];
}


-(void)BBLocationManagerDidUpdateGeocodeAdress:(NSDictionary *)addressDictionary
{
     NSLog(@"Current Location GeoCode/Address: %@", addressDictionary.description);
    [self logtext:[NSString stringWithFormat:@"Current Location: %@ at time: %@", addressDictionary.description, NSDate.date.description]];
    [self showInMapsWithDictionary:addressDictionary title:@"Geocode Updated"];
}

#pragma mark-  Other methods

-(void)showLocalNotification:(NSString*)notificationBody withDate:(NSDate*)notificationDate
{
    UIApplication *app                = [UIApplication sharedApplication];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate  = notificationDate;
    notification.timeZone  = [NSTimeZone defaultTimeZone];
    notification.alertBody = notificationBody;
    notification.soundName = UILocalNotificationDefaultSoundName;
    //notification.applicationIconBadgeNumber = badgeCount;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    //[userInfo setValue:eventType forKey:@"event_type"];
    [notification setUserInfo:userInfo];
    [app scheduleLocalNotification:notification];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
