//
//  TransactionList.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-18.
//

import SwiftUI

struct TransactionList: View {
    
    @EnvironmentObject var transactionListViewModel : TransactionListViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(transactionListViewModel.groupTransactionByMonth()), id: \.key) { month, transactions in
                    Section {
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    } header: {
                        Text(month)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionList()
        }
    }
}
