import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    public var body: some View {
        ZStack {
            switch viewModel.state {
            case .disconnected:
                ConnectionView()
                    .transition(.opacity)
            case .connecting:
                ConnectingView()
                    .transition(.opacity)
            case .connected(let method):
                StreamView(method: method)
                    .transition(.opacity)
            case .failed(let error):
                ErrorView(error: error) {
                    viewModel.restart()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state.hashValue)
        .environmentObject(viewModel)
    }
}

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var state: ConnectionState = .disconnected

        init() {
            ConnectionManager.shared.delegate = self
        }

        func start() {
            ConnectionManager.shared.start()
        }

        func stop() {
            StreamManager.shared.stopStreaming()
            ConnectionManager.shared.stop()
        }

        func restart() {
            stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.start()
            }
        }
    }
}

extension ContentView.ViewModel: ConnectionManagerDelegate {
    func connectionStateDidChange(_ state: ConnectionState) {
        self.state = state
        if case .connected = state {
            StreamManager.shared.startStreaming()
        } else {
            StreamManager.shared.stopStreaming()
        }
    }

    func didReceivePacket(_ packet: Packet) {}
}
