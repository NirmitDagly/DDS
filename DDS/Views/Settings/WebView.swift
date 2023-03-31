//
//  WebView.swift
//  DDS
//
//  Created by Nirmit Dagly on 4/1/2023.
//

import SwiftUI
import WebKit

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView()
    }
}

struct WebView: View {
    @State var title = ""
    @State var openLink = true
    
    var linkToDisplay = LinkToOpen(rawValue: "")

    var body: some View {
        ZStack {
            VStack {
                CustomNavigationViewForWebView(title: $title)
                Spacer()
                WebViewRepresentable(url: URL(string: linkToDisplay!.rawValue)!, isShowing: $openLink)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .stackNavigationView()
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    var url: URL
    @Binding var isShowing: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct CustomNavigationViewForWebView: View {
    @Binding var title: String
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
            
            GeometryReader { geometryReader in
                Text(title)
                    .foregroundColor(.white)
                    .font(.customFont(withWeight: .demibold, withSize: 24))
                    .frame(width: geometryReader.size.width, alignment: .center)
                    .padding(.top, 15)
            }
            
            Spacer()
        }
        .frame(height: 64, alignment: .center)
        .background(Color.qikiColor)
        .padding([.top], 20)
        .edgesIgnoringSafeArea(.all)
    }
}
