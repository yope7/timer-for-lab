import SwiftUI
import AVFoundation

/// 円形タイマー表示を備えたメインビュー
struct ContentView: View {
    @State private var minutesInput = ""
    @State private var secondsInput = ""
    @State private var remainingSeconds: Int? = nil
    @State private var totalSeconds: Int = 0

    // 1 Hz でカウントダウン
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var player: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 16) {
            // 時間入力（分：秒）
            HStack {
                TextField("分", text: $minutesInput)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                Text("：")
                TextField("秒", text: $secondsInput)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
            }
            .font(.title2.monospacedDigit())

            // 円形プログレス
            ZStack {
                // 背景リング
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 12)

                // 残り時間リング（赤）
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.red.opacity(0.8),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90)) // 12 時開始

                // 残り時間のテキスト
                Text(remainingSecondsLabel)
                    .font(.title.monospacedDigit())
                    .bold()
            }
            .frame(width: 160, height: 160)

            // 開始／リセットボタン
            Button(action: startTimer) {
                Text(remainingSeconds == nil ? "開始" : "リセット")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(24)
        .onReceive(timer) { _ in tick() }
    }

    // MARK: - タイマー制御
    private func startTimer() {
        if remainingSeconds == nil {
            let total = (Int(minutesInput) ?? 0) * 60 + (Int(secondsInput) ?? 0)
            guard total > 0 else { return }
            totalSeconds = total
            remainingSeconds = total
        } else {
            remainingSeconds = nil
            totalSeconds = 0
        }
    }

    private func tick() {
        guard var sec = remainingSeconds else { return }
        sec -= 1
        if sec <= 0 {
            remainingSeconds = nil
            playSound()
        } else {
            remainingSeconds = sec
        }
    }

    // MARK: - サウンド再生
    private func playSound() {
        guard let path = Bundle.main.path(forResource: "beep", ofType: "mp3") else {
            NSSound.beep()
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            if player?.play() == true {
                return
            }
            NSSound.beep()
        } catch {
            NSSound.beep()
        }
    }

    // MARK: - 表示用プロパティ
    private var remainingSecondsLabel: String {
        guard let sec = remainingSeconds else { return "--:--" }
        return String(format: "%02d:%02d", sec / 60, sec % 60)
    }

    private var progress: Double {
        guard totalSeconds > 0, let remaining = remainingSeconds else { return 0 }
        return Double(remaining) / Double(totalSeconds)
    }
}
