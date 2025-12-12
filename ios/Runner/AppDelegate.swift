import Flutter
import UIKit
import os

@main
@objc class AppDelegate: FlutterAppDelegate {
  var testHeadlessEngine: FlutterEngine?  // ✅ Add a test engine
    
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
              let logger = Logger(subsystem: "flutter.nz.co.resolution.flutterCallbackCacheExample", category: "foregroundChannel.setMethodCallHandler")

              guard let handle = arguments["callbackHandle"] as? Int64 else {
                  result("Invalid Parameters")
                  return
              }
              UserDefaultsHelper.storeCallbackHandle(handle)
              logger.log("Handling initialize, stored handle:\(handle)")
              
              let retrievedHandle = UserDefaultsHelper.getStoredCallbackHandle()
             
              logger.log("Handling initialize, retrieved handle:\(retrievedHandle ?? -1)")


              return
          case ("testDispatcher", _):  // ✅ Add test method
              self?.testDispatcherInHeadlessEngine()
              result("Testing dispatcher...")
              return
          
          default:
              result("Unhandled Method")
              return
          }
      })
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func testDispatcherInHeadlessEngine() {
        let logger = Logger(subsystem: "flutter.nz.co.resolution.flutterCallbackCacheExample", category: "TestDispatcher")

        logger.log("=== Testing Dispatcher in Headless Engine ===")

        // Clean up old engine if exists
        testHeadlessEngine?.destroyContext()

        // Create new headless engine
        logger.log("Creating headless Flutter engine...")
        let engine = FlutterEngine(name: "test_headless", project: nil, allowHeadlessExecution: true)
        self.testHeadlessEngine = engine

        logger.log("Attempting to run dispatcher entrypoint...")

        let success = engine.run(
            withEntrypoint: "dispatcher",
            libraryURI: nil
        )

        logger.log("Engine run result: \(success)")

        if success {
            logger.log("✓ Engine started successfully")
            logger.log("Waiting to see if dispatcher executes...")

        } else {
            logger.log("❌ Engine failed to start")
        }
    }

    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: "flutter.nz.co.resolution.flutterCallbackCacheExample", category: "didRegisterForRemoteNotificationsWithDeviceToken")
            logger.log("notification deviceToken:\(deviceTokenString)")
        } else {
            // Fallback on earlier versions
        }
    }
}

public struct UserDefaultsHelper {

    public static let userDefaults = UserDefaults(suiteName: "group.resolution.callbackCacheExample")!

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
