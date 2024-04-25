//
//  ListDataView.swift
//  BarcodeTextScanner
//
//  Created by trinh.ngoc.nam on 4/25/24.
//

import SwiftUI

struct ListDataView: View {
    @EnvironmentObject var datastore: DataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(datastore.collectedItems, id: \.id) { item in
                    VStack {
                        HStack {
                            Text(item.dateCreated.formatted())
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.leading, 42)
                            
                        HStack {
                            Label(
                                item.string ?? "",
                                systemImage: item.icon
                            )
                            Spacer()
                        }
                    }
                    .padding([.top, .bottom], 8)
                }
                .onDelete { indexset in
                    if let index = indexset.first {
                        let item = datastore.collectedItems[index]
                        datastore.deleteItem(item)
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button {
                        dismiss()
                    } label: {
                        Label("", systemImage: "xmark")
                    }, trailing:
                    HStack {
                        let str = datastore.collectedItems.map { $0.string ?? "" }.joined(separator: ", ")
                        ShareLink(item: str) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
            )
        }
       
        .onAppear {
            datastore.fetchItems()
            
        }
        .onDisappear {
            datastore.saveKeptItems()
        }
    }
    
}

struct ListDataView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel())
    }
}
