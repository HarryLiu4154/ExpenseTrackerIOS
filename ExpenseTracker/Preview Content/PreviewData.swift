//
//  PreviewData.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-14.
//

import Foundation

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
