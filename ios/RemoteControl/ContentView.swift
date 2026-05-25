import SwiftUI

struct ContentView: View {
    @StateObject private var server = ServerManager.shared
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
                .opacity(isPulsing ? 0.4 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            Text(statusText)
                .font(.title2.bold())
            if server.state == .listening {
                Text(server.localIP)
                    .font(.title3.monospaced())
                    .foregroundStyle(.green)
            }
            if server.state == .failed, !server.errorMessage.isEmpty {
                Text(server.errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            if server.state == .idle || server.state == .failed {
                Button(action: { server.start() }) {
                    Label("Start Server", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: { server.stop() }) {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            Spacer()
            Text("Remote Control v1.0")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .onAppear { isPulsing = true }
    }

    private var statusText: String {
        switch server.state {
        case .idle: return "Ready to Connect"
        case .listening: return "Waiting for connection..."
        case .connected: return "Connected"
        case .failed: return "Connection Failed"
        }
    }
}
