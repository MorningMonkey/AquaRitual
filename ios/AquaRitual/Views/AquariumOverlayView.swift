import SwiftUI

struct AquariumOverlayView: View {
    @ObservedObject var manager: AquariumManager
    var dailyProgress: Double // 0.0 - 1.0 from HabitManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1) Decor Layer (Bottom)
                DecorLayer(
                    slots: manager.state.decorSlots,
                    width: geometry.size.width,
                    height: geometry.size.height
                )

                // 2) Plants Layer (Bottom, growing)
                PlantsLayer(progress: dailyProgress, width: geometry.size.width)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 18)

                // 3) Fish Layer (Swimming)
                ForEach(manager.state.fishes) { fish in
                    FishView(
                        fish: fish,
                        containerWidth: geometry.size.width,
                        containerHeight: geometry.size.height
                    )
                }
            }
        }
    }
}

// MARK: - Decor

struct DecorLayer: View {
    let slots: [String]
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            ForEach(Array(slots.enumerated()), id: \.element) { index, decorID in
                DecorShape(id: decorID)
                    .fill(Color(white: 0.8, opacity: 0.8)) // Silhouette
                    .frame(width: 80, height: 60)
                    .position(
                        x: positionForIndex(index, width),
                        y: bottomY
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }

    private var bottomY: CGFloat {
        // Slightly above the very bottom so it does not feel clipped
        max(0, height - 46)
    }

    func positionForIndex(_ index: Int, _ w: CGFloat) -> CGFloat {
        switch index {
        case 0: return w * 0.2
        case 1: return w * 0.8
        case 2: return w * 0.5
        default: return w * 0.5
        }
    }
}

struct DecorShape: Shape {
    let id: String

    func path(in rect: CGRect) -> Path {
        var path = Path()

        switch id {
        case "rock_small": // Simple mound
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.width / 2, y: 0)
            )

        case "driftwood": // Branchy look
            path.move(to: CGPoint(x: rect.width * 0.2, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.4))
            path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.2))
            path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.5))
            path.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height))

        case "shell": // Fan shape
            path.addArc(
                center: CGPoint(x: rect.width / 2, y: rect.height),
                radius: rect.width / 2,
                startAngle: .degrees(180),
                endAngle: .degrees(360),
                clockwise: false
            )

        default:
            break
        }

        return path
    }
}

// MARK: - Plants

struct PlantsLayer: View {
    var progress: Double
    let width: CGFloat

    // 5 plants static positions
    let plantXs: [Double] = [0.1, 0.3, 0.5, 0.7, 0.9]

    var body: some View {
        GeometryReader { proxy in
            let areaH = proxy.size.height

            ZStack(alignment: .bottom) {
                ForEach(0..<plantXs.count, id: \.self) { i in
                    let base: CGFloat = 40
                    let growth: CGFloat = 110 * CGFloat(max(0, min(1, progress)))
                    let variance: CGFloat = CGFloat(i) * 8
                    let plantHeight = base + growth + variance

                    PlantShape(growth: progress)
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint.opacity(0.6)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 14, height: plantHeight, alignment: .bottom)
                        // Bottom anchored placement in local coordinate space
                        .position(
                            x: width * plantXs[i],
                            y: areaH - (plantHeight / 2)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct PlantShape: Shape {
    var growth: Double // 0 to 1

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Simple blade of grass
        path.move(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width * 1.5, y: rect.height / 2)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.width / 2, y: rect.height),
            control: CGPoint(x: 0, y: rect.height / 2)
        )
        return path
    }
}

// MARK: - Fish

struct FishView: View {
    let fish: Fish
    let containerWidth: CGFloat
    let containerHeight: CGFloat

    @State private var x: CGFloat = 0
    @State private var started = false

    var body: some View {
        let dir: CGFloat = fish.direction >= 0 ? 1 : -1
        let laneY = containerHeight * CGFloat(fish.lane)

        // Slight size variation for life-like feel (no external assets)
        let sizeW: CGFloat = 34 + CGFloat(abs(fish.seed % 12))
        let sizeH: CGFloat = max(16, sizeW * 0.5)

        FishShape(seed: fish.seed)
            .fill(fishColor(seed: fish.seed))
            .frame(width: sizeW, height: sizeH)
            .scaleEffect(x: dir, y: 1) // Flip visual to face travel direction
            .position(x: x, y: laneY)
            .onAppear {
                guard !started else { return }
                started = true

                let startX: CGFloat = (dir > 0) ? -80 : (containerWidth + 80)
                let endX: CGFloat   = (dir > 0) ? (containerWidth + 140) : -140

                x = startX
                withAnimation(.linear(duration: fish.speed).repeatForever(autoreverses: false)) {
                    x = endX
                }
            }
            .allowsHitTesting(false)
    }

    func fishColor(seed: Int) -> Color {
        let colors: [Color] = [.orange, .yellow, .cyan, .pink, .white]
        return colors[seed % colors.count]
    }
}

struct FishShape: Shape {
    let seed: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Oval body
        path.addEllipse(in: rect)

        // Tail (left side of body)
        let tailPath = Path { p in
            p.move(to: CGPoint(x: 0, y: rect.midY))
            p.addLine(to: CGPoint(x: -10, y: rect.minY))
            p.addLine(to: CGPoint(x: -10, y: rect.maxY))
            p.closeSubpath()
        }
        path.addPath(tailPath)

        return path
    }
}
