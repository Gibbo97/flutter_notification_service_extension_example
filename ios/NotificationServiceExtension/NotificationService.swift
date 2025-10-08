//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Jack Gibbons on 08/10/2024.
//

import UserNotifications
import UIKit
import Flutter
import Foundation
import os
import UIKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let logger = Logger(subsystem: "flutter.nz.co.resolution.flutterCallbackCacheExample", category: "NotificationPreSync")

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.logger.log("Service Extension called")

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
                
        guard let callbackHandle = UserDefaultsHelper.getStoredCallbackHandle()
        else {
            self.logger.log("No callback handle stored")
            
            serviceExtensionTimeWillExpire()
            return
        }
        self.logger.log("Successfully retrieved callback handle: \(callbackHandle)")
        
        var cachePath: String
        
        if let appGroupIdentifier = Bundle.main.object(forInfoDictionaryKey: "FlutterAppGroupIdentifier") as? String,
           let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {

            let cacheURL = groupURL.appendingPathComponent("Library/Caches")
            try? FileManager.default.createDirectory(at: cacheURL,
                                                      withIntermediateDirectories: true,
                                                      attributes: nil)
            cachePath = cacheURL.path
        }

        FlutterCallbackCache.setCachePath(cachePath)
        FlutterCallbackCache.loadCacheFromDisk()

        let exampleShowingNil = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)

        guard let flutterCallbackInformation = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)
        else {
            self.logger.log("Cannot find handle in FlutterCallbackCache")
            
            serviceExtensionTimeWillExpire()
            return
        }
        
        self.logger.log("Successfully found handle in FlutterCallbackCache: \(flutterCallbackInformation)")

    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
