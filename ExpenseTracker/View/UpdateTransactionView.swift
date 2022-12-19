//
//  UpdateTransactionView.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-18.
//

import SwiftUI

struct UpdateTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var transactionListViewModel : TransactionListViewModel
    
    @State private var transaction : Transaction = Transaction(date: Date().formatForModel(), institution: "", account: "", merchant: "", amount: 0, type: "debit", categoryId: 101, category: "Public Transportation", isPending: false, isTransfer: false, isExpense: true, isEdited: false)
    
    @State private var date : Date = Date()
    @State private var isCurrentDate : Bool = true
    
    @State private var institution : String = ""
    @State private var account : String = ""
    @State private var merchant : String = ""
    
    @State private var amount : Int = 0
    private var numberFormatter : NumberFormatterProtocol
    
    @State private var type : TransactionType.RawValue = "debit"
    
    @State private var mainCategory : String = "Auto & Transport"
    @State private var mainCategoryId : Int64 = 1
    @State private var subCategory : String = ""
    @State private var isPending : Bool = false
    @State private var isTransfer : Bool = false
    @State private var isExpense : Bool = true
    @State private var isEdited : Bool = false
    
    @State private var showErrorAlert: Bool = false
    
    init(transaction: Transaction, numberFormatter: NumberFormatterProtocol = NumberFormatter()) {
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
        
        self.transaction = transaction
        self.date = transaction.date.parseDate()
        self.institution = transaction.institution
        self.account = transaction.account
        self.merchant = transaction.merchant
        self.amount = Int(transaction.amount * 100)
        self.type = transaction.type
        
        if Category.subCategories.contains(where: { $0.id == transaction.categoryId }) {
            self.subCategory = Category.subCategories.first(where: { $0.id == transaction.categoryId })!.name
            self.mainCategoryId = Int64(Category.categories.first(where: { $0.id == Category.subCategories.first(where: { $0.id == transaction.categoryId })!.mainCategoryId })!.id)
            self.mainCategory = Category.categories.first(where: { $0.id == Category.subCategories.first(where: { $0.id == transaction.categoryId })!.mainCategoryId })!.name
        }
        else {
            self.subCategory = ""
            self.mainCategoryId = Int64(Category.categories.first(where: { $0.id == transaction.categoryId })!.id)
            self.mainCategory = Category.categories.first(where: { $0.id == transaction.categoryId })!.name
        }
        
        self.isPending = transaction.isPending
        self.isTransfer = transaction.isTransfer
        self.isExpense = transaction.isExpense
        self.isEdited = transaction.isEdited
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding()
                }
                
                Spacer()
                
                Button {
                    updateTransaction()
                } label: {
                    Text("Save")
                        .padding()
                        .foregroundColor(Color.text)
                }
                .alert(isPresented: $showErrorAlert){
                    Alert(
                        title: Text("Required Field Empty"),
                        message: Text("Please enter an amount."),
                        dismissButton: .default(Text("Close"))
                    )
                    
                }
            }
            
            Form {
                Section {
                    CurrencyTextField(numberFormatter: numberFormatter, value: $amount)
                } header: {
                    Text("Amount")
                }
                
                Section {
                    Picker("Picker", selection: $type) {
                        Text("Debit")
                            .tag("debit")
                        
                        Text("Credit")
                            .tag("credit")
                    }
                    .onChange(of: type) { newValue in
                        isExpense = newValue == "credit" ? true : false
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Picker("Picker", selection: $isCurrentDate) {
                        Text("Today")
                            .tag(true)
                        
                        Text("Select Date")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .disabled(isCurrentDate)
                        .accentColor(Color.text)
                }
                
                Section {
                    TextField("Institution", text: $institution)
                    TextField("Account", text: $account)
                    TextField("Merchant", text: $merchant)
                }
                
                Section {
                    Picker("Main Category", selection: $mainCategory) {
                        ForEach(Category.categories) { cat in
                            Text("\(cat.name)")
                                .tag("\(cat.name)")
                                .truncationMode(.tail)
                                .lineLimit(1)
                        }
                    }
                    .onChange(of: mainCategory) { newValue in
                        mainCategory = newValue
                        mainCategoryId = Int64(Category.categories.first(where: { $0.name == newValue })!.id)
                        subCategory = ""
                    }
                    
                    Picker("Subcategory", selection: $subCategory) {
                        Text("")
                            .tag("")
                            .truncationMode(.tail)
                            .lineLimit(1)
                        
                        ForEach(Category.subCategories.filter { sc in
                            return sc.mainCategoryId == Category.categories.first(where: { $0.name == mainCategory })!.id
                        }) { subcat in
                            Text("\(subcat.name)")
                                .tag("\(subcat.name)")
                                .truncationMode(.tail)
                                .lineLimit(1)
                        }
                    }
                }
                
                Section {
                    Toggle("Pending", isOn: $isPending)
                    Toggle("Transfer", isOn: $isTransfer)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
    
    func updateTransaction() {
        if amount == 0 {
            showErrorAlert.toggle()
        }
        
        let transactionMO = transactionListViewModel.transactionsMOList.first(where: { $0.id == transaction.id })!
        
        isEdited = updateNeeded()
        
        if isEdited {
            transactionMO.date = self.date.formatForModel()
            transactionMO.institution = self.institution
            transactionMO.account = self.account
            transactionMO.merchant = self.merchant
            transactionMO.amount = Double(self.amount) / 100
            transactionMO.type = self.type
            transactionMO.categoryId = subCategory == "" ? Int64(mainCategoryId) : Int64(Category.subCategories.first(where: { $0.name == subCategory })!.id)
            transactionMO.category = subCategory == "" ? mainCategory : subCategory
            transactionMO.isPending = self.isPending
            transactionMO.isTransfer = self.isTransfer
            transactionMO.isExpense = self.isExpense
            transactionMO.isEdited = self.isEdited
        }
        
        transactionListViewModel.updateTransaction(updatedTransaction: transactionMO)
        
        transactionListViewModel.getAllTransactions()
        presentationMode.wrappedValue.dismiss()
    }
    
    func updateNeeded() -> Bool {
        let transactionMO = transactionListViewModel.transactionsMOList.first(where: { $0.id == transaction.id })!
        var needed = false
        
        if transactionMO.date != self.date.formatForModel() {
            needed = true
        }
        else if transactionMO.institution != self.institution {
            needed = true
        }
        else if transactionMO.account != self.account {
            needed = true
        }
        else if transactionMO.merchant != self.merchant {
            needed = true
        }
        else if Int(transactionMO.amount * 100) != self.amount {
            needed = true
        }
        else if transactionMO.type != self.type {
            needed = true
        }
        else if (transactionMO.category != self.subCategory) && (transactionMO.category != self.mainCategory)  {
            needed = true
        }
        else if transactionMO.isPending != self.isPending {
            needed = true
        }
        else if transactionMO.isTransfer != self.isTransfer {
            needed = true
        }
        else if transactionMO.isExpense != self.isExpense {
            needed = true
        }
        
        return needed
    }
}

//struct UpdateTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpdateTransactionView(transaction: transactionPreviewData)
//    }
//}
