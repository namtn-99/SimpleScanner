//
//  DataScannerView.swift
//  BarcodeTextScanner
//
//

import Foundation
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        vc.overlayContainerView.frame = context.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]

        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
            DataStore.shared.keepItem(TransientItem(item: item).toStoredItem())
            playHapticClick()
        }
       
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
            DataStore.shared.addThings(
              addedItems.map { TransientItem(item: $0) },
              allItems: allItems.map { TransientItem(item: $0) }
            )
            for item in addedItems {
                DataStore.shared.keepItem(TransientItem(item: item).toStoredItem())
            }
            DataStore.shared.saveKeptItems()
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: {$0.id == item.id })
            }
            DataStore.shared.removeThings(
              removedItems.map { TransientItem(item: $0) },
              allItems: allItems.map { TransientItem(item: $0) }
            )
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            DataStore.shared.updateThings(
              updatedItems.map { TransientItem(item: $0) },
              allItems: allItems.map { TransientItem(item: $0) }
            )
        }
        
    }
    
}
