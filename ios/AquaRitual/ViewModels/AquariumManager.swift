import Foundation
import SwiftUI

struct Fish: Identifiable, Codable {
    let id: UUID
    let seed: Int // For random visual variation (color/size)
    var lane: Double // 0.0 - 1.0 (Y Position relative to container)
    var speed: Double // Animation duration or point/sec
    var direction: Double // 1.0 (Right) or -1.0 (Left)
    
    init() {
        self.id = UUID()
        self.seed = Int.random(in: 0...1000)
        self.lane = Double.random(in: 0.1...0.8) // Avoid very top/bottom
        self.speed = Double.random(in: 15.0...30.0) // Slower is calmer
        self.direction = Bool.random() ? 1.0 : -1.0
    }
}

struct AquariumState: Codable {
    var fishes: [Fish]
    var dailyFishSpawns: Int
    var lastDayKey: String
    var decorSlots: [String] // Max 3
    var unlockedDecor: [String] // Use as Set internally
    
    static let initial = AquariumState(
        fishes: [Fish(), Fish(), Fish()], // Initial ambiance: 3 fish
        dailyFishSpawns: 0,
        lastDayKey: "",
        decorSlots: [],
        unlockedDecor: []
    )
}

class AquariumManager: ObservableObject {
    @Published var state: AquariumState
    @Published var fishSpawnTrigger: Int = 0 // Triggers bubble effect or spawn animation
    
    private let storageKey = "aqua_ritual_aquarium_state"
    private let maxDailySpawns = 2
    private let maxTotalFish = 12
    
    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(AquariumState.self, from: data) {
            self.state = decoded
        } else {
            self.state = .initial
        }
        
        checkDayReset()
    }
    
    func applyCompletionReward(dayKey: String, progress: Double, streak: Int) {
        checkDayReset() // Ensure correct day before applying logic
        
        // 1) Fish Reward (Immediate, max 2/day, max total 12)
        if state.dailyFishSpawns < maxDailySpawns && state.fishes.count < maxTotalFish {
            spawnFish()
            state.dailyFishSpawns += 1
            fishSpawnTrigger += 1 // Signal for bubble effect
        }
        
        // 2) Decor Unlocks (Streak based)
        // 7, 14, 30
        let milestones: [(day: Int, id: String)] = [
            (7, "rock_small"),
            (14, "driftwood"),
            (30, "shell")
        ]
        
        for m in milestones {
            if streak >= m.day && !state.unlockedDecor.contains(m.id) {
                unlockDecor(m.id)
            }
        }
        
        saveState()
    }
    
    private func spawnFish() {
        let newFish = Fish()
        state.fishes.append(newFish)
    }
    
    private func unlockDecor(_ id: String) {
        state.unlockedDecor.append(id)
        // Auto-equip if slot available
        if state.decorSlots.count < 3 {
            state.decorSlots.append(id)
        }
    }
    
    private func checkDayReset() {
        let today = Habit.todayKey
        if state.lastDayKey != today {
            state.lastDayKey = today
            state.dailyFishSpawns = 0
            saveState()
        }
    }
    
    private func saveState() {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
