import SwiftUI

struct SettingsView: View {
    @Binding var quality: ConnectionQuality
    @Binding var fps: Double
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Stream Quality") {
                    Picker("Resolution", selection: $quality) {
                        Text("Low (25%)").tag(ConnectionQuality.low)
                        Text("Medium (40%)").tag(ConnectionQuality.medium)
                        Text("High (60%)").tag(ConnectionQuality.high)
                        Text("Ultra (80%)").tag(ConnectionQuality.ultra)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max FPS: \(Int(fps))")
                            .font(.subheadline)
                        Slider(value: $fps, in: 10...60, step: 5)
                    }
                }

                Section("Connection") {
                    LabeledContent("Protocol",
                                   value: "RemoteControl v1")
                    LabeledContent("Encryption",
                                   value: "None (LAN only)")
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
