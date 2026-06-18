import SwiftUI
import VisionKit

// MARK: - Vista pública

struct ScannerView: View {
    /// false cuando el PlayerView está encima; pausa la cámara para ahorrar batería.
    var isActive: Bool
    var onScan: (String) -> Void

    var body: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerRepresentable(isActive: isActive, onScan: onScan)
                    .ignoresSafeArea()
            } else {
                CameraUnavailableView()
            }
        }
        .overlay(alignment: .bottom) {
            if isActive {
                Text("Apunta al QR de la carta")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 52)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - UIViewControllerRepresentable

private struct DataScannerRepresentable: UIViewControllerRepresentable {
    var isActive: Bool
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {
        if isActive && !vc.isScanning {
            context.coordinator.lastPayload = nil  // permite re-escanear la misma carta
            try? vc.startScanning()
        } else if !isActive && vc.isScanning {
            vc.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

    // MARK: Coordinator

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        var lastPayload: String?

        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            guard
                let item = addedItems.first,
                case .barcode(let barcode) = item,
                let payload = barcode.payloadStringValue,
                payload.hasPrefix("spotify:track:"),
                payload != lastPayload          // evita disparar dos veces la misma carta
            else { return }

            lastPayload = payload
            dataScanner.stopScanning()
            onScan(payload)
        }
    }
}

// MARK: - Fallback

private struct CameraUnavailableView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Cámara no disponible")
                .font(.title3.bold())
            Text("Requiere iPhone con iOS 16 o superior.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}
