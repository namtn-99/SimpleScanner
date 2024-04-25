//
//  Haptics.swift
//  BarcodeTextScanner
//
//  Created by trinh.ngoc.nam on 4/25/24.
//

import Foundation
import CoreHaptics
import UIKit

let hapticEngine: CHHapticEngine? = {
  do {
    let engine = try CHHapticEngine()
    engine.notifyWhenPlayersFinished { _ in
      return .stopEngine
    }
    return engine
  } catch {
    print("haptics are not working - because (error)")
    return nil
  }
}()

func hapticPattern() throws -> CHHapticPattern {
  let events = [
    CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [],
      relativeTime: 0,
      duration: 0.25
    ),
    CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [],
      relativeTime: 0.25,
      duration: 0.5
    )
  ]
  let pattern = try CHHapticPattern(events: events, parameters: [])
  return pattern
}

func playHapticClick() {
  guard let hapticEngine else {
    return
  }

  guard UIDevice.current.userInterfaceIdiom == .phone else {
    return
  }

  do {
    try hapticEngine.start()
    let pattern = try hapticPattern()
    let player = try hapticEngine.makePlayer(with: pattern)
    try player.start(atTime: 0)
  } catch {
    print("haptics are not working - because \(error)")
  }
}
