import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    // We initialize WorkoutManager with the bluetoothManager instance
    @StateObject var workoutManager: WorkoutManager
    
    init() {
        let btManager = BluetoothManager()
        _bluetoothManager = StateObject(wrappedValue: btManager)
        _workoutManager = StateObject(wrappedValue: WorkoutManager(bluetoothManager: btManager))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Connection Status Header
                HStack {
                    Image(systemName: getStatusIcon())
                        .foregroundColor(getStatusColor())
                    Text(bluetoothManager.connectionStatus)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if workoutManager.isRecording {
                        Text(formatTime(workoutManager.elapsedTime))
                            .font(.monospacedDigit(.headline)())
                            .foregroundColor(.red)
                        Image(systemName: "circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    NavigationLink(destination: HistoryView(workoutManager: workoutManager)) {
                        Text("History")
                    }
                }
                .padding(.top)

                if bluetoothManager.connectedPeripheral == nil {
                    // Scanning UI
                    List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unknown Device")
                            Spacer()
                            Button("Connect") {
                                bluetoothManager.connect(to: peripheral)
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                    .refreshable {
                        if bluetoothManager.centralManager.state == .poweredOn {
                            bluetoothManager.startScanning()
                        }
                    }
                } else {
                    // Dashboard UI
                    ScrollView {
                        VStack(spacing: 30) {
                            // Metrics Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                MetricCard(title: "Power", value: "\(bluetoothManager.currentPower)", unit: "W", icon: "bolt.fill", color: .yellow)
                                MetricCard(title: "Cadence", value: "\(bluetoothManager.currentCadence)", unit: "RPM", icon: "arrow.clockwise", color: .green)
                                MetricCard(title: "Heart Rate", value: "\(bluetoothManager.currentHeartRate)", unit: "BPM", icon: "heart.fill", color: .red)
                            }
                            .padding()

                            // Low Cadence Alert
                            if bluetoothManager.currentCadence > 0 && bluetoothManager.currentCadence < 70 {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("Cadence Too Low!")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Spin Faster to Save Knees")
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .transition(.opacity)
                            }

                            // Manual Control
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Resistance Control")
                                        .font(.headline)
                                    Spacer()
                                    if !bluetoothManager.hasControl {
                                        Button("Request Control") {
                                            bluetoothManager.requestControl()
                                        }
                                        .font(.caption)
                                        .buttonStyle(.borderedProminent)
                                    } else {
                                        Text("Control Active")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(bluetoothManager.targetPower) },
                                    set: { bluetoothManager.setTargetPower(Int($0)) }
                                ), in: 0...Double(bluetoothManager.wattageCeiling), step: 5)
                                .disabled(!bluetoothManager.hasControl)
                                
                                HStack {
                                    Text("\(bluetoothManager.targetPower) W")
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                    Text("Ceiling: \(bluetoothManager.wattageCeiling) W")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                if bluetoothManager.connectedPeripheral == nil {
                    Button(action: {
                        if bluetoothManager.centralManager.state == .poweredOn {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        Text("Rescan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                } else {
                    // Start/Stop Workout Button
                    Button(action: {
                        if workoutManager.isRecording {
                            workoutManager.stopWorkout()
                        } else {
                            workoutManager.startWorkout()
                        }
                    }) {
                        Text(workoutManager.isRecording ? "Stop Workout" : "Start Workout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(workoutManager.isRecording ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                         bluetoothManager.disconnect()
                    }) {
                        Text("Disconnect")
                            .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Smart Trainer Pro")
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getStatusIcon() -> String {
        switch bluetoothManager.centralManager.state {
        case .poweredOn: return "bluetooth"
        case .poweredOff: return "bluetooth.disabled"
        default: return "exclamationmark.circle"
        }
    }
    
    func getStatusColor() -> Color {
        return bluetoothManager.centralManager.state == .poweredOn ? .blue : .gray
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text(value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
