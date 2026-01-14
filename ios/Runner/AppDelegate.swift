import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var eventSink: FlutterEventSink?
  private var initialLink: String?
  private let METHOD_CHANNEL = "easypharma/deeplink"
  private let EVENT_CHANNEL = "easypharma/deeplink_stream"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    
    // Method channel for getting initial link
    let methodChannel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getInitialLink" {
        result(self?.initialLink)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    // Event channel for deep link stream
    let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)
    
    // Handle initial link if app was launched through a URL
    if let url = launchOptions?[.url] as? URL {
      initialLink = url.absoluteString
    } else if let userActivityDictionary = launchOptions?[.userActivityDictionary] as? [AnyHashable: Any],
              let userActivity = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity,
              userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL {
      initialLink = url.absoluteString
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle custom scheme URLs when the app is already open
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    eventSink?(url.absoluteString)
    return super.application(app, open: url, options: options)
  }

  // Handle universal links (https) when the app is already open
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
      eventSink?(url.absoluteString)
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}
