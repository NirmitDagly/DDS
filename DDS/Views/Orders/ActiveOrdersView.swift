//
//  ActiveOrdersView.swift
//  DDS
//
//  Created by Nirmit Dagly on 3/1/2023.
//

import SwiftUI

struct ActiveOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveOrdersView()
    }
}

struct ActiveOrdersView: View {
    @State var shouldShowHistoryOrders = false
    @State var shouldShowSettings = false
    @State var shouldShowRundown = false
    
    @State var shouldShowAlert = true
    
    @StateObject var fetchActiveOrders = GetActiveOrders()
    @StateObject var bgColor = UpdateBackgroundViewColor()
    
    var body: some View {
        ZStack() {
            VStack(spacing: 0) {
                CustomNavigationView(title: "Active Orders", displayRundown: fetchActiveOrders.displayRundown, shouldShowHistoryOrders: $shouldShowHistoryOrders, shouldShowSettings: $shouldShowSettings, shouldShowRundown: $shouldShowRundown, fetchActiveOrders: fetchActiveOrders)
                
                Spacer()
                
                if shouldShowAlert == true {
                    NoSectionAlert()
                }
                else {
                    if shouldShowRundown == true {
                        DisplayOrdersWithProductSummary(fetchActiveOrders: fetchActiveOrders, bgColor: bgColor, shouldShowRunDown: $shouldShowRundown)
                    }
                    else {
                        OrdersView(fetchedOrders: fetchActiveOrders, bgColor: bgColor, shouldShowRunDown: $shouldShowRundown)
                    }
                }
                
                Spacer()
            }
            .onAppear {
                if selectedSections.count == 0 {
                    shouldShowAlert = true
                }
                else {
                    shouldShowAlert = false
                    fetchActiveOrders.getActiveOrders()
                }
            }
            .alert(item: $fetchActiveOrders.info, content: { info in
                Alert(title: Text(info.title), message: Text(info.message))
            })
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .stackNavigationView()
    }
}

struct CustomNavigationView: View {
    var title: String
    @ObservedObject var displayRundown: DisplayRunDownList
    @Binding var shouldShowHistoryOrders: Bool
    @Binding var shouldShowSettings: Bool
    @Binding var shouldShowRundown: Bool
    
    @ObservedObject var fetchActiveOrders: GetActiveOrders
    
    var body: some View {
        ZStack {
            HStack() {
                if displayRundown.shouldDisplayRundown == true {
                    Button {
                        if shouldShowRundown == false {
                            shouldShowRundown = true
                        }
                        else {
                            shouldShowRundown = false
                        }
                    } label: {
                        Image(systemName: "doc.text.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color.white)
                            .padding([.leading], 20)
                    }
                }
                
                Spacer()
                
                GeometryReader { geometryReader in
                    Text(title)
                        .foregroundColor(.white)
                        .font(.customFont(withWeight: .demibold, withSize: 24))
                        .frame(width: geometryReader.size.width, alignment: .center)
                        .padding(.top, 15)
                        .padding(.leading, 100)
                }
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: CompletedOrdersView(shouldShowAlert: docketSections.count > 0 ? false : true), isActive: $shouldShowHistoryOrders) {
                        Button {
                            shouldShowHistoryOrders = true
                        } label: {
                            Text("Completed Orders")
                                .foregroundColor(.white)
                                .font(.customFont(withWeight: .medium, withSize: 20))
                                .frame(alignment: .center)
                                .padding(.trailing, 10)
                        }
                    }
                    
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
            }
        }
        .frame(height: 64, alignment: .center)
        .background(Color.qikiColor)
        .padding([.top], 20)
        .edgesIgnoringSafeArea(.all)
    }
}

struct NoSectionAlert: View {
    var body: some View {
        Text("You need to setup docket sections first.\n\nYou can select desired sections from:\n 'Settings -> Docket Sections'")
            .foregroundColor(.qikiRed)
            .font(.customFont(withWeight: .medium, withSize: 22))
            .multilineTextAlignment(.center)
    }
}

struct DisplayOrdersWithProductSummary: View {
    @ObservedObject var fetchActiveOrders: GetActiveOrders
    @ObservedObject var bgColor: UpdateBackgroundViewColor
    @Binding var shouldShowRunDown: Bool

    var body: some View {
        HStack {
            if fetchActiveOrders.orders.count > 0 {
                ProductSummaryView(fetchedOrders: fetchActiveOrders)
                    .frame(width: 300)
                
                OrdersView(fetchedOrders: fetchActiveOrders, bgColor: bgColor, shouldShowRunDown: $shouldShowRunDown)
            }
        }
    }
}

struct OrdersView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
    @ObservedObject var bgColor: UpdateBackgroundViewColor
    @Binding var shouldShowRunDown: Bool
    @State var gridItems = [GridItem]()
    
    var body: some View {
        HStack() {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(fetchedOrders.orders, id: \.self) { order in
                        ActiveOrderDisplayView(fetchedOrders: fetchedOrders, bgColor: bgColor, order: individualOrderDetail(forOrder: order))
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
        if shouldShowRunDown == true {
            allocatedGridItems = Array(repeating: .init(.adaptive(minimum: 320, maximum: 320), spacing: 20, alignment: .top), count: 1)
        }
        else {
            allocatedGridItems = Array(repeating: .init(.adaptive(minimum: 320, maximum: 320), spacing: 20, alignment: .top), count: 2)
        }
        
        return allocatedGridItems
    }
    
    func individualOrderDetail(forOrder order: Order) -> Order {
        return order
    }
}

struct ProductSummaryView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
    
    var body: some View {
        List {
            ForEach(fetchedOrders.productSummary.productSummary, id: \.self) { summary in
                let productDetails = fetchedOrders.formattedProductSummary(forProductSummary: summary)
                
                HStack {
                    Text(productDetails.productName)
                    if productDetails.hasDietary == true {
                        Image(systemName: "exclamationmark.triangle")
                            .padding(.trailing, 10)
                    }
                }
            }
        }
    }
}

struct ActiveOrderDisplayView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
    @ObservedObject var bgColor: UpdateBackgroundViewColor
    
    @State var order: Order
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack {
                    OrderTypeView(fetchedOrders: fetchedOrders, order: $order)
                    OrderNumberView(fetchedOrders: fetchedOrders, order: $order)
                    TimerView(fetchedOrders: fetchedOrders, order: $order, bgColor: bgColor)
                }
                .background(setBackgroundColor())
                .cornerRadius(7, corners: [.topLeft, .topRight])
                
                VStack(spacing: 0) {
                    ProductListView(fetchedOrders: fetchedOrders, order: $order)
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
    
    func setBackgroundColor() -> Color {
        var backgroundColor = Color.green
        
        let updatedTime = fetchedOrders.updateTimeForTables(forOrder: order)
        
        if updatedTime["isExceededTime"] as! Bool == true {
            backgroundColor = Color.red
        }
        else {
            backgroundColor = Color.qikiGreen
        }
        
        return backgroundColor
    }
}

struct ProductListView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
    @Binding var order: Order
    
    var body: some View {
        ForEach((order.products), id: \.addedProductID!) { product in
            HStack(alignment: .top) {
                Button {
                    for i in 0 ..< fetchedOrders.orders.count {
                        if fetchedOrders.orders[i].terminalOrderNo == order.terminalOrderNo && fetchedOrders.orders[i].sequenceNo == order.sequenceNo {
                            for j in 0 ..< fetchedOrders.orders[i].products.count {
                                if fetchedOrders.orders[i].products[j].addedProductID! == product.addedProductID! {
                                    if fetchedOrders.orders[i].products[j].isDelivered == 0 {
                                        fetchedOrders.orders[i].products[j].isDelivered = 1
                                    }
                                    else {
                                        fetchedOrders.orders[i].products[j].isDelivered = 0
                                    }
                                    
                                    fetchedOrders.markIndividualItemAsDelivered(forOrderNo: order.orderNo, andSequenceNo: order.sequenceNo, andAddedProductID: fetchedOrders.orders[i].products[j].addedProductID!, andSection: fetchedOrders.orders[i].products[j].docketType[0], andIsDelivered: fetchedOrders.orders[i].products[j].isDelivered ?? 0)
                                    break
                                }
                            }
                        }
                    }
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
                
                let productDetails = fetchedOrders.productsAndDetails(product: product).string

                if product.isDeleted == 1 {
                    Text.init(productDetails)
                        .font(.customFont(withWeight: .medium, withSize: 16))
                        .frame(alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.top, 2.5)
                        .strikethrough(true, pattern: .solid, color: .gray)
                }
                else {
                    Text.init(productDetails)
                        .font(.customFont(withWeight: .medium, withSize: 16))
                        .frame(alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.top, 2.5)
                }
                
                Spacer()
            }
        }
    }
}

struct OrderTypeView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
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

struct OrderNumberView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
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
                let allProducts = order.products
                var addedProductIDs = [Int]()
                for i in 0 ..< allProducts.count {
                    addedProductIDs.append(allProducts[i].addedProductID!)
                }
                
                fetchedOrders.markOrderAsCompleted(forOrderNo: order.orderNo, andSequenceNo: order.sequenceNo, andAddedProductIDs: addedProductIDs)
            } label: {
                Text("Mark Delivered")
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
    }
}

struct TimerView: View {
    @ObservedObject var fetchedOrders: GetActiveOrders
    @Binding var order: Order
    @ObservedObject var bgColor: UpdateBackgroundViewColor
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var updatedTime = [String: Any]()
    @State var orderTime = ""
    
    var body: some View {
        HStack {
            Text(orderTime)
                .font(.customFont(withWeight: .medium, withSize: 16))
                .foregroundColor(.white)
                .frame(height: 40)
                .multilineTextAlignment(.leading)
                .padding([.leading], 10)
                .onReceive(timer) { _ in
                    updatedTime = fetchedOrders.updateTimeForTables(forOrder: order)
                    orderTime = updatedTime["timeToDisplay"] as! String
                }
            
            Spacer()
            
            if order.isUrgent == 0 {
                Button {
                    fetchedOrders.markOrderAsUrgent(forOrderNo: order.orderNo, andSequenceNo: order.sequenceNo)
                    fetchedOrders.orders.removeAll(where: {$0.terminalOrderNo == order.terminalOrderNo && $0.sequenceNo == order.sequenceNo})
                    fetchedOrders.orders.insert(order, at: 0)
                } label: {
                    Text("Mark Urgent")
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
        }
        .padding([.bottom], 10)
    }
}

class GetActiveOrders: ObservableObject {
    @Published var orders = [Order]()
    var tableOnTimer: Timer?
    @ObservedObject var productSummary = ProductSummary()
    @ObservedObject var displayRundown = DisplayRunDownList()
    @Published var info: AlertInfo?
    
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
    
    //MARK: Combine Products to display the product summary
    func combineProductsForSummaryDisplay() -> ProductSummary {
        productSummary = ProductSummary()
        
        for i in 0 ..< orders.count {
            for k in 0 ..< orders[i].products.count {
                if i == 0 && k == 0 {
                    let productName = orders[i].products[k].name
                    let qty = orders[i].products[k].qty
                    let dietary = orders[i].products[k].dietary
                    let isDeleted = orders[i].products[k].isDeleted
                    
                    if isDeleted == 0 {
                        let summary = DisplayProductSummary.init(productName: productName, qty: qty, dietary: dietary)
                        productSummary.productSummary.append(summary)
                    }
                }
                else {
                    let productName = orders[i].products[k].name
                    let qty = orders[i].products[k].qty
                    let dietary = orders[i].products[k].dietary
                    let isDeleted = orders[i].products[k].isDeleted
                    
                    if isDeleted == 0 {
                        if productSummary.productSummary.contains(where: {($0.productName == productName) && ($0.dietary == dietary)}) {
                            for j in 0 ..< productSummary.productSummary.count {
                                if productSummary.productSummary[j].productName == productName && productSummary.productSummary[j].dietary == dietary {
                                    productSummary.productSummary[j].qty = productSummary.productSummary[j].qty + qty
                                    break
                                }
                            }
                        }
                        else {
                            let summary = DisplayProductSummary.init(productName: productName, qty: qty, dietary: dietary)
                            productSummary.productSummary.append(summary)
                        }
                    }
                }
            }
        }
        productSummary.productSummary = productSummary.productSummary.sorted(by: {$0.qty > $1.qty})
        return productSummary
    }
    
    //MARK: Format products summary to display on the screen
    func formattedProductSummary(forProductSummary productSummary: DisplayProductSummary) -> FinalSummary {
        var formattedSummary = FinalSummary(productName: "", hasDietary: false)
        
        let productName = (productSummary.productName).components(separatedBy: "-")
        var formattedName = "\(productSummary.qty) X \(productName[0])\n"
        if productName.count > 1 {
            for i in 1 ..< productName.count {
                formattedName = formattedName + "   - \(productName[i])\n"
            }
        }
        
        let hasDietary = (productSummary.dietary) != "" ? true : false
        formattedSummary = FinalSummary.init(productName: formattedName, hasDietary: hasDietary)
        
        return formattedSummary
    }
    
    //MARK: Following functions will be used to schedule timer to display table active time and destory them.
    func invalidateTimer() {
        activeOrdersTimer?.invalidate()
        activeOrdersTimer = nil
        
        tableOnTimer?.invalidate()
        tableOnTimer = nil
    }
    
    //MARK: Following functions will be used to schedule timer to display table active time and destory them.
    func scheduleTimerToUpdateCollectionView() {
        if tableOnTimer == nil {
            tableOnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateOrderView), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateOrderView() {
        
    }
    
    //MARK: Update Timer for only visible cells on the layout
    func updateTimeForTables(forOrder order: Order) -> [String: Any] {
        var timeDetail = [String: Any]()
        if order.dateAdded != "" {
            var timeToDisplay = "00:00:00"
            var isExceeededTime = false
            
            var hoursToDisplay = ""
            var minutesToDisplay = ""
            var secondsToDisplay = ""
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let referenceDateTime = dateFormat.date(from: order.dateAdded!)!
            
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            
            let convertedDate = df.string(from: referenceDateTime)
            let convertedDateTime = df.date(from: convertedDate)
            
            let presentDate = dateFormat.string(from: Date())
            let currentDateTime = dateFormat.date(from: presentDate)
            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: convertedDateTime!, to: currentDateTime!)
            
            let hours = diffComponents.hour
            let minutes = diffComponents.minute
            let seconds = diffComponents.second
            
            if hours! < 10 {
                hoursToDisplay = "0\(String(hours!))"
            }
            else {
                hoursToDisplay = String(hours!)
            }
            
            if minutes! < 10 {
                minutesToDisplay = "0\(String(minutes!))"
            }
            else {
                minutesToDisplay = String(minutes!)
            }
            
            if seconds! < 10 {
                secondsToDisplay = "0\(String(seconds!))"
            }
            else {
                secondsToDisplay = String(seconds!)
            }
            
            timeToDisplay = "\(hoursToDisplay):\(minutesToDisplay):\(secondsToDisplay)"
            
            switch order.deliveryType {
                case .pickup:
                    if currentDateTime!.timeIntervalSince(convertedDateTime!) > (3 * 60) {
                        isExceeededTime = true
                    }
                case .delivery:
                    if currentDateTime!.timeIntervalSince(convertedDateTime!) > (3 * 60) {
                        isExceeededTime = true
                    }
                case .dineIn:
                    if currentDateTime!.timeIntervalSince(convertedDateTime!) > (20 * 60) {
                        isExceeededTime = true
                    }
            }
            
            timeDetail = ["timeToDisplay": timeToDisplay, "isExceededTime": isExceeededTime]
        }
        
        return timeDetail
    }
    
    //MARK: Schedule timer to call the active order in background
    func scheduleTimerToGetActiveOrders() {
        if activeOrdersTimer == nil {
            activeOrdersTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getActiveOrders), userInfo: nil, repeats: true)
        }
    }
    
    //MARK: This function will fecth the completed orders of the current date.
    @objc func getActiveOrders() {
        invalidateTimer()
        print("Fetching active orders...")
        
        OrderServices.shared.getActiveOrders(orderStatus: "Active") { result in
            switch result {
                case .failure(let error):
                    print("Failed to get active orders...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    Helper.loadingSpinner(isLoading: false, isUserInteractionEnabled: true, withMessage: "")
                    self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.getOrders_Active)))", message: "\(error)")
                    
                    self.scheduleTimerToGetActiveOrders()
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
                        
                        self.filterOrdersToDisplay()
                        self.productSummary = self.combineProductsForSummaryDisplay()
                    }
                    else {
                        self.orders = [Order]()
                    }
                    self.shouldDisplayRunDownOption()
                    self.scheduleTimerToGetActiveOrders()
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
    func markOrderAsCompleted(forOrderNo orderNo: Int, andSequenceNo seqNo: Int, andAddedProductIDs addedProductIDs: [Int]) {
        invalidateTimer()
        
        OrderServices.shared.markOrderAsCompleted(forOrderNumber: orderNo, andSequenceNo: seqNo, forAddedProductIDs: addedProductIDs) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark order \(orderNo) as completed...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markAsCompleted)))", message: error.localizedDescription)
                    self.scheduleTimerToGetActiveOrders()
                case .success(_):
                    print("Order successfully marked as completed...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Order No: \(orderNo) has been marked as completed successfully...")
                    
                    self.orders.removeAll(where: {$0.orderNo == orderNo && $0.sequenceNo == seqNo})
                    
                    self.productSummary = self.combineProductsForSummaryDisplay()
                    self.scheduleTimerToGetActiveOrders()
            }
        }
    }
    
    //MARK: To mark order as urgent.
    func markOrderAsUrgent(forOrderNo orderNo: Int, andSequenceNo seqNo: Int) {
        OrderServices.shared.markOrderAsUrgent(forOrderNumber: orderNo, andSequenceNo: seqNo) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark order \(orderNo) as urgent...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markAsUrgent)))", message: error.localizedDescription)
                case .success(_):
                    print("Order successfully marked as urgent...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Order No: \(orderNo) has been marked as urgent successfully...")
            }
        }
    }
    
    //MARK: To mark individual item as delivered.
    func markIndividualItemAsDelivered(forOrderNo orderNo: Int, andSequenceNo seqNo: Int, andAddedProductID addedProductID: Int, andSection section: String, andIsDelivered isDelivered: Int) {
        OrderServices.shared.markItemAsDelivered(forOrderNumber: orderNo, andSequenceNo: seqNo, forAddedProductID: addedProductID, andHasSection: section, andIsDelivered: isDelivered) { result in
            switch result {
                case .failure(let error):
                    print("Failed to mark item id: \(addedProductID) for Order: \(orderNo) as delivered...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "\(error)")
                    
                    self.info = AlertInfo(id: .one, title: "Something Went Wrong (Error code: \(Helper.errorForAPI(APIErrorCode.markIndividualItemDelivered)))", message: error.localizedDescription)
                case .success(_):
                    print("Item marked delivered / not delivered successfully...")
                    Logs.writeLog(onDate: Helper.getCurrentDateAndTime(), andDescription: "Item ID: \(addedProductID) for Order No: \(orderNo) has been marked \(isDelivered) successfully...")
            }
        }
    }
    
    //MARK: Generate TableNumber to display.
    func generateTableNoToDisplay(forTableNo tableNumber: String, andTabNumber tabNumber: Int?, withTabName tabName: String?) -> String {
        var tableNo = tableNumber
        if tabNumber != nil && tabNumber != 1 {
            tableNo = tableNumber + "-" + "\(tabNumber!)"
        }
        
        if tabName != nil && tabName != ""  {
            tableNo = tableNo + "-" + "\(tabName!)"
        }
        
        return tableNo
    }
    
    //MARK: Notify to display the product summary view or not based on the orders count
    func shouldDisplayRunDownOption() {
        if orders.count > 0 {
            displayRundown.shouldDisplayRundown = true
        }
        else {
            displayRundown.shouldDisplayRundown = false
        }
    }
}

class UpdateBackgroundViewColor: ObservableObject {
    @Published var backgroundColor = Color.qikiGreen
}

class ProductSummary: ObservableObject {
    @Published var productSummary = [DisplayProductSummary]()
}

class DisplayRunDownList: ObservableObject {
    @Published var shouldDisplayRundown = false
}

struct DisplayProductSummary: Hashable {
    var productName: String
    var qty: Int
    var dietary: String
    
    // Hashing
    func hash(into hasher: inout Hasher) {
        hasher.combine(qty)
    }
}

struct FinalSummary: Hashable {
    var productName: String
    var hasDietary: Bool
    
    // Hashing
    func hash(into hasher: inout Hasher) {
        hasher.combine(productName)
    }
}
