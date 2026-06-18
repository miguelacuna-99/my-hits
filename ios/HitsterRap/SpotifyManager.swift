import Foundation
import SpotifyiOS  // Requiere SpotifyiOS.xcframework (ver SETUP.md)

enum SpotifyState: Equatable {
    case disconnected
    case connecting
    case playing
    case paused
    case spotifyNotInstalled
    case error(String)
}

final class SpotifyManager: NSObject, ObservableObject {
    static let shared = SpotifyManager()

    // TODO: Pega aquí tu Client ID (ver SETUP.md → paso 1)
    private let clientID    = "YOUR_CLIENT_ID"
    // Debe coincidir exactamente con el Redirect URI del Spotify Dashboard
    private let redirectURI = URL(string: "hitsterrap://spotify-callback")!

    @Published private(set) var state: SpotifyState = .disconnected

    private lazy var appRemote: SPTAppRemote = {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        let remote = SPTAppRemote(configuration: config, logLevel: .none)
        remote.delegate = self
        return remote
    }()

    private override init() { super.init() }

    // MARK: - API pública

    /// Reproduce una pista. Si no hay conexión, abre Spotify para autorizar.
    func play(uri: String) {
        if appRemote.isConnected {
            appRemote.playerAPI?.play(uri, callback: { _, _ in })
        } else {
            setState(.connecting)
            appRemote.authorizeAndPlayURI(uri) { [weak self] spotifyInstalled in
                if !spotifyInstalled {
                    self?.setState(.spotifyNotInstalled)
                }
                // Si spotifyInstalled == true, Spotify se abrió para autorizar;
                // el flujo continúa en handleURL cuando el usuario vuelve a la app.
            }
        }
    }

    func togglePlayPause() {
        switch state {
        case .playing: appRemote.playerAPI?.pause({ _, _ in })
        case .paused:  appRemote.playerAPI?.resume({ _, _ in })
        default: break
        }
    }

    /// Pausa sin desconectar, para que la siguiente carta empiece más rápido.
    func pause() {
        appRemote.playerAPI?.pause({ _, _ in })
    }

    // MARK: - Ciclo de vida

    /// Llamado desde .onOpenURL cuando Spotify redirige de vuelta a la app.
    func handleURL(_ url: URL) {
        let params = appRemote.authorizationParameters(from: url)
        if let token = params?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
        } else if let desc = params?[SPTAppRemoteErrorDescriptionKey] as? String {
            setState(.error(desc))
        }
    }

    func appDidBecomeActive() {
        // Solo reconectar si ya tenemos un token de la sesión actual
        guard appRemote.connectionParameters.accessToken != nil else { return }
        appRemote.connect()
    }

    func appWillResignActive() {
        appRemote.disconnect()
    }

    // MARK: - Privado

    private func setState(_ newState: SpotifyState) {
        DispatchQueue.main.async { self.state = newState }
    }
}

// MARK: - SPTAppRemoteDelegate

extension SpotifyManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        setState(.playing)
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { _, _ in })
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        setState(.error(error?.localizedDescription ?? "No se pudo conectar con Spotify"))
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        setState(.disconnected)
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate

extension SpotifyManager: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        setState(playerState.isPaused ? .paused : .playing)
    }
}
