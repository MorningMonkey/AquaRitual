import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var completedDayKeys: [String] // "YYYY-MM-DD"
    let createdAt: Date
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.completedDayKeys = []
        self.createdAt = Date()
    }
    
    var isCompletedToday: Bool {
        completedDayKeys.contains(Habit.todayKey)
    }
    
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static var todayKey: String {
        dayFormatter.string(from: Date())
    }
}

class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let storageKey = "aqua_ritual_habits"
    
    init() {
        loadHubits()
    }

    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
        let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
        habits = decoded
        }
    }
    
    func addHabit(title: String) {
        let newHabit = Habit(title: title)
        habits.append(newHabit)
        saveHabits()
    }
    
    func toggleHabit(id: UUID) -> Bool {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return false }
        
        var habit = habits[index]
        let today = Habit.todayKey
        var completedNow = false
        
        if let keyIndex = habit.completedDayKeys.firstIndex(of: today) {
            habit.completedDayKeys.remove(at: keyIndex)
        } else {
            habit.completedDayKeys.append(today)
            completedNow = true
        }
        
        habits[index] = habit
        saveHabits()
        return completedNow
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveHabits()
    }
    
    // MARK: - Computed Properties for Rewards
    
    var dailyProgress: Double {
        guard !habits.isEmpty else { return 0.0 }
        let completedCount = habits.filter { $0.isCompletedToday }.count
        return Double(completedCount) / Double(habits.count)
    }
    
    /// Calculates streak: consecutively completed days (at least 1 habit completed per day).
    var streak: Int {
        // Gather all unique completed dates across all habits
        let allCompletedDatesString = Set(habits.flatMap { $0.completedDayKeys })
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        
        // Convert to Date objects for calculation
        let sortedDates = allCompletedDatesString
            .compactMap { formatter.date(from: $0) }
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        // Check from Today or Yesterday
        let today = Date()
        let calendar = Calendar.current
        
        var currentStreak = 0
        var checkDate = today
        
        // If today is completed, start from today.
        // If today is NOT completed, check if yesterday was completed to maintain streak.
        // If yesterday is also not completed, streak is 0 (or broken).
        
        let isTodayCompleted = allCompletedDatesString.contains(Habit.todayKey)
        if !isTodayCompleted {
            // Need to check if yesterday exists, otherwise streak is 0
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  allCompletedDatesString.contains(formatter.string(from: yesterday)) else {
                return 0
            }
            // Start checking from yesterday backwards
            checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        }
        
        // Loop backwards
        while true {
            let dateStr = formatter.string(from: checkDate)
            if allCompletedDatesString.contains(dateStr) {
                currentStreak += 1
                // Move 1 day back
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadHubits() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
}
