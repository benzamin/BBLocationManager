![BBLocationManager](https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/BBLocationManager-logo.png)   
A Location Manager for easily implementing location services & geofencing in iOS, written in Objective-C. **Ready for iOS 11.**

## Features

* Get current/continious/frequent location and get current geocode/address with simple API call. 
* Add or remove [Geofence](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html) at current/given location. Get callback via delegate when user enter/exit a geofence, supports foreground/background, even when [app is not running](https://developer.apple.com/reference/corelocation/cllocationmanager#//apple_ref/doc/uid/TP40007125-CH3-SW32). 
* Read location permission status and if not provided ask for location permisssion automatically. 
* High performance, easy to use, battery friendly, use via block or delegate. Stops automatically when location update is not required. 
* [Example App](https://github.com/benzamin/BBLocationManager/archive/master.zip) included for demonstrating all the features. Supports iOS 6.0 and later. 

![Current location and GeoCode](https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/locationNgeofence.gif  "Getting current location and Geocode")

## Getting Started
[Location services](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/CoreLocation/CoreLocation.html) is a powerful feature of iOS, but sometimes its not easy to understand all the API's and learn how to use them. With BBLocationManager, you can start using iOS Location Services API in no time. It provides good code documentation for better understanding of the methods and delegates. If you are making a location aware app or building a geofencing app like the [Alarm](https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/EventKitProgGuide/ConfiguringAlarms/ConfiguringAlarms.html) app in iOS which reminds you to buy milk when you are near home, BBLocationManager can be your choice.


## Installation
BBLocationManager can be installed through Cocoapods or manually. You can check out the example project by [downloading the full source code](https://github.com/benzamin/BBLocationManager/archive/master.zip)
> Supports iOS 6.0 and later.

### Installing with CocoaPods

[CocoaPods](http://cocoapods.org) is very popular dependency manager for iOS projects. It automates and simplifies the process of using 3rd-party libraries like BBLocation in your projects. If you don't have cocoapods installed in your mac already, you can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile
If you already have a Podfile, add the following line in your podfile:

```ruby
pod 'BBLocationManager'
```

If you already dont have a podfile, To integrate BBLocationManager into your Xcode project using CocoaPods, create and add it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

target 'YourTargetName' do
pod 'BBLocationManager'
end
```

Then, run the following command:

```bash
$ pod install
```
And the pod should be installed in your project. **PLEASE NOTE:** Close the yourProject.xcodeProj and open the yourProject.xcworkspace, as the pod has been initiated, from now one use the yourProject.xcworkspace to work with. Please refer to [CocoaPods](http://cocoapods.org) for detailed info.

#### Manual Installation
Just add the BBLocationManager.h and BBLocationManager.m files in your project [From Here](https://github.com/benzamin/BBLocationManager/tree/master/BBLocationManager/BBLocationManagerClasses). Import the BBLocationManager.h file in your class where you need location support.

## Permission
BBLocationManager automatically reads the current location permission status of the app and requests for permission if needed. But you need to provide some information in your info.plist file of your project depending on the minimum iOS version you are trageting. For iOS Version **earlier then 8.0**, a description of your purpose is recommended to provide by setting a string for the key `NSLocationUsageDescription` in your app's Info.plist file.

#### For iOS 11 and later
For **iOS 11** provide a description for how your app uses location services by setting a string for the key `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysAndWhenInUseUsageDescription` in your app's Info.plist file. When you build your app using the iOS 11 SDK, you are now required to provide an NSLocationWhenInUseUsageDescription key in all cases (if you use location at all). For “Always” access, you can additionally provide a second key, which is now called NSLocationAlwaysAndWhenInUseUsageDescription. If you only provide NSLocationAlwaysAndWhenInUseUsageDescription but not NSLocationWhenInUseUsageDescription, asking for “Always” access will not work. The old iOS 8/9/10 key NSLocationAlwaysUsageDescription is now only needed for backwards compatibility, if you’re still making the app available to iOS 10 or earlier users. It’s not needed or used on iOS 11 devices.

BBLocationManager automatically reads which level of permissions to request based on which description key you provide. You should only request the minimum permission level that your app requires, therefore it is recommended that you use the "When In Use" level unless you require more access. If you want to get **loation update in background** (even when app not running), you **MUST** provide a key called `UIBackgroundModes` and add a item called `location` inside it. Please see the attached image for these keys for iOS 11 with compatibility:
 
![Setting the keys in info.plist](https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/iOS-11-keys.png  "Configure these keys correctly for iOS 11, otherwise the location update might not work correctly.")


#### For iOS 8 and later
Starting with **iOS 8, you MUST** provide a description for how your app uses location services by setting a string for the key `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` in your app's Info.plist file. BBLocationManager automatically reads which level of permissions to request based on which description key you provide. You should only request the minimum permission level that your app requires, therefore it is recommended that you use the "When In Use" level unless you require more access. If you provide values for both description keys, the more permissive "Always" level is requested. 
Also, if you want to get **loation update in background** (even when app not running), you **MUST** provide a key called `UIBackgroundModes` and add a item called `location` inside it. Please see the attached image for these keys for iOS 8/9/10:
 
![Setting the keys in info.plist](https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/keys.png  "Configure these keys correctly, otherwise the location update might not work correctly.")

## Usage

First import `BBLocationManager.h` header in your class. Calling `[BBLocationManager sharedManager]` creates an singleton class of `BBLocationManager` and manages everything from here. You can either use `BBLocationManagerDelegate` to get location/geofence related callbacks, or use Objective-C blocks to get location. For useing Geofence, the `BBFenceInfo` is a easy to use object, using which `BBLocationManager` delivers fence related data to your class. You can use `lastKnownGeocodeAddress` and `lastKnownGeoLocation` properties to get the last location/geocode the class got before.

* To know the current location permission status call `+ (BOOL)locationPermission` method.
* To manually ask the user for location permission before accessing location, call `-(void)getPermissionForStartUpdatingLocation` method.

#### Getting current location (Using Block)
Get BBLocationManager's shared instance, set the `desiredAcuracy` and `distanceFilter` parameter as you like, then request for current location using block or delegate.
```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
manager.desiredAcuracy = 100; //how accurate you want your location, in meters   
manager.distanceFilter = 500; //you'll be notified if user moves away 500 meters from his initial location
[manager getCurrentLocationWithCompletion:^(BOOL success, NSDictionary *latLongAltitudeDictionary, NSError *error) {
        //access the 'latLongAltitudeDictionary' dictionary using BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE key
        NSLog(@"Current Location latitude: %@", latLongAltitudeDictionary[BB_LATITUDE]);
}];
```
#### Getting current location (Using Delegate)

```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
manager.desiredAcuracy = 100; //how accurate you want your location, in meters   
manager.distanceFilter = 500; //you'll be notified if user moves away 500 meters from his initial location
[manager getCurrentLocationWithDelegate:self];  
......
......
#pragma mark - BBLocationManagerDelegate methods
-(void)BBLocationManagerDidUpdateLocation:(NSDictionary *)latLongAltitudeDictionary
{
    //access the 'latLongAltitudeDictionary' dictionary using BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE key
    NSLog(@"Current Location Latitude: %@", latLongAltitudeDictionary[BB_LATITUDE]);
}
```
#### Getting current geocode/address (Using Block)
You can get user's current geocode AKA address from apple's geocode/maps server. You might need it for different purpose, and it might take a little time to get the location first and then determine the address.
```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
    [manager getCurrentGeoCodeAddressWithCompletion:^(BOOL success, NSDictionary *addressDictionary, NSError *error) {
        //access the dict using BB_LATITUDE, BB_LONGITUDE, BB_ALTITUDE, BB_ADDRESS_NAME, BB_ADDRESS_STREET, BB_ADDRESS_CITY, BB_ADDRESS_STATE, BB_ADDRESS_COUNTY, BB_ADDRESS_ZIPCODE, BB_ADDRESS_COUNTY, BB_ADDRESS_DICTIONARY
        NSLog(NSString stringWithFormat:@"Current GeoCode/Address: %@", addressDictionary.description);
    }];
```

#### Add a geofence in current location

```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
manager.delegate = self;
[manager addGeofenceAtCurrentLocation];
/*****can be also done using one of the following methods *****/
//[manager addGeofenceAtCurrentLocationWithRadious:100];
//[manager addGeofenceAtlatitude:59.331981f andLongitude:18.068435f withRadious:100 withIdentifier:@"MyFence-1";
//[manager addGeofenceAtCurrentLocationWithRadious:100 withIdentifier:@"MyFence-1"];
//[manager addGeofenceAtCoordinates:CLLocationCoordinate2DMake(59.331981f, 18.068435f) withRadious:100 withIdentifier:@"MyFence-1"];
//[manager addGeofenceAtCoordinates:CLLocationCoordinate2DMake(59.331981f, 18.068435f) withRadious:100 withIdentifier:nil];//If you provide identifier name 'nil', BBLocationManager will automatically asign a identifier string
 ```
 
![Geofence and alert](https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/geofence.gif  "Adding Geofence and getting alert")
![Geofence Alert](https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/geofence-alert.gif  "Geofence enter/exit alert while app in background/exited")
 
 #### Get all added geofences 
See which geofence is already added to get enter/exit callbacks. **NOTE:** You can add [maximum 20 geofences, its a limit [apple put](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html) in region monitoring.
```objective-c
 BBLocationManager *manager = [BBLocationManager sharedManager];
    
    NSArray *geoFences = [manager getCurrentFences];
    NSString *allFencetxt = @"All fences: ";
    for (BBFenceInfo *geofence in geoFences)
    {
        NSString *txt = [NSString stringWithFormat:@"Geofence '%@' is Active at Coordinates: %@:%@ with %@ meter radious \n", geofence.fenceIDentifier, [geofence.fenceCoordinate objectForKey:BB_LATITUDE],[geofence.fenceCoordinate objectForKey:BB_LONGITUDE], [geofence.fenceCoordinate objectForKey:BB_RADIOUS]];
        NSLog(@"%@", txt);
    }
```

 #### Delete a spefific geofence

```objective-c
 BBLocationManager *manager = [BBLocationManager sharedManager];
[manager deleteGeoFenceWithIdentifier:@"My-Geofence-3"];
```

#### Subscribe to Continious location
To get continuous location updates, use `-getContiniousLocationWithDelegate:` method. This will enable the BBLocationManager to listen every bit of change in location, and will keep you updated using the `-BBLocationManagerDidUpdateLocation:` delegate call. To stop getting continious location, call `-stopGettingLocation` method. Note that, until you stop the continious location, it will keep updating and will use battery life.
```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
[manager getContiniousLocationWithDelegate:self];
```
#### Subscribe to Significant location change
To get significant location changes, use `-getSingificantLocationChangeWithDelegate:` method. This will start looking for for significant location changes, which is very power efficient. The delegate callback `-BBLocationManagerDidUpdateLocation:` will be called everytime BBLocationManager finds any significant location change. This can be stoped by calling the `-stopGettingLocation` method. 
```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
[manager getSingificantLocationChangeWithDelegate:self];
```
**NOTE:** Significant location change will not be called frequently. According to [Apple documentation:](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/CoreLocation/CoreLocation.html)
>"Apps can expect a notification as soon as the device moves 500 meters or more from its previous notification. It should not expect notifications more frequently than once every five minutes. If the device is able to retrieve data from the network, the location manager is much more likely to deliver notifications in a timely manner."

#### Stop getting all kind of location

```objective-c
BBLocationManager *manager = [BBLocationManager sharedManager];
[manager stopGettingLocation];
```
#### BBLocationManagerDelegate methods
```objective-c
-(void)BBLocationManagerDidUpdateLocation:(NSDictionary *)latLongAltitudeDictionary;

-(void)BBLocationManagerDidUpdateGeocodeAdress:(NSDictionary *)addressDictionary;

-(void)BBLocationManagerDidAddFence:(BBFenceInfo *)fenceInfo;
-(void)BBLocationManagerDidFailedFence:(BBFenceInfo *)fenceInf
-(void)BBLocationManagerDidEnterFence:(BBFenceInfo *)fenceInfo
-(void)BBLocationManagerDidExitFence:(BBFenceInfo *)fenceInfo;

```
## Example Project
 [Downloading the full source code](https://github.com/benzamin/BBLocationManager/archive/master.zip) or checking out using git will provide you the example project. Give it a try, dont forget to specify a location in the iOS Simulator's Debug > Location menu if you aren't testing on real device.
 
## Other Reads

* [BBLocationManager: Simple yet powerfull](http://redgreen.studio/blog/2017/03/21/bblocationmanager-simple-yet-powerfull/) - A blog post on BBLocationManager.

## Issues and Contributions

Please [raise an issue here](https://github.com/benzamin/BBLocationManager/issues) if you find any bug, I'll try to resolve it asap. You can also make [pull requests](https://github.com/benzamin/BBLocationManager/pulls) if you want.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details. 

### Using BBLocationManager in your project?
If you are using this library in your project, and happy about it, please send me a [email](mailto:benzamin1985@gmail.com) and let me know, I'll add a references of your app. Thanks :)

