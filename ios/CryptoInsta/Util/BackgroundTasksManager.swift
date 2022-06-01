//
//  BackgroundTasksManager.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation
import UIKit

class BackgroundTasksManager {
    
    static var shared = BackgroundTasksManager()
    
    var connectBackgroundTaskID: UIBackgroundTaskIdentifier?
    var sendTxBackgroundTaskID: UIBackgroundTaskIdentifier?
    
    func createConnectBackgroundTask() {
        connectBackgroundTaskID =
        UIApplication.shared.beginBackgroundTask (withName: "Connect to wallet") { [weak self] in
            self?.finishConnectBackgroundTask()
        }
    }
    
    func createSendTxBackgroundTask() {
        sendTxBackgroundTaskID =
        UIApplication.shared.beginBackgroundTask (withName: "Send tx") { [weak self] in
            self?.finishSendTxBackgroundTask()
        }
    }
    
    func finishConnectBackgroundTask() {
        if let taskId = connectBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.connectBackgroundTaskID = nil
        }
    }
    
    func finishSendTxBackgroundTask() {
        if let taskId = sendTxBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskId)
            self.sendTxBackgroundTaskID = nil
        }
    }
}
