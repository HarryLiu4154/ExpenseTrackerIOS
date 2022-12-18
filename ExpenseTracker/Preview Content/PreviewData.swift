//
//  PreviewData.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-14.
//

import Foundation
import CoreData

var transactionPreviewData = Transaction(
    date: "12/14/2022",
    institution: "Mastercard",
    account: "BMO Mastercard",
    merchant: "Apple",
    amount: 1.99,
    type: "credit",
    categoryId: 801,
    category: "Software",
    isPending: false,
    isTransfer: false,
    isExpense: true,
    isEdited: false
)

var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count: 5)

var transactionMOPreviewData = NSEntityDescription.insertNewObject(forEntityName: "TransactionMO", into: PersistenceController.shared.container.viewContext) as! TransactionMO

var transactionMOListPreviewData = [TransactionMO](repeating: transactionMOPreviewData, count: 5)

