import SwiftUI

struct StreamView: View {
    let method: ConnectionMethod
    @EnvironmentObject var viewModel: ContentView.ViewModel
    @State private var showSettings = false
    @State private var fps: Double = 30
    @State private var quality: ConnectionQuality = .high

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Spacer()
            streamingIndicator
            Spacer()
            controlBar
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(quality: $quality, fps: $fps)
        }
        .onChange(of: quality) { newValue in
            StreamManager.shared.updateQuality(newValue)
        }
        .onChange(of: fps) { newValue in
            StreamManager.shared.setMaxFps(UInt8(newValue))
        }
    }

    private var headerBar: some View {
        HStack {
            Circle()
                .fill(.green)
                .frame(width: 10, height: 10)
            Text("Streaming via \(method.rawValue)")
                .font(.subheadline.weight(.medium))
            Spacer()
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gear")
                    .font(.title3)
            }
            Button(action: { viewModel.stop() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var streamingIndicator: some View {
        VStack(spacing: 16) {
            Image(systemName: "display")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .overlay(
                    Image(systemName: "arrow.up.forward")
                        .font(.caption)
                        .offset(x: 16, y: -16)
                )

            Text("Screen Mirroring Active")
                .font(.headline)

            HStack(spacing: 24) {
                Label("\(Int(fps)) fps", systemImage: "speedometer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(qualityLabel, systemImage: "photo.badge.arrow.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var controlBar: some View {
        HStack(spacing: 32) {
            Button(action: { /* disconnect */ }) {
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                    Text("Disconnect")
                        .font(.caption2)
                }
            }
            .foregroundStyle(.red)

            Button(action: { /* toggle cursor */ }) {
                VStack(spacing: 4) {
                    Image(systemName: "cursorarrow")
                        .font(.title2)
                    Text("Cursor")
                        .font(.caption2)
                }
            }
            .foregroundStyle(.blue)

            Button(action: { /* lock orientation */ }) {
                VStack(spacing: 4) {
                    Image(systemName: "lock.rotation")
                        .font(.title2)
                    Text("Orientation")
                        .font(.caption2)
                }
            }
            .foregroundStyle(.blue)
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }

    private var qualityLabel: String {
        switch quality {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .ultra: return "Ultra"
        }
    }
}
