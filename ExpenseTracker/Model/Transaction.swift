//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-14.
//

import Foundation

enum TransactionType : String {
    case credit = "credit"
    case debit = "debit"
}

struct Transaction : Identifiable, Hashable {
    let id : UUID = UUID()
    let date :  String
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
}
