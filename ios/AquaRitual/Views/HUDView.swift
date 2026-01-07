import SwiftUI

struct GlassOverlay: View {
    var body: some View {
        Color.black.opacity(0.1)
            .background(.ultraThinMaterial) // Glass effect
            .ignoresSafeArea()
            .allowsHitTesting(false) // Let touches pass through to gesture areas if needed
    }
}

struct HUDView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Clock
            Text(Date.now, format: .dateTime.hour().minute())
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            // Timer
            VStack {
                Text(timerManager.displayTime)
                    .font(.system(size: 60, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                HStack(spacing: 30) {
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pause()
                        } else {
                            timerManager.start()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    if !timerManager.isRunning && timerManager.elapsedTime > 0 {
                        Button(action: timerManager.stop) {
                            Image(systemName: "stop.circle")
                                .font(.system(size: 44))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.2))
                .background(.ultraThinMaterial)
        )
    }
}
