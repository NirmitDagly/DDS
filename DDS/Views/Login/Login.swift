    //
    //  Login.swift
    //  DDS
    //
    //  Created by Nirmit Dagly on 30/12/2022.
    //

import SwiftUI

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

struct Login: View {
    @State var userName = "hospitality" //UserDefaults.userName ??
    @State var password = "rasmuslerdorf" //UserDefaults.password ??
    @State var shouldShowPassword = false
    @State var shouldRememberPassword = UserDefaults.rememberLoginDetails
    
    @EnvironmentObject var views: Views
    
    var body: some View {
        ZStack {
            NavigationView() {
                BaseView(userName: $userName, password: $password, shouldShowPassword: $shouldShowPassword, shouldRememberPassword: $shouldRememberPassword, views: views)
                    .onAppear(perform: {
                            //                            userName = UserDefaults.userName ?? ""
                            //                            password = UserDefaults.password ?? ""
                        shouldRememberPassword = UserDefaults.rememberLoginDetails
                        
                        if userName != "" && password != "" {
                            fillAutoDetailsAndPerformLogin(userName: $userName, password: $password)
                            
                            if UserDefaults.isLoggedIn == true {
                                btnLogin(userName: $userName, password: $password, views: views).performLogin()
                            }
                        }
                    })
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .stackNavigationView()
        }
    }
    
    func fillAutoDetailsAndPerformLogin(userName: Binding<String>, password: Binding<String>) {
        if UserDefaults.rememberLoginDetails == true {
            _ = UsernameField(userName: $userName)
            _ = PasswordField(password: $password, shouldShowPassword: $shouldShowPassword)
        }
    }
}

struct BaseView: View {
    @Binding var userName: String
    @Binding var password: String
    @Binding var shouldShowPassword: Bool
    @Binding var shouldRememberPassword: Bool
    @ObservedObject var views: Views
    
    var body: some View {
        VStack() {
            Spacer()
            
            Image("QikiLogo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 492, height: 180)
            
            UsernameField(userName: $userName)
            PasswordField(password: $password, shouldShowPassword: $shouldShowPassword)
            RememberLoginDetails(userName: $userName, password: $password, shouldRememberPassword: $shouldRememberPassword)
            LoginButton(userName: $userName, password: $password, views: views)
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct UsernameField: View {
    @Binding var userName: String
    
    var body: some View {
        Text("Username")
            .frame(width: 500, height: 40, alignment: .leading)
            .font(.customFont(withWeight: .demibold, withSize: 18))
            .foregroundColor(Color.qikiColor)
            .padding([.top], 30)
        
        TextField("Enter Username", text: $userName)
            .frame(width: 500, height: 40, alignment: .leading)
            .font(.customFont(withWeight: .demibold, withSize: 18))
            .foregroundColor(.black)
            .multilineTextAlignment(.leading)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
        
        Divider()
            .frame(width: 500, height: 2, alignment: .leading)
            .background(Color.qikiColor)
    }
}

struct PasswordField: View {
    @Binding var password: String
    @Binding var shouldShowPassword: Bool
    
    var body: some View {
        Text("Password")
            .frame(width: 500, height: 40, alignment: .leading)
            .font(.customFont(withWeight: .demibold, withSize: 18))
            .foregroundColor(Color.qikiColor)
        
        HStack {
            if shouldShowPassword == false {
                SecureField("Enter Password", text: $password)
                    .frame(width: 400, height: 40, alignment: .leading)
                    .font(.customFont(withWeight: .demibold, withSize: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .autocorrectionDisabled(true)
                    .padding([.trailing], 50)
            }
            else {
                TextField("Enter Password", text: $password)
                    .frame(width: 400, height: 40, alignment: .leading)
                    .font(.customFont(withWeight: .demibold, withSize: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .autocorrectionDisabled(true)
                    .padding([.trailing], 50)
            }
            
            Button {
                if shouldShowPassword == false {
                    shouldShowPassword = true
                }
                else {
                    shouldShowPassword = false
                }
            } label: {
                if shouldShowPassword == true && password != "" {
                    Image("QikiEyeOpen")
                }
                else {
                    Image("QikiEyeClosed")
                }
            }
            .frame(width: 40, height: 40, alignment: .trailing)
        }
        
        Divider()
            .frame(width: 500, height: 2, alignment: .leading)
            .background(Color.qikiColor)
    }
}

struct RememberLoginDetails: View {
    @Binding var userName: String
    @Binding var password: String
    @Binding var shouldRememberPassword: Bool
    
    var body: some View {
        HStack {
            Text("Remember Login Details?")
                .font(.customFont(withWeight: .demibold, withSize: 18))
                .foregroundColor(.qikiColor)
            
            Button {
                if shouldRememberPassword == false {
                    shouldRememberPassword = true
                    UserDefaults.rememberLoginDetails = true
                    UserDefaults.password = password
                }
                else {
                    shouldRememberPassword = false
                    UserDefaults.rememberLoginDetails = false
                    UserDefaults.password = ""
                }
            } label: {
                if shouldRememberPassword == false {
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(.qikiColor)
                        .frame(width: 25, height: 25, alignment: .trailing)
                }
                else {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .foregroundColor(.qikiColor)
                        .frame(width: 25, height: 25, alignment: .trailing)
                }
            }
        }
        .frame(width: 500, height: 40, alignment: .trailing)
        .padding([.bottom], 20)
    }
}

struct LoginButton: View {
    @Binding var userName: String
    @Binding var password: String
    
    @ObservedObject var views: Views
    
    var body: some View {
        NavigationLink(destination: ActiveOrdersView(), isActive: $views.stacked) {
            btnLogin(userName: $userName, password: $password, views: views)
        }
    }
}

struct btnLogin: View {
    @Binding var userName: String
    @Binding var password: String
    
    @State var info: AlertInfo?
    @ObservedObject var views: Views
    
    var body: some View {
        Button(action: {
            performLogin()
        }, label: {
            Text("Sign In")
                .foregroundColor(.qikiColor)
                .font(.customFont(withWeight: .demibold, withSize: 26))
                .frame(width: 500, height: 50, alignment: .center)
        })
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.qikiColor, lineWidth: 2)
        )
        .alert(item: $info, content: { info in
            Alert(title: Text(info.title), message: Text(info.message))
        })
    }
    
    func performLogin() {
        if userName == "" && password == "" {
            info = AlertInfo(id: .one, title: "ALERT", message: "Username and Password cannot be empty.")
        }
        else if userName == "" {
            info = AlertInfo(id: .one, title: "ALERT", message: "Username cannot be empty.")
        }
        else if password == "" {
            info = AlertInfo(id: .one, title: "ALERT", message: "Password cannot be empty.")
        }
        else {
            if Helper.isNetworkReachable() {
                let updatedAppVersionNumber = Helper.getAppVersionNumber()
                Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "Logging In...")
                LoginService.shared.login(username: userName, password: password, appVersion: updatedAppVersionNumber, completion: {
                    result in
                    switch result {
                        case .failure(let error):
                            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: error.localizedDescription)
                            self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.login)))", message: error.localizedDescription)
                        case .success(let resp):
                            print(resp)
                            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: false, withMessage: "")
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
                            self.LoginSuccess()
                    }
                })
            }
            else {
                info = AlertInfo(id: .one, title: "Device Offline", message: "Please reconnect to the internet and try again.")
            }
        }
    }
    
    func LoginSuccess() {
        UserDefaults.userName = userName
        UserDefaults.password = password
        
        posID = UserDefaults.token?.username ?? "Admin"
        if UserDefaults.lastLogoutDate != nil {
            if UserDefaults.lastLogoutDate != Date().toString(format: "dd-MM-yyyy") {
                isLoggedinFirstTime = true
            }
            else {
                isLoggedinFirstTime = false
            }
        }
        else {
            isLoggedinFirstTime = false
        }
        
        registerDevice(userName: userName)
    }
    
    func registerDevice(userName: String) {
        if Helper.isNetworkReachable() {
            Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "Syncing Data...")
            CommonService.shared.registerDevice(username: userName, deviceToken: UserDefaults.deviceTokenString) { result in
                switch result {
                    case .failure(let error):
                        print("Failed to register device: \(error)")
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Failed to register device because: \(error).")
                        
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.deviceRegister)))", message: error.localizedDescription)
                        
                        UserDefaults.isDeviceTokenRegistered = false
                    case .success(let resp):
                        UserDefaults.isDeviceTokenRegistered = true
                        UserDefaults.deviceID = resp.deviceID
                        deviceID = resp.deviceID
                        posID = (UserDefaults.token?.username ?? "Admin") + String(UserDefaults.deviceID)
                        self.updateAppVersion()
                }
            }
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: false, withMessage: "")
            info = AlertInfo(id: .one, title: "Device Offline", message: "Please reconnect to the internet and try again.")
        }
    }
    
    func updateAppVersion() {
        if UserDefaults.appVersion != nil {
            if UserDefaults.appVersion != UIApplication.appVersion {
                checkForAppVersion()
            }
            else {
                UserDefaults.appVersion = UIApplication.appVersion
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.getStoreDetails()
                }
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.getStoreDetails()
            }
        }
    }
    
    func checkForAppVersion() {
            //call API that user has got newer version of app and hence update the base url
        if Helper.isNetworkReachable() {
            let updatedVersionNumber = Helper.getAppVersionNumber()
            LoginService.shared.getBaseURL(appVersion: updatedVersionNumber) { result in
                switch result {
                    case .failure(let error):
                        print("Unable to get base URL")
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Failed to update base url for new app version \(error).")
                        
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.updateVersionNumber)))", message: error.localizedDescription)
                        
                    case .success(let resp):
                        print("Successfully updated base URL")
                        if UserDefaults.token != nil {
                            UserDefaults.token!.qikiSite = resp.qikiSite
                        }
                        
                        UserDefaults.appVersion = UIApplication.appVersion
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Successfully updated base url for new version.")
                        
                        self.getStoreDetails()
                }
            }
        }
        else {
            info = AlertInfo(id: .one, title: "Device Offline", message: "Please reconnect to the internet and try again.")
        }
    }
    
    func getStoreDetails() {
        if Helper.isNetworkReachable() {
            CommonService.shared.getStoreDetails {result in
                switch result {
                    case .failure(let error):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            print("Failed to get store details...")
                            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                            
                            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                            self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getStoreDetails)))", message: error.localizedDescription)
                        }
                    case .success(let resp):
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Received response is:\n Store Details: \(String(describing: resp.storeDetails)) \n IsMainTerminal: \(String(describing: resp.isMainTerminal))\n Device ID: \(resp.deviceID ?? 0)\n")
                        
                        if resp.success == 1 {
                            Helper.scheduleTimerToUploadLogFile()
                            
                            if resp.storeDetails != nil {
                                UserDefaults.storeDetails = resp.storeDetails
                                Helper.startLogoutTimer()
                                Helper.checkForBusinessHours()
                            }
                            
                            if resp.isMainTerminal != nil {
                                UserDefaults.isMainTerminal = resp.isMainTerminal! == 1 ? true : false
                            }
                            
                            if resp.deviceID != nil {
                                UserDefaults.deviceID = resp.deviceID!
                                deviceID = resp.deviceID!
                            }
                            
                            self.getDocketSections()
                        }
                        else if resp.success == 2 && resp.isMainTerminal != nil && resp.isMainTerminal! == 0 {
                            self.info = AlertInfo(id: .one, title: "ALERT", message: "The system has detected that you are running different application version than main POS terminal. Make sure the application version is same on every device(s). \n\nYou can check version of application by clicking on Settings (5th Tab) and Scroll down to bottom.")
                        }
                }
            }
        }
        else {
            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            info = AlertInfo(id: .one, title: "Device Offline", message: "Please reconnect to the internet and try again.")
        }
    }
    
    func getDocketSections() {
        if Helper.isNetworkReachable() {
            CommonService.shared.getDocketSections {result in
                switch result {
                    case .failure(let error):
                        print("Failed to get docket sections...")
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                        
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getDocketSection)))", message: error.localizedDescription)
                    case .success(let resp):
                            //docketSectionOptions = resp.dockets
                        docketSections = resp.dockets //resp.dockets.compactMap({$0.docket})
                        
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        
                        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.count > 0 {
                            for i in 0 ..< UserDefaults.selectedDocketSections!.count {
                                if !docketSections.contains(UserDefaults.selectedDocketSections![i]) {
                                    UserDefaults.selectedDocketSections!.remove(at: i)
                                }
                            }
                            
                            if UserDefaults.selectedDocketSections!.count > 0 {
                                selectedSections = UserDefaults.selectedDocketSections!
                            }
                            else {
                                selectedSections = [String]()
                            }
                        }
                        views.stacked = true
                }
            }
        }
        else {
            Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            info = AlertInfo(id: .one, title: "Device Offline", message: "Please reconnect to the internet and try again.")
        }
    }
}
