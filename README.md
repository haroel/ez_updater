# ez_updater

[![CI Status](https://img.shields.io/travis/ihowe@outlook/ez_updater.svg?style=flat)](https://travis-ci.org/whzsgame@gmail.com/ez_updater)
[![Version](https://img.shields.io/cocoapods/v/ez_updater.svg?style=flat)](https://cocoapods.org/pods/ez_updater)
[![License](https://img.shields.io/cocoapods/l/ez_updater.svg?style=flat)](https://cocoapods.org/pods/ez_updater)
[![Platform](https://img.shields.io/cocoapods/p/ez_updater.svg?style=flat)](https://cocoapods.org/pods/ez_updater)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ez_updater is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ez_updater'


// Add code to your project

    [[EZUpdater Instance] checkAppStoreVersion];


```

### Customizations

    [[EZUpdater Instance] checkAppStoreInfoWithHandler:^(NSError* error,NSString *appstoreVersion, NSDictionary*appstoreInfo){


    }];

## Author

ihowe@outlook.com

## License

ez_updater is available under the MIT license. See the LICENSE file for more info.
