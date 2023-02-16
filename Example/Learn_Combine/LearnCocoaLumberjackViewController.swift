//
//  LearnCocoaLumberjackViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 15/2/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import CocoaLumberjack

class LearnCocoaLumberjackViewController: UIViewController {

    let logger = DDOSLogger(subsystem: "LearningDemo", category: "CocoaLumberjack")

    override func viewDidLoad() {
        super.viewDidLoad()
        initLogging()
    }

    private func initLogging() {
        DDLog.add(logger)
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        print("log file path: \(fileLogger.currentLogFileInfo?.fileName)")
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)


//        for i in 0 ..< 10 {
//            DDLogDebug("log \(i)")
//        }
        DDLogDebug("log 1")

    }



}
