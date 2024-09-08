import SwiftUI
import AVFoundation
import Combine

struct StartTrainingView: View {
    @State private var currentTechniqueIndex = 0
    @State private var isSessionComplete = false
    @State private var countdownSeconds = 0
    @State private var countdownActive = false
    @State private var cancellable: AnyCancellable? = nil

    private var sessionManager = iPhoneSessionManager()
    private var trainingSessions: [TrainingSession]
    private let speechSynthesizer = AVSpeechSynthesizer()

    init(trainingSessions: [TrainingSession]) {
        self.trainingSessions = trainingSessions
    }

    var body: some View {
        VStack {
            if isSessionComplete {
                Text("Session Complete!")
                    .font(.largeTitle)
                    .padding()
            } else if currentTechniqueIndex < trainingSessions[0].techniques.count {
                Text(trainingSessions[0].techniques[currentTechniqueIndex].name)
                    .font(.largeTitle)
                    .padding()

                if countdownActive {
                    Text("Next in \(countdownSeconds) seconds")
                        .font(.title)
                        .padding()
                }

                Button("Skip to Next Technique") {
                    moveToNextTechnique()
                }
                .padding()
            }
        }
        .onAppear {
            startTechnique() // Start the first technique
        }
        .onDisappear {
            endTrainingSession() // Stop the training session when the view is dismissed
        }
    }

    // Start the current technique and begin countdown if required
    private func startTechnique() {
        // Speak the name of the current technique
        speakText(trainingSessions[0].techniques[currentTechniqueIndex].name)
        
        // Start countdown for the next technique
        countdownActive = true
        startCountdown(seconds: trainingSessions[0].timeBetweenTechniques)
    }

    // Start the countdown using Combine's Timer publisher
    private func startCountdown(seconds: Int) {
        countdownSeconds = seconds
        cancellable?.cancel() // Cancel the previous countdown if any
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.countdownSeconds > 0 {
                    self.countdownSeconds -= 1
                } else {
                    self.cancellable?.cancel()
                    self.moveToNextTechnique()
                }
            }
    }

    // Move to the next technique and restart the countdown
    private func moveToNextTechnique() {
        if currentTechniqueIndex < trainingSessions[0].techniques.count - 1 {
            currentTechniqueIndex += 1
            startTechnique() // Restart the next technique and countdown
        } else {
            isSessionComplete = true
            cancellable?.cancel() // Cancel the countdown once the session is complete
        }
    }

    // Stop the countdown and speech synthesis when the view is dismissed
    private func endTrainingSession() {
        cancellable?.cancel() // Cancel the countdown
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate) // Stop any ongoing speech
        }
    }

    // Speak text using text-to-speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}
