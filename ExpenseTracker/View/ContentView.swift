//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-13.
//

import SwiftUI
import CoreData
import SwiftUICharts

struct ContentView: View {
    
    @EnvironmentObject var transactionListViewModel : TransactionListViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Overview")
                        .font(.title)
                        .bold()
                    
                    let data = transactionListViewModel.accumulateTransactions()
                    
                    if !data.isEmpty {
                        let totalExpenses = data.last?.1 ?? 0
                        CardView {
                            VStack(alignment: .leading) {
                                ChartLabel(totalExpenses.formatted(.currency(code: "CAD")), type: .title, format: "CA$%.02f")
                                
                                LineChart()
                            }
                            .background(Color.systemBackground)
                            
                        }
                        .data(data)
                        .chartStyle(ChartStyle(backgroundColor: Color.systemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                        .frame(height: 300)
                    }
                    
                    RecentTransactionList()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.background)
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.icon, .primary)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
        .onAppear {
            transactionListViewModel.getAllTransactions()
            
            //EDIT THIS
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
