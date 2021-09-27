#import "FlutterCameraSegmentationPlugin.h"
#if __has_include(<flutter_camera_segmentation/flutter_camera_segmentation-Swift.h>)
#import <flutter_camera_segmentation/flutter_camera_segmentation-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_camera_segmentation-Swift.h"
#endif

@implementation FlutterCameraSegmentationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCameraSegmentationPlugin registerWithRegistrar:registrar];
}
@end
