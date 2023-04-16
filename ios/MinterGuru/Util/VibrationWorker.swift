//
//  VibrationWorker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 27.07.2022.
//

import Foundation
import CoreHaptics

class VibrationWorker {
    
    private var engine: CHHapticEngine? = nil
    private var isStopped = false
    
    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { reason in
                print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
                self.isStopped = true
            }
            startEngine()
        } catch {
            print("Create vibrate engine error: \(error.localizedDescription)")
        }
    }
    
    private func startEngine() {
        do {
            try engine?.start()
            isStopped = false
        } catch {
            print("Start vibrate engine error: \(error.localizedDescription)")
        }
    }
    
    func vibrate(intensity: Float = 1, sharpness: Float = 1) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        if isStopped {
            startEngine()
        }
        var events = [CHHapticEvent]()

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
    
}
