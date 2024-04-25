//
//  Storage.swift
//  BarcodeTextScanner
//
//  Created by trinh.ngoc.nam on 4/25/24.
//

import Foundation
import Combine

class DataStore: ObservableObject {
  static var shared = DataStore()

  @Published var collectedItems: [StoredItem] = []
  @Published var allTransientItems: [TransientItem] = []

  func keepItem(_ newitem: StoredItem) {
    let index = collectedItems.firstIndex { item in
      item.id == newitem.id
    }

    guard index == nil else {
      return
    }

    collectedItems.append(newitem)
  }
    
    func fetchItems() {
        collectedItems = DataStore.savedCollections
    }

  func deleteItem(_ newitem: StoredItem) {
    guard let index = collectedItems.firstIndex(where: { item in
      item.id == newitem.id
    }) else {
      return
    }
    collectedItems.remove(at: index)
  }

  func addThings(_ newItems: [TransientItem], allItems: [TransientItem]) {
    allTransientItems = allItems
  }

  func updateThings(_ changedItems: [TransientItem], allItems: [TransientItem]) {
    allTransientItems = allItems
  }

  func removeThings(_ removedItems: [TransientItem], allItems: [TransientItem]) {
    allTransientItems = allItems
  }
}

extension DataStore {
  @Storage(key: "CollectedItems", defaultValue: [])
  static var savedCollections: [StoredItem]
  
  func saveKeptItems() {
    DataStore.savedCollections = collectedItems
  }

  func restoreKeptItems() {
    DataStore.savedCollections = []
  }
}

@propertyWrapper
struct Storage<T: Codable> {
    struct Wrapper<U>: Codable where U: Codable {
        let wrapped: U
    }
    
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data
            else { return defaultValue }
            let value = try? JSONDecoder().decode(Wrapper<T>.self, from: data)
            return value?.wrapped ?? defaultValue
        }
        set {
            do {
                let data = try JSONEncoder().encode(Wrapper(wrapped: newValue))
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                print(error)
            }
        }
    }
}
