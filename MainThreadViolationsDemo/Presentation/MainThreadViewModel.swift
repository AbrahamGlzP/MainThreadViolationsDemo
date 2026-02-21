//
//  MainThreadViewModel.swift
//  MainThreadViolationsDemo
//
//  Created by Abraham Gonzalez Puga on 20/02/26.
//

import SwiftUI

@Observable
@MainActor
class MainThreadViewModel {
    var log: [String] = []
    var isLoading = false
    var counter = 0
    
    // MARK: Simulated classic violation
    func triggerViolation() {
        isLoading = true
        log = []
        log.insert("🚀 Initiating background operation", at: 0)
        
        Task.detached { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            
            // We are in background - this is a violation
            // In a real project this would cause a warning in the Main Thread Checker
            // Here we simulate with a log
            
            await self?.logViolation("💀 Trying to update the UI from background")
            await self?.logViolation("⚠️ Main thread checker will detect it here")
            await self?.logViolation("🔴 In UIKit this would cause a crash or a render inconsistency")
            
            try? await Task.sleep(for: .seconds(1))
            await self?.setLoading(false)
        }
    }
    
    // MARK: Correct way with MainActor
    func runSafely() async {
        isLoading = true
        log = []
        log.insert("🚀 Initiating safe operation", at: 0)
        
        // Heavy work in background
        let result = await Task.detached(priority: .background) {
            // Simulate heavy work
            var sum = 0
            for _ in 0..<1_000_000 { sum += 1 }
            return sum
        }.value
        
        // When coming back from the await we still in @MainActor
        // Is safe to update the UI here
        log.insert("✅ Cómputo completado en background: \(result)", at: 0)
        log.insert("✅ UI actualizada desde @MainActor", at: 0)
        log.insert("🎉 Sin violations", at: 0)
        isLoading = false
    }
    
    // MARK: Useful on legacy SDKs callbacks
    func runWithLegacySDK() {
        isLoading = true
        log = []
        log.insert("🚀 Simulating legacy SDK callback", at: 0)
        
        // Simulates a background SDK callback
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let data = "SDK data"
            
            Task { @MainActor in
                self.log.insert("✅ Recieved callback: \(data)", at: 0)
                self.log.insert("✅ UI updated safely", at: 0)
                self.isLoading = false
                
            }
        }
        
    }
}

private extension MainThreadViewModel {
    // Helpers
    func logViolation(_ message: String) {
        log.insert(message, at: 0)
    }
    
    func setLoading(_ value: Bool) {
        isLoading = value
    }
}
