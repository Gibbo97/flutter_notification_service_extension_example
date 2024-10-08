import Foundation

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
