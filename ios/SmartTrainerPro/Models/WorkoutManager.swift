import Foundation
import Combine

struct WorkoutPoint: Codable {
    let timestamp: Date
    let power: Int
    let cadence: Int
    let heartRate: Int
}

struct WorkoutSession: Codable, Identifiable {
    var id: UUID = UUID()
    let startTime: Date
    var endTime: Date?
    var points: [WorkoutPoint]
    
    var duration: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }
    
    var averagePower: Int {
        guard !points.isEmpty else { return 0 }
        let total = points.reduce(0) { $0 + $1.power }
        return total / points.count
    }
}

class WorkoutManager: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentSession: WorkoutSession?
    @Published var savedSessions: [WorkoutSession] = []
    
    private var timer: Timer?
    private let bluetoothManager: BluetoothManager
    
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        loadSessions()
    }
    
    func startWorkout() {
        guard !isRecording else { return }
        
        isRecording = true
        elapsedTime = 0
        currentSession = WorkoutSession(startTime: Date(), points: [])
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordPoint()
        }
    }
    
    func stopWorkout() {
        guard isRecording, var session = currentSession else { return }
        
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        session.endTime = Date()
        currentSession = nil
        
        saveSession(session)
    }
    
    private func recordPoint() {
        guard isRecording else { return }
        
        elapsedTime += 1
        
        let point = WorkoutPoint(
            timestamp: Date(),
            power: bluetoothManager.currentPower,
            cadence: bluetoothManager.currentCadence,
            heartRate: bluetoothManager.currentHeartRate
        )
        
        currentSession?.points.append(point)
    }
    
    // MARK: - Persistence
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getHistoryFileURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("workout_history.json")
    }
    
    private func saveSession(_ session: WorkoutSession) {
        savedSessions.append(session)
        // Sort by newest first
        savedSessions.sort { $0.startTime > $1.startTime }
        
        do {
            let data = try JSONEncoder().encode(savedSessions)
            try data.write(to: getHistoryFileURL())
            print("Session saved. Total sessions: \(savedSessions.count)")
        } catch {
            print("Failed to save session: \(error)")
        }
    }
    
    private func loadSessions() {
        let url = getHistoryFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            savedSessions = try JSONDecoder().decode([WorkoutSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
        }
    }
}
