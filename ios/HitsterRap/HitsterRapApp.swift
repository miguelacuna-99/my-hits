import SwiftUI

@main
struct HitsterRapApp: App {
    @StateObject private var spotify = SpotifyManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotify)
                .onOpenURL { url in
                    // Spotify redirige aquí tras la autorización del usuario
                    spotify.handleURL(url)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:   spotify.appDidBecomeActive()
            case .inactive: spotify.appWillResignActive()
            default:        break
            }
        }
    }
}
