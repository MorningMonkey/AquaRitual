import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var habitManager = HabitManager()
    @StateObject private var aquariumManager = AquariumManager() // NEW

    @State private var showingHabits = false
    
    // Bubble effect trigger linked to aquariumManager
    var bubbleTrigger: Binding<Int> {
        $aquariumManager.fishSpawnTrigger
    }

    var body: some View {
        ZStack {
            // 1) Video background
            VideoBackgroundView(videoName: "aquarium_loop_1080p", videoExtension: "mp4")
                .ignoresSafeArea()

            // 2) Aquarium Rewards Overlay (Fish, Plants, Decor)
            AquariumOverlayView(manager: aquariumManager, dailyProgress: habitManager.dailyProgress)
                .ignoresSafeArea()
            
            // 3) Bubble effects (Triggered by Fish Spawn)
            BubbleEffectView(trigger: bubbleTrigger)
                .allowsHitTesting(false)

            // 4) Glass overlay
            GlassOverlay()
                .ignoresSafeArea()
        }
        // --- Top HUD ---
        .safeAreaInset(edge: .top) {
            HUDView(timerManager: timerManager)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
        }
        // --- Bottom Handle ---
        .safeAreaInset(edge: .bottom) {
            habitsHandle
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        // --- Habits Sheet ---
        .sheet(isPresented: $showingHabits) {
            HabitListView(
                habitManager: habitManager,
                onComplete: {
                    // Trigger Reward Logic
                    aquariumManager.applyCompletionReward(
                        dayKey: Habit.todayKey,
                        progress: habitManager.dailyProgress,
                        streak: habitManager.streak
                    )
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Bottom Handle UI

    private var habitsHandle: some View {
        Button {
            showingHabits = true
        } label: {
            VStack(spacing: 6) {
                Capsule()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 44, height: 6)

                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))

                    Text("Habits")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // 片手操作の最低タップ領域
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(radius: 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rounded corner helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
