//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-18.
//

import Foundation
import CoreData
import UIKit
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String, Double)]

final class TransactionListViewModel : ObservableObject {
    
    //@Published var transactions: [Transaction] = []
    
//    func getTransactions() {
//        guard let url =
//    }
    
    @Published var transactionsMOList = [TransactionMO]()
    @Published var transactions = [Transaction]()
    
    private static var shared : TransactionListViewModel?
    
    static func getInstance() -> TransactionListViewModel {
        if shared != nil{
            return shared!
        }
        else{
            shared = TransactionListViewModel(context: PersistenceController.preview.container.viewContext)
            return shared!
        }
    }
    
    private let moc : NSManagedObjectContext
    private let ENTITY_NAME = "TransactionMO"
    
    init(context: NSManagedObjectContext){
        self.moc = context
    }
    
    func insertTransaction(transaction: Transaction){
        do {
            
            let transactionToInsert = NSEntityDescription.insertNewObject(forEntityName: ENTITY_NAME, into: self.moc) as! TransactionMO
            
            transactionToInsert.date = transaction.date
            transactionToInsert.institution = transaction.institution
            transactionToInsert.account = transaction.account
            transactionToInsert.merchant = transaction.merchant
            transactionToInsert.amount = transaction.amount
            transactionToInsert.type = transaction.type
            transactionToInsert.categoryId = transaction.categoryId
            transactionToInsert.category = transaction.category
            transactionToInsert.isPending = transaction.isPending
            transactionToInsert.isTransfer = transaction.isTransfer
            transactionToInsert.isExpense = transaction.isExpense
            transactionToInsert.isEdited = transaction.isEdited
            
            //may not need these to be saved
//            transactionToInsert.parsedDate = transaction.parsedDate
//            transactionToInsert.signedAmount = transaction.signedAmount
//            transactionToInsert.icon = transaction.icon.rawValue
//            transactionToInsert.month = transaction.month
            
            transactionToInsert.id = UUID()
            
            if self.moc.hasChanges{
                try self.moc.save()
                print(#function, "Data is saved successfully")
            }
            
        } catch let error as NSError{
            print(#function, "Could not save the data \(error)")
        }
    }
    
    func getAllTransactions() {
        let fetchRequest = NSFetchRequest<TransactionMO>(entityName: ENTITY_NAME)
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: true)]
        
        do {
            let result = try self.moc.fetch(fetchRequest)
            print(#function, "Number of records fetched : \(result.count)")
            self.transactionsMOList.removeAll()
            self.transactionsMOList.insert(contentsOf: result, at: 0)
            self.transactionsMOList = self.transactionsMOList.sorted(by: { $0.date!.parseDate() > $1.date!.parseDate() })
            
            self.transactions.removeAll()
            for transactionMO in transactionsMOList {
                self.transactions.append(Transaction(transactionMO: transactionMO))
            }
            
        } catch let error as NSError{
            print(#function, "Could not fetch data from Database \(error)")
        }
    }
    
    private func getTransaction(id : UUID) -> TransactionMO? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_NAME)
        let predicateId = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicateId
        
        do {
            let result = try self.moc.fetch(fetchRequest)
            
            if result.count > 0 {
                return result.first as? TransactionMO
            }
        } catch let error as NSError {
            print(#function, "Unable to search for data \(error)")
        }
        
        return nil
    }
    
    func deleteTransaction(id : UUID) {
        let searchResult = self.getTransaction(id: id)
        
        if (searchResult != nil) {
            do {
                self.moc.delete(searchResult!)
                
                try self.moc.save()
                objectWillChange.send()
                print(#function, "Data deleted successfully")
            } catch let error as NSError {
                print(#function, "Couldn't delete data \(error)")
            }
        }
        else {
            print(#function, "No matching record found")
        }
    }
    
    func updateTransaction(updatedTransaction: TransactionMO){
        let searchResult = self.getTransaction(id: updatedTransaction.id! as UUID)
        
        if (searchResult != nil) {
            do {
                let transactionToUpdate = searchResult!
                
                transactionToUpdate.date = updatedTransaction.date
                transactionToUpdate.institution = updatedTransaction.institution
                transactionToUpdate.account = updatedTransaction.account
                transactionToUpdate.merchant = updatedTransaction.merchant
                transactionToUpdate.amount = updatedTransaction.amount
                transactionToUpdate.type = updatedTransaction.type
                transactionToUpdate.categoryId = updatedTransaction.categoryId
                transactionToUpdate.category = updatedTransaction.category
                transactionToUpdate.isPending = updatedTransaction.isPending
                transactionToUpdate.isTransfer = updatedTransaction.isTransfer
                transactionToUpdate.isExpense = updatedTransaction.isExpense
                transactionToUpdate.isEdited = updatedTransaction.isEdited
//                transactionToUpdate.parsedDate = updatedTransaction.parsedDate
//                transactionToUpdate.signedAmount = updatedTransaction.signedAmount
                
                try self.moc.save()
                objectWillChange.send()
                print(#function, "Data Updated Successfully")
                
            } catch let error as NSError {
                print(#function, "Unable to update data \(error)")
            }
        }
        else {
            print(#function, "No matching data found")
        }
    }
    
    func groupTransactionByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }
        
        let groupedTransactions = TransactionGroup(grouping: transactions) { $0.month }
        
        return groupedTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        guard !transactions.isEmpty else { return [] }
        
        let today = Date.now
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        
        var sum: Double = .zero
        var cumulativeSum = TransactionPrefixSum()
        
        for date in stride(from: dateInterval.start, to: today, by: 60 * 60 * 24) {
            let dailyExpenses = transactions.filter({ $0.parsedDate == date && $0.isExpense })
            
            let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmount }
            
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            cumulativeSum.append((date.formatted(), sum))
        }
        
        print(cumulativeSum)
        return cumulativeSum
    }
}
