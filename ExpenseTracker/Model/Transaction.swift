//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-14.
//

import Foundation
import SwiftUIFontIcon

enum TransactionType : String {
    case credit = "credit"
    case debit = "debit"
}

struct Transaction : Identifiable, Hashable {
    let id : UUID
    let date : String //
    let institution : String
    let account : String
    let merchant : String
    let amount : Double
    let type : TransactionType.RawValue
    var categoryId : Int64
    var category : String
    let isPending : Bool
    var isTransfer : Bool
    var isExpense : Bool
    var isEdited : Bool
    
    var parsedDate : Date {
        date.parseDate()
    }
    
    var signedAmount : Double {
        return type == TransactionType.credit.rawValue ? amount : -amount
    }
    
    var icon: FontAwesomeCode {
        if let category = Category.all.first(where: { $0.id == categoryId }) {
            return category.icon
        }
        
        return .question
    }
    
    var month: String {
        parsedDate.formatted(.dateTime.year().month(.wide))
    }
    
    init(date: String, institution: String, account: String, merchant: String, amount: Double, type: TransactionType.RawValue, categoryId: Int64, category: String, isPending: Bool, isTransfer: Bool, isExpense: Bool, isEdited: Bool) {
        self.id = UUID()
        self.date = date
        self.institution = institution
        self.account = account
        self.merchant = merchant
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.category = category
        self.isPending = isPending
        self.isTransfer = isTransfer
        self.isExpense = isExpense
        self.isEdited = isEdited
    }
    
    init(id: UUID, date: String, institution: String, account: String, merchant: String, amount: Double, type: TransactionType.RawValue, categoryId: Int64, category: String, isPending: Bool, isTransfer: Bool, isExpense: Bool, isEdited: Bool) {
        self.id = id
        self.date = date
        self.institution = institution
        self.account = account
        self.merchant = merchant
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.category = category
        self.isPending = isPending
        self.isTransfer = isTransfer
        self.isExpense = isExpense
        self.isEdited = isEdited
    }
    
    init(transactionMO: TransactionMO) {
        self.id = transactionMO.id!
        self.date = transactionMO.date!
        self.institution = transactionMO.institution!
        self.account = transactionMO.account!
        self.merchant = transactionMO.merchant!
        self.amount = transactionMO.amount
        self.type = transactionMO.type!
        self.categoryId = transactionMO.categoryId
        self.category = transactionMO.category!
        self.isPending = transactionMO.isPending
        self.isTransfer = transactionMO.isTransfer
        self.isExpense = transactionMO.isExpense
        self.isEdited = transactionMO.isEdited
    }
}
