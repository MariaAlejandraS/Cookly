import SwiftUI
#if os(iOS)
import UIKit
#endif

enum ScannerAvailability: Equatable {
    case checking
    case ready
    case missingUsageDescription
    case denied
    case unavailable
}

enum CameraAccess {
    static func openSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}

#if os(iOS)
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    var isRunning: Bool
    var generation: UUID
    var onCodeDetected: (String) -> Void
    var onAvailability: (ScannerAvailability) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController()
    }

    func updateUIViewController(_ controller: ScannerViewController, context: Context) {
        controller.onCodeDetected = onCodeDetected
        controller.onAvailability = onAvailability
        if controller.generation != generation {
            controller.generation = generation
            controller.resetDetection()
        }
        controller.prepareIfNeeded()
        controller.setRunning(isRunning)
    }
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeDetected: ((String) -> Void)?
    var onAvailability: ((ScannerAvailability) -> Void)?
    var generation = UUID()

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cookly.barcode.session")
    private let feedback = UINotificationFeedbackGenerator()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didDetect = false
    private var didPrepare = false
    private var configured = false
    private var wantsRunning = false
    private var appliedRunning: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer
        feedback.prepare()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func resetDetection() {
        didDetect = false
    }

    func setRunning(_ running: Bool) {
        guard appliedRunning != running else { return }
        appliedRunning = running
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.wantsRunning = running
            if running {
                self.startOnQueue()
            } else if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func prepareIfNeeded() {
        guard !didPrepare else { return }
        didPrepare = true
        guard Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil else {
            DispatchQueue.main.async { self.onAvailability?(.missingUsageDescription) }
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.configure()
                } else {
                    DispatchQueue.main.async { self.onAvailability?(.denied) }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { self.onAvailability?(.denied) }
        @unknown default:
            DispatchQueue.main.async { self.onAvailability?(.denied) }
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !didDetect else { return }
        for object in metadataObjects {
            guard let code = object as? AVMetadataMachineReadableCodeObject,
                  let value = code.stringValue else { continue }
            let digits = value.filter(\.isNumber)
            guard digits == value, [8, 12, 13].contains(digits.count) else { continue }
            didDetect = true
            sessionQueue.async { [weak self] in
                guard let self, self.session.isRunning else { return }
                self.session.stopRunning()
            }
            feedback.notificationOccurred(.success)
            onCodeDetected?(digits)
            return
        }
    }

    deinit {
        let captureSession = session
        sessionQueue.async {
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }

    private func configure() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                DispatchQueue.main.async { self.onAvailability?(.unavailable) }
                return
            }
            self.session.beginConfiguration()
            if self.session.canSetSessionPreset(.high) {
                self.session.sessionPreset = .high
            }
            guard self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.onAvailability?(.unavailable) }
                return
            }
            self.session.addInput(input)
            let output = AVCaptureMetadataOutput()
            guard self.session.canAddOutput(output) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.onAvailability?(.unavailable) }
                return
            }
            self.session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            let wanted: [AVMetadataObject.ObjectType] = [.ean13, .ean8, .upce]
            let supported = wanted.filter { output.availableMetadataObjectTypes.contains($0) }
            if !supported.isEmpty {
                output.metadataObjectTypes = supported
            }
            self.session.commitConfiguration()
            self.configured = true
            DispatchQueue.main.async { self.onAvailability?(.ready) }
            if self.wantsRunning {
                self.startOnQueue()
            }
        }
    }

    private func startOnQueue() {
        guard configured, !session.isRunning else { return }
        session.startRunning()
    }
}
#else
struct BarcodeScannerView: View {
    var isRunning: Bool
    var generation: UUID
    var onCodeDetected: (String) -> Void
    var onAvailability: (ScannerAvailability) -> Void

    var body: some View {
        Color.clear
            .onAppear { onAvailability(.unavailable) }
    }
}
#endif
