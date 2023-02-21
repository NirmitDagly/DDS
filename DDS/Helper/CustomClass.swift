//
//  CustomClass.swift
//  DDS
//
//  Created by Nirmit Dagly on 30/12/2022.
//

import Foundation

class  Logs {
    class func writeLog(onDate date: String, andDescription error: String) {
        let logData = "\n[\(date)] " + "and Description: \(error)"
        
        var textLog = TextLog()
        textLog.write(LogFileNames.logs.rawValue + "+" + logData)
    }
}
