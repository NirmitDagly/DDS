//
//  CompletedOrdersView.swift
//  DDS
//
//  Created by Nirmit Dagly on 21/2/2023.
//

import Foundation
import SwiftUI

struct CompletedOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedOrdersView()
    }
}

struct CompletedOrdersView: View {
    @State var shouldShowSettings = false
    @State var shouldShowAlert = true
    
    @StateObject var fetchCompletedOrders = GetHistoryOrders()
    @StateObject var bgColor = UpdateBackgroundViewColor()

    var body: some View {
        ZStack() {
            VStack(spacing: 0) {
                CustomNavigation(title: "Completed Orders", shouldShowSettings: $shouldShowSettings)
                
                Spacer()
                
                if shouldShowAlert == true {
                    NoSectionAlert()
                }
                else {
                    HistoryOrdersView(fetchedOrders: fetchCompletedOrders, bgColor: bgColor)
                }
                
                Spacer()
            }
            .onAppear {
                fetchCompletedOrders.getCompletedOrders()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .stackNavigationView()
    }
}

struct CustomNavigation: View {
    var title: String
    @Binding var shouldShowSettings: Bool
    
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
            
            NavigationLink(destination: Settings(), isActive: $shouldShowSettings) {
                Button {
                    shouldShowSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color.white)
                        .padding([.trailing], 20)
                }
            }
        }
        .frame(height: 64, alignment: .center)
        .background(Color.qikiColor)
        .padding([.top], 20)
        .edgesIgnoringSafeArea(.all)
    }
}

struct HistoryOrdersView: View {
    @ObservedObject var fetchedOrders: GetHistoryOrders
    @ObservedObject var bgColor: UpdateBackgroundViewColor
    @State var gridItems = [GridItem]()
    
    var body: some View {
        HStack() {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(fetchedOrders.orders, id: \.self) { order in
                        HistoryOrderDisplayView(fetchedOrders: fetchedOrders, bgColor: bgColor, order: individualOrderDetail(forOrder: order))
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear() {
            gridItems = allocateGridItems()
        }
    }
    
    func allocateGridItems() -> [GridItem] {
        var allocatedGridItems = [GridItem]()
            allocatedGridItems = Array(repeating: .init(.adaptive(minimum: 320, maximum: 320), spacing: 20, alignment: .top), count: 2)
        
        return allocatedGridItems
    }
    
    func individualOrderDetail(forOrder order: Order) -> Order {
        return order
    }
}

struct HistoryOrderDisplayView: View {
    @ObservedObject var fetchedOrders: GetHistoryOrders
    @ObservedObject var bgColor: UpdateBackgroundViewColor
    
    @State var order: Order
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack {
                    HistoryOrderTypeView(fetchedOrders: fetchedOrders, order: $order)
                    HistoryOrderNumberView(fetchedOrders: fetchedOrders, order: $order)
                }
                .background(Color.qikiGreen)
                .cornerRadius(7, corners: [.topLeft, .topRight])
                
                VStack(spacing: 0) {
                    HistoryProductListView(fetchedOrders: fetchedOrders, order: $order)
                        .padding(.top, 10)
                        .background(Color.qikiColorDisabled)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.qikiColor, lineWidth: 1)
            )
        }
    }
}


struct HistoryOrderTypeView: View {
    @ObservedObject var fetchedOrders: GetHistoryOrders
    @Binding var order: Order
    
    var body: some View {
        HStack {
            Text(order.deliveryType.rawValue)
                .font(.customFont(withWeight: .medium, withSize: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding([.leading, .top], 10)
            
            Spacer()
            if order.deliveryType.rawValue == DeliveryType.pickup.rawValue {
                Text("ASAP")
                    .font(.customFont(withWeight: .medium, withSize: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .padding([.trailing], 10)
            }
            else if order.deliveryType.rawValue == DeliveryType.dineIn.rawValue {
                
                Text("Table #: \(fetchedOrders.generateTableNoToDisplay(forTableNo: order.tableNo!, andTabNumber: order.tabNumber, withTabName: order.tabName))")
                    .font(.customFont(withWeight: .medium, withSize: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .padding([.trailing], 10)
            }
        }
    }
}

struct HistoryOrderNumberView: View {
    @ObservedObject var fetchedOrders: GetHistoryOrders
    @Binding var order: Order
    
    var body: some View {
        HStack {
            Text("\(Helper.generateOrderNumberWithPrefix(orderNo: order.terminalOrderNo, orderFrom: order.orderOrigin))")
                .font(.customFont(withWeight: .medium, withSize: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding([.leading], 10)
            Spacer()
            Button {
                var sectionOfProducts = [String]()
                for i in 0 ..< order.products.count {
                    let dockets = order.products[i].docketType
                    for j in 0 ..< dockets.count {
                        if sectionOfProducts.contains(where: {$0 == dockets[j]}) {
                            //Don't add docket section again
                        }
                        else {
                            sectionOfProducts.append(dockets[j])
                        }
                    }
                }

                fetchedOrders.markOrderAsActive(forOrderNo: order.orderNo, andSequenceNo: order.sequenceNo, withProductSections: sectionOfProducts)
            } label: {
                Text("Mark Active")
                    .font(.customFont(withWeight: .medium, withSize: 16))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.qikiColor)
                    )
            }
            .frame(width: 160, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.qikiColor, lineWidth: 1)
            )
            .padding([.trailing], 10)
        }
        .padding([.bottom], 10)
    }
}

struct HistoryProductListView: View {
    @ObservedObject var fetchedOrders: GetHistoryOrders
    @Binding var order: Order
    
    var body: some View {
        ForEach((order.products), id: \.addedProductID!) { product in
            HStack(alignment: .top) {
                Button {
                    //No need to add any action at this moment...
                } label: {
                    if product.isDelivered != nil && product.isDelivered == 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.qikiColor)
                            .frame(width: 25, height: 25, alignment: .leading)
                            .padding(.leading, 10)
                    }
                    else {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.qikiColor)
                            .frame(width: 25, height: 25, alignment: .leading)
                            .padding(.leading, 10)
                    }
                }
                
                Text.init(fetchedOrders.productsAndDetails(product: product).string)
                    .font(.customFont(withWeight: .medium, withSize: 16))
                    .frame(alignment: .leading)
                    .padding([.leading, .trailing], 10)
                    .padding(.top, 2.5)
                
                Spacer()
            }
        }
    }
}


class GetHistoryOrders: ObservableObject {
    @Published var info: AlertInfo?
    
    @Published var orders = [Order]()
    
    //MARK: This function will create a product string with dietary requirements to be displayed on screen.
    func productsAndDetails(product: Product) -> NSMutableAttributedString {
        let orderDetails = NSMutableAttributedString.init()
        
        let productName = product.name
        let dietryReq = product.dietary
        let isDeleted = product.isDeleted
        
        let updatedProductName = NSMutableAttributedString.init()
        
        let productWithOptions = productName.components(separatedBy: "-")
        let productNameWithQuantity = NSMutableAttributedString.init(string: "\(product.qty) X \(productWithOptions[0])\n")
        
        if isDeleted == 1 {
            productNameWithQuantity.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                                   NSAttributedString.Key.strikethroughColor: UIColor.darkGray],
                                                  range: NSMakeRange(0, productNameWithQuantity.length))
        }
        
        let productAttributes = NSMutableAttributedString.init()
        if product.attributes != nil && product.attributes!.count > 0 {
            for j in 0 ..< product.attributes!.count {
                let attribute = NSMutableAttributedString.init(string: "   - \(product.attributes![j].name)\n")
                productAttributes.append(attribute)
            }
        }
        
        if isDeleted == 1 {
            productAttributes.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                             NSAttributedString.Key.strikethroughColor: UIColor.darkGray],
                                            range: NSMakeRange(0, productAttributes.length))
        }
        
        let dietaryReq = NSMutableAttributedString.init()
        if dietryReq != "" {
            let dietary = NSMutableAttributedString.init(string: "Dietary Requirements: ")
            let requirement = NSMutableAttributedString.init(string: "\(dietryReq)\n")
            
            if isDeleted == 1 {
                requirement.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                           NSAttributedString.Key.strikethroughColor: UIColor.darkGray],
                                          range: NSMakeRange(0, requirement.length))
            }
            dietaryReq.append(dietary)
            dietaryReq.append(requirement)
        }
        
        updatedProductName.append(productNameWithQuantity)
        updatedProductName.append(productAttributes)
        updatedProductName.append(dietaryReq)
        orderDetails.append(updatedProductName)
        
        return orderDetails
    }
    
    //MARK: Combine Product to display on the card
    func combineProductForOrderDisplay() {
        for i in 0 ..< orders.count {
            var combinedProductsToDisplay = [Product]()
            for k in 0 ..< orders[i].products.count {
                let productName = orders[i].products[k].name
                let qty = orders[i].products[k].qty
                let dietary = orders[i].products[k].dietary
                
                if combinedProductsToDisplay.contains(where: {$0.name == productName && $0.dietary == dietary}) {
                    for j in 0 ..< combinedProductsToDisplay.count {
                        if combinedProductsToDisplay[j].name == productName && combinedProductsToDisplay[j].dietary == dietary
                        {
                            combinedProductsToDisplay[j].qty = combinedProductsToDisplay[j].qty + qty
                            break
                        }
                    }
                }
                else {
                    combinedProductsToDisplay.append(orders[i].products[k])
                }
            }
            self.orders[i].products = combinedProductsToDisplay
        }
    }
    
    //MARK: This function will fecth the completed orders of the current date.
    @objc func getCompletedOrders() {
        print("Fetching history orders...")
        
        OrderServices.shared.getHistoryOrders(orderStatus: "History") { result in
            switch result {
                case .failure(let error):
                    print("Failed to get active orders...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getOrders_Active)))", message: error.localizedDescription)
                    
                case .success(let resp):
                    if resp.orders.count > 0 {
                        self.orders = resp.orders
                        self.orders.sort(by: {$0.isUrgent > $1.isUrgent})
                        
                        for i in 0 ..< self.orders.count {
                            if self.orders[i].deletedProducts != nil && self.orders[i].deletedProducts!.count > 0 {
                                for j in 0 ..< self.orders[i].deletedProducts!.count {
                                    self.orders[i].deletedProducts![j].isDeleted = 1
                                }
                                self.orders[i].products = self.orders[i].products + self.orders[i].deletedProducts!
                            }
                        }
                        
                        if UserDefaults.selectedDocketSections != nil && UserDefaults.selectedDocketSections!.contains("Terminal") {
                                //Don't remove any products from order, as the Section is selected as 'Terminal'. Hence, all items will be displayed here...
                        }
                        else {
                            self.filterOrdersToDisplay()
                        }
                    }
            }
        }
    }
    
    //MARK: Filter Orders based on selected sections to display
    func filterOrdersToDisplay() {
        for i in 0 ..< self.orders.count {
            var productsOfOrder = self.orders[i].products
            productsOfOrder.forEach { product in
                for i in 0 ..< product.docketType.count {
                    if selectedSections.contains(where: {$0 == product.docketType[i]}) {
                        break
                    }
                    else if i == product.docketType.count - 1 {
                        productsOfOrder.removeAll(where: {$0 == product})
                    }
                    else {
                            //Keep the loop running...
                    }
                }
            }
            
            if productsOfOrder.count > 0 {
                self.orders[i].products = productsOfOrder
            }
            else {
                self.orders[i].products = [Product]()
            }
        }
        orders.removeAll(where: {$0.products.count == 0})
    }
    
    //MARK: To mark order as completed.
    func markOrderAsActive(forOrderNo orderNo: Int, andSequenceNo seqNo: Int, withProductSections sections: [String]) {
        OrderServices.shared.markOrderAsActive(forOrderNumber: orderNo, andSequenceNo: seqNo, withProductSections: sections) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark order \(orderNo) as completed...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markAsCompleted)))", message: error.localizedDescription)
                case .success(_):
                    print("Order successfully marked as completed...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Order No: \(orderNo) has been marked as completed successfully...")
                    
                    self.orders.removeAll(where: {$0.orderNo == orderNo && $0.sequenceNo == seqNo})
            }
        }
    }

    //MARK: Generate TableNumber to display.
    func generateTableNoToDisplay(forTableNo tableNumber: String, andTabNumber tabNumber: Int?, withTabName tabName: String?) -> String {
        var tableNo = ""
        if tabNumber != nil && tabNumber != 1 {
            tableNo = tableNumber + "-" + "\(tabNumber!)"
        }
        
        if tabName != nil && tabName != ""  {
            tableNo = tableNo + "-" + "\(tabName!)"
        }
        
        return tableNo
    }
}
