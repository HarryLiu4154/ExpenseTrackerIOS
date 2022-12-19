//
//  NewTransactionView.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-18.
//

import SwiftUI

struct NewTransactionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var transactionListViewModel : TransactionListViewModel
    
    @State private var date : Date = Date()
    @State private var isCurrentDate : Bool = true
    
    @State private var institution : String = ""
    @State private var account : String = ""
    @State private var merchant : String = ""
    
    @State private var amount : Int = 0
    private var numberFormatter : NumberFormatterProtocol
    
    @State private var type : TransactionType.RawValue = "credit"
    
    @State private var mainCategory : String = "Auto & Transport"
    @State private var mainCategoryId : Int64 = 1
    @State private var subCategory : String = ""
    @State private var isPending : Bool = false
    @State private var isTransfer : Bool = false
    @State private var isExpense : Bool = true
    @State private var isEdited : Bool = false
    
    @State private var showErrorAlert: Bool = false
    
    init(numberFormatter: NumberFormatterProtocol = NumberFormatter()) {
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
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
                    saveTransaction()
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
                        Text("Credit")
                            .tag("credit")
                        
                        Text("Debit")
                            .tag("debit")
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
    
    func saveTransaction() {
        if amount == 0 {
            showErrorAlert.toggle()
        }
        
        transactionListViewModel.insertTransaction(
            transaction: Transaction(
                date: self.date.formatForModel(),
                institution: self.institution,
                account: self.account,
                merchant: self.account,
                amount: Double(self.amount) / 100,
                type: self.type,
                categoryId: subCategory == "" ? Int64(mainCategoryId) : Int64(Category.subCategories.first(where: { $0.name == subCategory })!.id),
                category: subCategory == "" ? mainCategory : subCategory,
                isPending: self.isPending,
                isTransfer: self.isTransfer,
                isExpense: self.isExpense,
                isEdited: self.isEdited
            )
        )
        
        transactionListViewModel.getAllTransactions()
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NewTransactionView()
    }
}
