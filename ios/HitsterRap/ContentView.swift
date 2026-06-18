import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var spotify: SpotifyManager
    @State private var showPlayer = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // El escáner siempre está en el fondo; se pausa cuando showPlayer = true
            ScannerView(isActive: !showPlayer) { uri in
                spotify.play(uri: uri)
                showPlayer = true
            }

            if showPlayer {
                PlayerView {
                    spotify.pause()        // pausa sin desconectar
                    showPlayer = false     // vuelve al escáner
                }
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea()
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: showPlayer)
        .onChange(of: spotify.state) { state in
            switch state {
            case .error(let msg):
                errorMessage = msg
                showError = true
                showPlayer = false
            case .spotifyNotInstalled:
                errorMessage = "Spotify no está instalado en este dispositivo.\n\nInstala la app de Spotify (cuenta Premium necesaria) y vuelve a intentarlo."
                showError = true
                showPlayer = false
            default:
                break
            }
        }
        .alert("Error de Spotify", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}
