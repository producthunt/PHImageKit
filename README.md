# PHImageKit

PHImageKit is simple yet powerfull image downloding, caching and GIF playback framework. It powers all image related views in ProductHunt iOS App.

## Installation

#### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C and swift, which automates and simplifies the process of using 3rd-party libraries like PHImageKit

``` ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'PHImageKit'
```

Then, run the following command:

``` bash
$ pod install
```

## Usage

Just instead of using `UIImageView` use `PHImageKit` witch is category of `UIImageView`. Then just pass image url

```swift
imageView.url = NSURL(string: "http://your_image_url.png")!
```

And that it's.

## Options

You can configure apperiance of `PHImageView`

- Show loading indicator - Disable by default
```swift
imageView.showLoadingIndicator = true
```
- Animated transition - Enabled by default
```swift
imageView.animatedTransition = true
```

If you want to change default cache size just call

```swift
PHManager.sharedInstance.setCacheSize(memorySizeInMB, fileCacheSize: fileSizeInMB)
```

## Requirements

iOS 8.0+
Xcode 7.0 or above

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Run the tests
6. Create new Pull Request

## License

**[MIT License](https://github.com/producthunt/PHImageKit/blob/master/LICENSE)**