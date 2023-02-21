//
//  DocketSections.swift
//  DDS
//
//  Created by Nirmit Dagly on 6/1/2023.
//

import SwiftUI

class SelectedDocketSection: ObservableObject {
    @Published var alreadySelectedSections = selectedSections
}

struct DocketSections_Previews: PreviewProvider {
    static var previews: some View {
        DocketSections()
    }
}

struct DocketSections: View {
    @State var sections = [String]()
    @StateObject var selSection = SelectedDocketSection()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationViewForDocketSections(title: "Docket Sections")
                List {
                    ForEach(sections, id: \.self) { section in
                        MultipleSelectionRow(title: section, isSelected: selSection.alreadySelectedSections.contains(section)) {
                            if selSection.alreadySelectedSections.contains(section) {
                                selSection.alreadySelectedSections.removeAll(where: { $0 == section })
                            }
                            else {
                                selSection.alreadySelectedSections.append(section)
                            }
                            selectedSections = selSection.alreadySelectedSections
                            UserDefaults.selectedDocketSections = selSection.alreadySelectedSections
                        }
                        .frame(height: 60)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .stackNavigationView()
        .onDisappear(perform: {
            sections = [String]()
            selSection.alreadySelectedSections = [String]()
        })
    }
}

struct CustomNavigationViewForDocketSections: View {
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

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .font(.customFont(withWeight: .medium, withSize: 20))
                
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.qikiColor)
                        .padding([.trailing], 10)
                }
            }
        }
    }
}
