//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-13.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Overview")
                        .font(.title)
                        .bold()
                    
                    RecentTransactionList()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.background)
            .toolbar {
                ToolbarItem {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.icon, .primary)
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
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
