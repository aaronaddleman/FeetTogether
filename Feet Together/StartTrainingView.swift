import SwiftUI
import AVFoundation
import Combine

import SwiftUI
import AVFoundation
import Combine

struct StartTrainingView: View {
    @State private var currentSectionIndex = 0
    @State private var currentItemIndex = 0
    @State private var isSessionComplete = false
    @State private var countdownSeconds = 0
    @State private var countdownActive = false
    @State private var cancellable: AnyCancellable? = nil

    @Binding var session: TrainingSession // Change this to a binding for updated section order

    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if isSessionComplete {
                Text("Session Complete!")
                    .font(.largeTitle)
                    .padding()
                Button("Restart Session") {
                    restartSession()
                }
                .padding()
            } else if let currentItem = getCurrentItem() {
                Text(currentItem.name)
                    .font(.largeTitle)
                    .padding()

                if countdownActive {
                    Text("Next in \(countdownSeconds) seconds")
                        .font(.title)
                        .padding()
                }

                Button("Skip to Next Item") {
                    moveToNextItem()
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

    // Start the session based on the user-defined order
    private func startSession() {
        currentSectionIndex = 0
        currentItemIndex = 0
        startCurrentItem()
    }

    // Get the current item from the active section
    private func getCurrentItem() -> AnyTrainingItem? {
        guard currentSectionIndex < session.sections.count else { return nil }
        let currentSection = session.sections[currentSectionIndex]
        guard currentItemIndex < currentSection.items.count else { return nil }
        return currentSection.items[currentItemIndex]
    }

    // Start the current item and begin the countdown
    private func startCurrentItem() {
        if let currentItem = getCurrentItem() {
            speakText(currentItem.name)
            countdownActive = true
            startCountdown(seconds: Int(session.timeBetweenTechniques))
        }
    }

    private func moveToNextItem() {
        guard currentSectionIndex < session.sections.count else { return }

        let currentSection = session.sections[currentSectionIndex]

        if currentItemIndex < currentSection.items.count - 1 {
            currentItemIndex += 1
            startCurrentItem()
        } else if currentSectionIndex < session.sections.count - 1 {
            currentItemIndex = 0
            currentSectionIndex += 1
            startCurrentItem()
        } else {
            isSessionComplete = true
            cancellable?.cancel()
            announceEndOfSession()
        }
    }

    // Restart the session
    private func restartSession() {
        isSessionComplete = false
        startSession()
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
                    self.moveToNextItem()
                }
            }
    }


    // Stop the training session and cancel the countdown
    private func endTrainingSession() {
        cancellable?.cancel()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // Announce the end of the session using text-to-speech
    private func announceEndOfSession() {
        let utterance = AVSpeechUtterance(string: "Congratulations! You have completed the training session.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    // Speak the current item's name using text-to-speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}
