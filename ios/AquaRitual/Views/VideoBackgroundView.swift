import SwiftUI
import AVFoundation

struct VideoBackgroundView: UIViewRepresentable {
    var videoName: String
    var videoExtension: String
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName, videoExtension: videoExtension)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed for static loop
    }
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?   // 追加：保持

    deinit {
        queuePlayer?.pause()
        queuePlayer = nil
        playerLooper = nil
    }

    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)

        guard let fileUrl = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("Video file not found: \(videoName).\(videoExtension). Using fallback color.")
            self.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)
            return
        }

        let assetItem = AVPlayerItem(url: fileUrl)

        let qp = AVQueuePlayer()
        qp.isMuted = true
        playerLayer.player = qp
        playerLayer.videoGravity = .resizeAspectFill

        playerLooper = AVPlayerLooper(player: qp, templateItem: assetItem)
        layer.addSublayer(playerLayer)

        queuePlayer = qp
        qp.play()
    }
}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
