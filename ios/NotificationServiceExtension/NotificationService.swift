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
    let logger = Logger()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.logger.log("NotificationPreSync Service Extension called")

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
                
        guard let callbackHandle = UserDefaultsHelper.getStoredCallbackHandle()
        else {
            self.logger.log("[\(String(describing: self))] no callback handle stored")
            
            serviceExtensionTimeWillExpire()
            return
        }
        let exampleShowingNil = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)

        guard let flutterCallbackInformation = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)
        else {
            self.logger.log("[\(String(describing: self))] cannot look up callback information")
            
            serviceExtensionTimeWillExpire()
            return
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
