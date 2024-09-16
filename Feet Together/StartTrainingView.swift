import SwiftUI
import AVFoundation
import Combine

struct StartTrainingView: View {
    @State private var currentSectionIndex = 0
    @State private var currentItemIndex = 0
    @State private var isSessionComplete = false
    @State private var countdownSeconds = 0
    @State private var countdownActive = false
    @State private var isSessionStarted = false // Flag to prevent redundant session initialization
    @State private var cancellable: AnyCancellable? = nil
    @State private var session: TrainingSession  // Use @State to allow modifications
    private let speechSynthesizer = AVSpeechSynthesizer()  // Add text-to-speech support

    init(session: TrainingSession) {
        self._session = State(initialValue: session)  // Initialize the session as a @State
    }

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
            } else {
                if let currentItem = getCurrentItem() {
                    Text(currentItem.name)
                        .font(.largeTitle)
                        .padding()

                    // Countdown timer UI
                    if countdownActive {
                        Text("Next in \(countdownSeconds) seconds")
                            .font(.title)
                            .padding()
                    }

                    Button("Next Item") {
                        moveToNextItem()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            guard !isSessionStarted else { return }  // Prevent redundant session start
            isSessionStarted = true
            startSession()
        }
        .onDisappear {
            endTrainingSession()  // Stop the timer if the view is dismissed
        }
    }

    // Start the session and begin the countdown for the first item
    private func startSession() {
        currentSectionIndex = 0
        currentItemIndex = 0
        isSessionComplete = false
        startCurrentItem()
    }

    // Get the current item to display and announce
    private func getCurrentItem() -> AnyTrainingItem? {
        guard currentSectionIndex < session.sections.count else { return nil }
        let currentSection = session.sections[currentSectionIndex]
        guard currentItemIndex < currentSection.items.count else { return nil }
        return currentSection.items[currentItemIndex]
    }

    // Start the current item, announce it, and start the countdown
    private func startCurrentItem() {
        if let currentItem = getCurrentItem() {
            speakText(currentItem.name)  // Announce the item via text-to-speech
            countdownActive = true  // Activate the countdown
            startCountdown(seconds: session.timeBetweenTechniques)  // Use the session's timeBetweenTechniques for the countdown
        }
    }

    // Start the countdown using Combine's Timer publisher
    private func startCountdown(seconds: Int) {
        countdownSeconds = seconds
        cancellable?.cancel()  // Cancel any previous countdown
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

    // Move to the next item in the session
    private func moveToNextItem() {
        cancellable?.cancel()  // Cancel the current countdown

        if currentItemIndex < session.sections[currentSectionIndex].items.count - 1 {
            currentItemIndex += 1
        } else if currentSectionIndex < session.sections.count - 1 {
            currentItemIndex = 0
            currentSectionIndex += 1
        } else {
            isSessionComplete = true
            announceEndOfSession()  // Announce the end of the session via text-to-speech
            return
        }

        startCurrentItem()  // Start the next item
    }

    // Restart the session
    private func restartSession() {
        isSessionComplete = false
        isSessionStarted = false // Reset session start flag
        startSession()
    }

    // End the session, stopping any active countdown and speech synthesis
    private func endTrainingSession() {
        cancellable?.cancel()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // Text-to-speech function to announce the current item
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    // Announce the end of the session
    private func announceEndOfSession() {
        let utterance = AVSpeechUtterance(string: "Congratulations! You have completed the training session.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}
