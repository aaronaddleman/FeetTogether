import SwiftUI
import AVFoundation
import Combine

struct StartTrainingView: View {
    @State private var currentTechniqueIndex = 0
    @State private var isSessionComplete = false
    @State private var countdownSeconds = 0
    @State private var countdownActive = false
    @State private var cancellable: AnyCancellable? = nil
    @State private var shuffledTechniques: [Technique] = []

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
            } else if currentTechniqueIndex < shuffledTechniques.count {
                Text(shuffledTechniques[currentTechniqueIndex].name)
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
            startSession()
        }
        .onDisappear {
            endTrainingSession()
        }
    }

    // Start the session and shuffle techniques if randomization is enabled
    private func startSession() {
        if trainingSessions[0].randomizeTechniques {
            shuffledTechniques = trainingSessions[0].techniques.shuffled()
        } else {
            shuffledTechniques = trainingSessions[0].techniques
        }
        currentTechniqueIndex = 0
        startTechnique()
    }

    // Start the current technique and begin countdown
    private func startTechnique() {
        speakText(shuffledTechniques[currentTechniqueIndex].name)
        countdownActive = true
        startCountdown(seconds: trainingSessions[0].timeBetweenTechniques)
    }

    // Start the countdown using Combine's Timer publisher
    private func startCountdown(seconds: Int) {
        countdownSeconds = seconds
        cancellable?.cancel()
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
        if currentTechniqueIndex < shuffledTechniques.count - 1 {
            currentTechniqueIndex += 1
            startTechnique()
        } else {
            isSessionComplete = true
            cancellable?.cancel()
            announceEndOfSession() // Announce the end of the session
        }
    }

    // Announce the end of the session using text-to-speech
    private func announceEndOfSession() {
        let utterance = AVSpeechUtterance(string: "Congratulations! You have completed the training session.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    // Stop the countdown and speech synthesis when the view is dismissed
    private func endTrainingSession() {
        cancellable?.cancel()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // Speak text using text-to-speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}
