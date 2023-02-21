//
//  StatusBarModifier.swift
//  DDS
//
//  Created by Nirmit Dagly on 4/1/2023.
//

import SwiftUI

struct StatusBarStyleModifier: ViewModifier {
      let color: Color
      let material: Material
      let hidden: Bool

      func body(content: Content) -> some View {
        ZStack {
          // View inserted behind the status bar
          VStack {
            GeometryReader { geo in
              color
                .background(material) // SwiftUI 3+ only
                .frame(height: geo.safeAreaInsets.top)
                .edgesIgnoringSafeArea(.top)
              Spacer()
            }
          }
          content
        }
        .statusBar(hidden: hidden) // visibility
      }
}
