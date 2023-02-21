    //
    //  Settings.swift
    //  DDS
    //
    //  Created by Nirmit Dagly on 5/1/2023.
    //

import Foundation
import SwiftUI
import NDT7

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

struct Settings: View {
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationViewForSettings(title: "Settings")
                List {
                    FirstSection()
                    SecondSection()
                    ThirdSection()
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .stackNavigationView()
    }
}

struct CustomNavigationViewForSettings: View {
    var title: String
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        HStack() {
            Button {
                self.mode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.white)
                    .padding([.leading], 20)
            }
            
            Spacer()
            
            Text(title)
                .foregroundColor(.white)
                .font(.customFont(withWeight: .demibold, withSize: 24))
            
            Spacer()
        }
        .frame(height: 64, alignment: .center)
        .background(Color.qikiColor)
        .padding([.top], 20)
        .edgesIgnoringSafeArea(.all)
    }
}

struct FirstSection: View {
    @State var shouldOpenDocketSection = false
    
    var body: some View {
        Section {
            ZStack {
                NavigationLink(destination: DocketSections(sections: docketSections), isActive: $shouldOpenDocketSection) {
                    EmptyView()
                }
                .opacity(0)
                
                Button {
                    shouldOpenDocketSection = true
                } label: {
                    HStack {
                        Image(systemName: "doc.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(.qikiColor)
                            .padding([.leading], 20)
                        
                        Text("Docket Options")
                            .font(.customFont(withWeight: .medium, withSize: 18))
                            .foregroundColor(.black)
                            .padding([.leading], 10)
                        
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .foregroundColor(.gray)
                            .padding([.trailing], 10)
                    }
                    .frame(height: 60)
                }
            }
        } header: {
            Text("POS Options")
                .padding([.bottom], 10)
        }
    }
}

struct SecondSection: View {
    @State var info: AlertInfo?
    @State var shouldOpenUserGuide = false
    @State var shouldOpenPrivacyPolicy = false
    @State var shouldOpenTerms = false
    
    var body: some View {
        Section {
            ZStack {
                NavigationLink(destination: WebView(title: "User Guide", linkToDisplay: LinkToOpen.userGuide), isActive: $shouldOpenUserGuide) {
                    EmptyView()
                }
                .opacity(0)
                
                UserGuide(shouldOpenUserGuide: $shouldOpenUserGuide)
            }
            
            ContactUs(info: $info)
            
            ZStack {
                NavigationLink(destination: WebView(title: "Privacy Policy", linkToDisplay: LinkToOpen.privacyPolicy), isActive: $shouldOpenPrivacyPolicy) {
                    EmptyView()
                }
                .opacity(0)
                
                PrivacyPolicy(shouldOpenPrivacyPolicy: $shouldOpenPrivacyPolicy)
            }
            
            ZStack {
                NavigationLink(destination: WebView(title: "Terms and conditions", linkToDisplay: LinkToOpen.termsAndConditions), isActive: $shouldOpenTerms) {
                    EmptyView()
                }
                .opacity(0)
                
                TermsAndConditions(shouldOpenTerms: $shouldOpenTerms)
            }
        } header: {
            Text("Information")
                .padding([.bottom], 10)
        }
    }
}

struct ThirdSection: View {
    var body: some View {
        Section {
            SpeedTestView()
            SendLogsView()
            LogoutView()
        } header: {
            Text("Other")
                .padding([.bottom], 10)
        } footer: {
            HStack(alignment: .center) {
                Spacer()
                Text(appVersion)
                    .frame(alignment: .center)
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .padding([.top], 5)
                Spacer()
            }
        }
    }
}

struct UserGuide: View {
    @Binding var shouldOpenUserGuide: Bool
    
    var body: some View {
        Button {
            shouldOpenUserGuide = true
        } label: {
            HStack {
                Image(systemName: "book.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("User Guide")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
    }
}

struct ContactUs: View {
    @Binding var info: AlertInfo?
    
    var body: some View {
        Button {
            info = AlertInfo(id: .one, title: "Contact Us", message: "For 24 hour assistance call:\n 1300 642 633.")
        } label: {
            HStack {
                Image(systemName: "phone.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("Contact Us")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
        .alert(item: $info, content: { info in
            Alert(title: Text(info.title), message: Text(info.message))
        })
    }
}

struct PrivacyPolicy: View {
    @Binding var shouldOpenPrivacyPolicy: Bool
    
    var body: some View {
        Button {
            shouldOpenPrivacyPolicy = true
        } label: {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("Privacy Policy")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
    }
}

struct TermsAndConditions: View {
    @Binding var shouldOpenTerms: Bool
    
    var body: some View {
        Button {
            shouldOpenTerms = true
        } label: {
            HStack {
                Image(systemName: "doc.text.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("Terms and conditions")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
    }
}

struct SpeedTestView: View {
    @State var info: AlertInfo?

    @State var speedTest = SpeedTest()
    @State var isSpeedTestSuccessful = false
    
    var body: some View {
        Button {
            speedTest.startTest()
        } label: {
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("Speed Test")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
        .alert(item: $info, content: { info in
            Alert(title: Text(info.title), message: Text(info.message))
        })
    }
}

struct SendLogsView: View {
    @State var info: AlertInfo?
    
    var body: some View {
        Button {
            sendLogs()
        } label: {
            HStack {
                Image(systemName: "arrow.up.doc.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("Send Logs")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
        .alert(item: $info, content: { info in
            Alert(title: Text(info.title), message: Text(info.message))
        })
    }
    
    func sendLogs() {
        if Helper.isNetworkReachable() {
            Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "")
            LogService.shared.sendLogFile { result in
                switch result {
                    case .failure(let error):
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.uploadLogFile)))", message: error.localizedDescription)
                        
                    case .success(_):
                        Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                        info = AlertInfo(id: .one, title: "Success", message: "Log file sent!")
                }
            }
        }
        else {
            Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Device is not connected to internet.")
            info = AlertInfo(id: .one, title: "Device Offline", message: "Please reconnect to the internet and try again.")
        }
    }
}

struct LogoutView: View {
    @EnvironmentObject var views: Views
    
    var body: some View {
        Button {
            views.stacked = false
            UserDefaults.clearAll()
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.qikiColor)
                    .padding([.leading], 20)
                
                Text("Logout")
                    .font(.customFont(withWeight: .medium, withSize: 18))
                    .foregroundColor(.black)
                    .padding([.leading], 10)
                
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
                    .padding([.trailing], 10)
            }
            .frame(height: 60)
        }
    }
}

class SpeedTest {
    var info: AlertInfo?
    var ndt7Test: NDT7Test?
    var downloadTestRunning: Bool = false
    var uploadTestRunning: Bool = false
    var downloadSpeed: Double?
    var uploadSpeed: Double?
    var enableAppData = true
    
    func startTest() {
        Helper.loadingSpinner(isLoading: true, isUserInteractionEnabled: false, withMessage: "Speed Test is in progress...")

        ndt7Test = NDT7Test(settings: NDT7Settings())
        ndt7Test?.delegate = self
        statusUpdate(downloadTestRunning: true, uploadTestRunning: true)
        ndt7Test?.startTest(download: true, upload: true) {[self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.debugDescription)
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Error during internet speed test: \(error)")
                    self.info = AlertInfo(id: .one, title: "ALERT", message: "Error during internet speed test. Please start again.")
                }
                else {
                    self.statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    self.info = AlertInfo(id: .one, title: "ALERT", message: "Internet speed test has been finished and the results has been logged. \n\nIf you have been asked to share the results, click on 'Send Logs' button.")
                }
            }
        }
    }
    
    func cancelTest() {
        ndt7Test?.cancel()
        statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
    }

    func statusUpdate(downloadTestRunning: Bool?, uploadTestRunning: Bool?) {
        if let downloadTestRunning = downloadTestRunning {
            self.downloadTestRunning = downloadTestRunning
        }
        
        if let uploadTestRunning = uploadTestRunning {
            self.uploadTestRunning = uploadTestRunning
        }
    }
    
    func decimalArray(from firstInt: Double, to secondInt: Double) -> [Double] {
        var firstInt = firstInt
        var array: [Double] = []
        if firstInt == secondInt {
            array.insert(firstInt, at: 0)
        }
        else if firstInt > secondInt {
            let decimals = (firstInt - secondInt) / 10
            while firstInt >= secondInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt -= decimals
            }
        }
        else if secondInt > firstInt {
            let decimals = (secondInt - firstInt) / 10
            while secondInt >= firstInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt += decimals
            }
        }
        return array
    }
}

extension SpeedTest: NDT7TestInteraction {
    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        switch kind {
        case .download:
            downloadTestRunning = running
        case .upload:
            uploadTestRunning = running
            statusUpdate(downloadTestRunning: nil, uploadTestRunning: running)
        }
    }

    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        if let server = ndt7Test?.settings.currentServer {
            print(server.machine)
            if let serverCountry = server.location?.country, let serverCity = server.location?.city
            {
                Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "To measure the internet speed, we're using server: \(server.machine) which is located in: \(serverCity), \(serverCountry)")
                print("To measure the internet speed, we're using server: \(server.machine) which is located in: \(serverCity), \(serverCountry)")
            }
        }

        if origin == .client, enableAppData,
            let elapsedTime = measurement.appInfo?.elapsedTime,
            let numBytes = measurement.appInfo?.numBytes,
            elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            let mbit = numBytes / 125000
            let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
            switch kind {
            case .download:
                downloadSpeed = rounded
                DispatchQueue.main.async {
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Download speed is: \(rounded) Mbit/s")
                    print("Download speed is: \(rounded) Mbit/s")
                }
            case .upload:
                uploadSpeed = rounded
                DispatchQueue.main.async {
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Upload speed is: \(rounded) Mbit/s")
                    print("Upload speed is: \(rounded) Mbit/s")
                }
            }
        }
        else if origin == .server,
            let elapsedTime = measurement.tcpInfo?.elapsedTime,
            elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            switch kind {
            case .download:
                if let numBytes = measurement.tcpInfo?.bytesSent {
                    let mbit = numBytes / 125000
                    let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                    downloadSpeed = rounded
                    DispatchQueue.main.async {
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Download speed is: \(rounded) Mbit/s")
                    }
                }
            case .upload:
                if let numBytes = measurement.tcpInfo?.bytesReceived {
                    let mbit = numBytes / 125000
                    let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                    uploadSpeed = rounded
                    DispatchQueue.main.async {
                        Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Upload speed is: \(rounded) Mbit/s")
                    }
                }
            }
        }
    }

    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        cancelTest()
    }

    func errorAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.info = AlertInfo.init(id: .one, title: title, message: "\(message)")
        }
    }
}
