import AVFoundation
import Observation

/// Cihazın flaşını (torch) yönetir. Kamera izni gerektirmez.
@MainActor
@Observable
final class TorchController {
    private(set) var isOn = false
    let isAvailable: Bool

    @ObservationIgnored private let device: AVCaptureDevice?

    init() {
        #if targetEnvironment(simulator)
        // Simülatörde flaş yok; arayüzü test edebilmek için sanal flaş kullanılır.
        device = nil
        isAvailable = true
        #else
        let d = AVCaptureDevice.default(for: .video)
        device = (d?.hasTorch == true && d?.isTorchAvailable == true) ? d : nil
        isAvailable = device != nil
        #endif
    }

    /// Flaşı açar/kapatır. Başarılıysa true döner.
    @discardableResult
    func set(_ on: Bool) -> Bool {
        #if targetEnvironment(simulator)
        isOn = on
        return true
        #else
        guard let device else { return false }
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            isOn = on
            return true
        } catch {
            isOn = device.torchMode == .on
            return false
        }
        #endif
    }

    /// Uygulama öne geldiğinde gerçek flaş durumuyla arayüzü eşitler
    /// (ör. kullanıcı Kontrol Merkezi'nden kapattıysa).
    func syncWithHardware() {
        #if !targetEnvironment(simulator)
        if let device { isOn = device.torchMode == .on }
        #endif
    }
}
