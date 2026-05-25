import SwiftUI

@main
struct RemoteControlApp: App {
    @StateObject private var viewModel = ContentView.ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
                .onAppear {
                    configureAppearance()
                }
        }
    }

    private func configureAppearance() {
        UINavigationBar.appearance().prefersLargeTitles = false

        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.overrideUserInterfaceStyle = .dark
    }
}
