# PHImageKit

PHImageKit is simple yet powerful image downloading, caching and GIF playback framework. 

- Download image or GIF and display it with just a single call
- Caches both in memory and in file storage
- Plays multiple GIFs simultaneously
- Eliminates delays or blocking during the first playback loop of GIFs

PHImageKit is the component that powers all images and GIFs in ProductHunt iOS App

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

You can configure appearance of `PHImageView`

- Show loading indicator - Disable by default
```swift
imageView.showLoadingIndicator = true
```
- Animated transition - Enabled by default
```swift
imageView.animatedTransition = true
```
- change default cache size just call
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

## To Do

- Add ability to set `placeholder image`
- `Objective C` compatibility

## Inspirations

- [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage)
- [SDWebImage](https://github.com/rs/SDWebImage)
- [Kingfisher](https://github.com/onevcat/Kingfisher)

## License

**[MIT License](https://github.com/producthunt/PHImageKit/blob/master/LICENSE)**