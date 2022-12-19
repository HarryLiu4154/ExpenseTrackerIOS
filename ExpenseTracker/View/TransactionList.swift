//
//  TransactionList.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-18.
//

import SwiftUI

struct TransactionList: View {
    
    @EnvironmentObject var transactionListViewModel : TransactionListViewModel
    @State private var isAddingTransactionPresented = false
    @State private var isEditingTransactionPresented = false
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(transactionListViewModel.groupTransactionByMonth()), id: \.key) { month, transactions in
                    Section {
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .onTapGesture {
                                    isEditingTransactionPresented.toggle()
                                }
                                .sheet(isPresented: $isEditingTransactionPresented) {
                                    UpdateTransactionView(transaction: transaction)
                                }
                        }
                        .onDelete(perform: delete)
                    } header: {
                        Text(month)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            //.background(Color.background)
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    isAddingTransactionPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.icon, .primary)
                }
                .sheet(isPresented: $isAddingTransactionPresented) {
                    NewTransactionView()
                }
                
                EditButton()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for i in offsets.makeIterator() {
            let tempId = transactionListViewModel.transactions.first(where: { $0.id == transactionListViewModel.transactions[i].id })!.id
            transactionListViewModel.deleteTransaction(id: tempId)
        }
        
        transactionListViewModel.transactions.remove(atOffsets: offsets)
        transactionListViewModel.getAllTransactions()
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionList()
        }
    }
}
