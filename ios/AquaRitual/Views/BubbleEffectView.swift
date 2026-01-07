import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
}

struct BubbleEffectView: View {
    @Binding var trigger: Int
    @State private var bubbles: [Bubble] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(Color.white)
                        .frame(width: bubble.size, height: bubble.size)
                        .position(x: bubble.x, y: bubble.y)
                        .opacity(bubble.opacity)
                }
            }
            }
            .onChange(of: trigger) { _ in
                spawnBubbles(in: geometry.size)
            }
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                guard !bubbles.isEmpty else { return }
                updateBubbles()
            }
        }
    }
    
    private func spawnBubbles(in size: CGSize) {
        // Spawn a burst of bubbles
        let count = Int.random(in: 12...20)
        for _ in 0..<count {
            let bubble = Bubble(
                x: CGFloat.random(in: (size.width * 0.2)...(size.width * 0.8)), // Center focus
                y: size.height + 20,
                size: CGFloat.random(in: 4...10),
                speed: CGFloat.random(in: 3...7),
                opacity: Double.random(in: 0.6...1.0)
            )
            bubbles.append(bubble)
        }
    }
    
    private func updateBubbles() {
        // Update physics
        bubbles = bubbles.map { b in
            var nb = b
            nb.y -= nb.speed
            nb.opacity -= 0.02 // Fade out faster
            return nb
        }
        // Remove finished
        bubbles.removeAll { $0.y < -50 || $0.opacity <= 0 }
    }
}
