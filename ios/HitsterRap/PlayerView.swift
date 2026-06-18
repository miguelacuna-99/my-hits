import SwiftUI

struct PlayerView: View {
    @EnvironmentObject private var spotify: SpotifyManager
    /// Callback del botón "Siguiente carta"
    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                Spacer()

                // Icono de estado
                statusIcon
                    .frame(height: 44)
                    .padding(.bottom, 16)

                // Texto de estado
                Text(statusText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(uiColor: .systemGray))
                    .animation(.easeInOut(duration: 0.2), value: spotify.state)
                    .padding(.bottom, 72)

                // Botón play / pausa
                Button {
                    spotify.togglePlayPause()
                } label: {
                    Image(systemName: playPauseIcon)
                        .font(.system(size: 84, weight: .ultraLight))
                        .foregroundStyle(.white)
                }
                .disabled(spotify.state == .connecting || spotify.state == .disconnected)

                Spacer()
                Spacer()

                // Botón siguiente carta
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text("Siguiente carta")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
            }
        }
    }

    // MARK: - Helpers

    private var playPauseIcon: String {
        switch spotify.state {
        case .playing:              return "pause.circle"
        case .paused:               return "play.circle"
        case .connecting,
             .disconnected:         return "ellipsis.circle"
        default:                    return "play.circle"
        }
    }

    private var statusText: String {
        switch spotify.state {
        case .playing:              return "Reproduciendo"
        case .paused:               return "En pausa"
        case .connecting,
             .disconnected:         return "Conectando con Spotify…"
        default:                    return ""
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        let spotifyGreen = Color(red: 29/255, green: 185/255, blue: 84/255)

        switch spotify.state {
        case .playing:
            Image(systemName: "music.note")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(spotifyGreen)
        case .paused:
            Image(systemName: "pause")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color(uiColor: .systemGray2))
        case .connecting, .disconnected:
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        default:
            Color.clear
        }
    }
}
