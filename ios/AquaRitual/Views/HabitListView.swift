import SwiftUI

struct HabitListView: View {
    @ObservedObject var habitManager: HabitManager
    var onComplete: () -> Void
    @State private var newHabitTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Add Form
                HStack {
                    TextField("新しい習慣...", text: $newHabitTitle)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: addHabit) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.cyan)
                    }
                    .disabled(newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                
                // List
                List {
                    ForEach(habitManager.habits) { habit in
                        HStack {
                            Text(habit.title)
                                .font(.body)
                                .strikethrough(habit.isCompletedToday)
                                .foregroundColor(habit.isCompletedToday ? .gray : .primary)
                            
                            Spacer()
                            
                            Button(action: {
                                if habitManager.toggleHabit(id: habit.id) {
                                    onComplete() // Trigger Bubble Effect
                                }
                            }) {
                                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(habit.isCompletedToday ? .cyan : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: habitManager.deleteHabit)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addHabit() {
        guard !newHabitTitle.isEmpty else { return }
        habitManager.addHabit(title: newHabitTitle)
        newHabitTitle = ""
    }
}
