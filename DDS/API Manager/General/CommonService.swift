//
//  CommonService.swift
//  Qiki KDS
//
//  Created by Nirmit Dagly on 30/11/2022.
//

import Foundation

struct CommonService {
    static let shared = CommonService()
    var baseURL: String { UserDefaults.token?.qikiSite ?? "" }
    
    //MARK: This function is called to register device token on server.
    func registerDevice(username: String, deviceToken: String, completion: @escaping (Result<GetDeviceRegistrationResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Register Device API called.")
        
        let apiRequest = ApiRequest(url: "\(baseURL)/register_device",
                                    params: ["username": username,
                                                "device_token": deviceToken,
                                                "device_uuid": deviceUUID,
                                                "device_name": deviceName,
                                                "device_model": deviceModel,
                                                "device_os": deviceSystemVersion,
                                                "app_version": versionNumber!,
                                                "app_build": buildNumber!],
                                    method: .post)
        WebService.shared.request(request: apiRequest, completion: completion)
    }
        
    //MARK: This function is called to get basic details of store.
    func getStoreDetails(completion: @escaping (Result<GetStoreDetailsResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Get Store Details API called.")
        
        let apiRequest = ApiRequest(url: "\(baseURL)/get_store_details",
                                    params: ["device_uuid": deviceUUID,
                                                "device_name": deviceName,
                                                "app_version": versionNumber!,
                                                "app_build": buildNumber!], method: .post)
        WebService.shared.request(request: apiRequest) { (result: Result<GetStoreDetailsResponse, Error>) in
            switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
        
    //MARK: This function is called to get the available docket sections.
    func getDocketSections(completion: @escaping (Result<GetDocketResponse, Error>) -> ()) {
        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Get Docket Section API called.")
        
        let apiRequest = ApiRequest(url: "\(baseURL)/get_dockets",
                                    params: ["device_uuid": deviceUUID,
                                                "device_name": deviceName], method: .post)
        WebService.shared.request(request: apiRequest) { (result: Result<GetDocketResponse, Error>) in
            switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let resp):
                    completion(.success(resp))
            }
        }
    }
    
    //MARK: This function is called to upload the log file on server.
    func sendLogFile(completion: @escaping (Result<GeneralResponse, Error>) -> ()) {
        let file = LogFileNames.logs.rawValue + ".txt" //this is the file. we will write to and read from it
        var fileURL = URL.init(string: "")
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dir.appendingPathComponent(file)
        }
        
        let apiRequest = ApiRequest.init(url: "\(baseURL)/ios_logs",
                                         params: ["device_uuid": deviceUUID,
                                                  "device_name": deviceName],
                                         method: .post)
        WebService.shared.requestToUploadFile(filePath: fileURL!, request: apiRequest) { (result: Result<GeneralResponse, Error>) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                completion(.failure(error))
            case .success(let resp):
                //First of all, delete the uploaded file and create a new one at Documents directory...
                let textLog = TextLog()
                if textLog.checkIfFileExists(fileName: LogFileNames.logs.rawValue) == true {
                    textLog.deleteFile()
                    textLog.createFile(fileName: LogFileNames.logs.rawValue)
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "New log file created for app with version: \(appVersion) and device UUID: \(deviceUUID) and device name: \(deviceName).")
                }
                else {
                    print("Log file does not exists at location...")
                }
                completion(.success(resp))
            }
        }

    }
}
