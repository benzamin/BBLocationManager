# BBLocationManager

A Location Manager for easily implementing location services & geofencing in iOS, written in Objective-C.

## Features
* Get current/continious/frequent location and get current geocode/address.
* Add or remove [Geofence](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html) at current/given location. Get callback via delegate when user enter/exit a geofence, supports foreground/background, even when [app is not running](https://developer.apple.com/reference/corelocation/cllocationmanager#//apple_ref/doc/uid/TP40007125-CH3-SW32).
* Read location permission status and ask for permisssion.
* High performance, easy to use, battery friendly, use via block or delegate. 
* Example App included for demonstrating all the features.

## Getting Started
[Location services](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/CoreLocation/CoreLocation.html) is a powerful feature of iOS, but sometimes its not easy to understand all the API's and learn how to use them. With BBLocationManager, you can start using iOS Location Services API in no time. It provides good code documentation for better understanding of the methods and delegates. If you are making a location aware app or building a geofencing app like the [Alarm](https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/EventKitProgGuide/ConfiguringAlarms/ConfiguringAlarms.html) app in iOS which reminds you to buy milk when you are near home, BBLocationManager can be your choice.


### Prerequisites

What things you need to install the software and how to install them

```
Give examples
```

### Installing

A step by step series of examples that tell you have to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc

