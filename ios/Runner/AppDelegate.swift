import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)

      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound, .badge]){granted, error in}
      
      UIApplication.shared.registerForRemoteNotifications()
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let foregroundChannel = FlutterMethodChannel(name: "nz.co.resolution.flutterCallbackCacheExample/flutterCallbackCacheExampleForegroundChannel",
                                                   binaryMessenger: controller.binaryMessenger)
      
      foregroundChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          switch (call.method, call.arguments as? [AnyHashable: Any]) {
          case ("initialize", let .some(arguments)):
              guard let handle = arguments["callbackHandle"] as? Int64 else {
                  result("Invalid Parameters")
                  return
              }
              UserDefaultsHelper.storeCallbackHandle(handle)
              return
          default:
              result("Unhandled Method")
              return
          }
      })
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
       print("deviceToken:\(deviceTokenString)")
    }
}

public struct UserDefaultsHelper {

    public static let userDefaults = UserDefaults(suiteName: "group.flutterCallbackCacheExample")!

    public enum Key {
        case callbackHandle
        case isDebug
    }

    public static func storeCallbackHandle(_ handle: Int64) {
       store(handle, key: .callbackHandle)
    }

    public static func getStoredCallbackHandle() -> Int64? {
        return getValue(for: .callbackHandle)
    }

    private static func store<T>(_ value: T, key: Key) {
        userDefaults.setValue(value, forKey: "handle")
    }

    private static func getValue<T>(for key: Key) -> T? {
        return userDefaults.value(forKey: "handle") as? T
    }
}
