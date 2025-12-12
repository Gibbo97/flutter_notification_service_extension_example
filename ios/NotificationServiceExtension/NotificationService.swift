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
    
    var flutterEngine: FlutterEngine?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.logger.log("=== Service Extension called ===")
        initializeFlutterCallbackCache()


        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let callbackHandle = UserDefaultsHelper.getStoredCallbackHandle()
        else {
            self.logger.log("No callback handle stored")
            
            serviceExtensionTimeWillExpire()
            return
        }
        
        self.logger.log("Callback Handle: \(callbackHandle)")
        
        guard let callbackInfo = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)
        else {
            self.logger.log("No callbackInfo stored")
            
            serviceExtensionTimeWillExpire()
            return
        }
        
        self.logger.log("CallbackInfo: \(callbackInfo)")


        // Create and store the engine
        self.logger.log("Creating Flutter engine...")
        let engine = FlutterEngine(name: "notification_service", project: nil, allowHeadlessExecution: true)
        self.flutterEngine = engine  // ✅ Keep reference!

        logger.log("Attempting to run dispatcher entrypoint...")

        let success = engine.run(withEntrypoint: callbackInfo.callbackName,
                                 libraryURI: callbackInfo.callbackLibraryPath,
                                 initialRoute: nil,
                                 entrypointArgs: ["a"])


        logger.log("Engine run result: \(success)")

        if success {
            logger.log("✓ Engine started successfully")
            logger.log("Waiting to see if dispatcher executes...")
        } else {
            self.logger.log("❌ Failed to start Flutter engine")
            serviceExtensionTimeWillExpire()
            return
        }

        // Give the extension 25 seconds to process (iOS limit is 30 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25.0) { [weak self] in
            self?.logger.log("Extension timeout approaching, finishing...")
            self?.serviceExtensionTimeWillExpire()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func initializeFlutterCallbackCache() {
        self.logger.log("initializeFlutterCallbackCache")
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.resolution.callbackCacheExample"
        ) else {
            self.logger.log("ERROR: App Group not accessible!")
            return
        }

        let cachePath = groupURL.appendingPathComponent("Library/Caches").path

        FlutterCallbackCache.setCachePath(cachePath)
        FlutterCallbackCache.loadFromDisk()  // Now this works!
    }

}
