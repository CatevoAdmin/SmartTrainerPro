import SwiftUI

struct HistoryView: View {
    @ObservedObject var workoutManager: WorkoutManager
    
    var body: some View {
        List(workoutManager.savedSessions) { session in
            VStack(alignment: .leading) {
                Text(session.startTime, style: .date)
                    .font(.headline)
                HStack {
                    Label("\(formatDuration(session.duration))", systemImage: "clock")
                    Spacer()
                    Label("\(session.averagePower) W", systemImage: "bolt.fill")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .navigationTitle("History")
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}
