import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var viewModel: ContentView.ViewModel
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
                .symbolEffect(.pulse, options: .repeat(nil),
                             isActive: isAnimating)

            VStack(spacing: 8) {
                Text("Ready to Connect")
                    .font(.title2.bold())
                Text("Open the desktop app and select this device")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                MethodRow(icon: "cable.connector",
                         title: "USB",
                         detail: "Connect via cable for lowest latency")
                MethodRow(icon: "wifi",
                         title: "WiFi",
                         detail: "Same network connection")
                MethodRow(icon: "bluetooth",
                         title: "Bluetooth",
                         detail: "Wireless, higher latency")
            }
            .padding(.horizontal, 24)

            Button(action: { viewModel.start() }) {
                Label("Start Server", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Spacer()

            Text("Remote Control v1.0")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .onAppear { isAnimating = true }
    }
}

struct MethodRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ConnectingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Waiting for connection...")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Make sure the desktop app is running")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
    }
}

struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Connection Failed")
                .font(.title2.bold())
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: retry) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}
