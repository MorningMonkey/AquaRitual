import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var displayTime: String = "00:00"
    @Published var isRunning: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    
    private var startTime: Date?
    private var timer: AnyCancellable?
    
    init() {
        // Restore state if needed (optional for MVP, sticking to simple logic first)
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTime = Date() - elapsedTime
        updateDisplay()
        
        timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let start = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
                self.updateDisplay()
            }
    }
    
    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func stop() {
        pause()
        elapsedTime = 0
        startTime = nil
        updateDisplay()
    }
    
    private func updateDisplay() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        displayTime = String(format: "%02d:%02d", minutes, seconds)
    }
}
