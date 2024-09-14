import SwiftUI
import AVFoundation
import Combine

struct StartTrainingView: View {
    var session: TrainingSession  // This holds the session data
    @State private var trainingItems: [(sectionType: SectionType, item: AnyTrainingItem)] = []  // List of section-type and item pairs
    @State private var currentItemIndex = 0
    @State private var countdownSeconds = 0
    @State private var countdownActive = false
    @State private var isSessionComplete = false
    @State private var cancellable: AnyCancellable? = nil  // For managing the countdown timer
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if isSessionComplete {
                Text("Session Complete!")
                    .font(.largeTitle)
                    .padding()
            } else if let currentItem = getCurrentItem() {
                Text(currentItem.item.name)
                    .font(.largeTitle)
                    .padding()

                switch currentItem.sectionType {
                case .exercise:
                    Button("Move to Next Exercise") {
                        moveToNextItem()
                    }
                    .padding()
                    
                case .technique:
                    if countdownActive {
                        Text("Next in \(countdownSeconds) seconds")
                            .font(.title)
                            .padding()
                    }

                    Button("Skip to Next Technique") {
                        moveToNextItem()
                    }
                    .padding()
                    
                case .kata:
                    Button("Move to Next Kata") {
                        moveToNextItem()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            startSession()
        }
        .onDisappear {
            endSession()  // Clean up when the view is dismissed
        }
    }

    // Get the current training item from the list
    private func getCurrentItem() -> (sectionType: SectionType, item: AnyTrainingItem)? {
        guard currentItemIndex < trainingItems.count else { return nil }
        return trainingItems[currentItemIndex]
    }

    // Move to the next item in the training list
    private func moveToNextItem() {
        if currentItemIndex < trainingItems.count - 1 {
            currentItemIndex += 1
            startItem()  // Start the next item with countdown if needed
        } else {
            isSessionComplete = true
            cancellable?.cancel()
            announceEndOfSession()  // Announce the session is over
        }
    }

    // Start the current training item and handle section-specific behavior
    private func startItem() {
        if let currentItem = getCurrentItem() {
            speakText(currentItem.item.name)  // Announce the current technique/item
            
            switch currentItem.sectionType {
            case .technique:
                countdownActive = true
                startCountdown(seconds: Int(session.timeBetweenTechniques))  // Start the countdown
            default:
                countdownActive = false
            }
        }
    }

    // Start the countdown timer for techniques
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
                    self.moveToNextItem()  // Automatically move to the next item when the countdown is over
                }
            }
    }

    // Start the session and build the ordered list of training items from the sections
    private func startSession() {
        // Build the trainingItems array by adding items from each section in order
        trainingItems = session.sections.flatMap { section in
            section.items.map { (sectionType: section.type, item: $0) }
        }

        // Shuffle techniques if necessary
        if session.randomizeTechniques {
            trainingItems = trainingItems.shuffledBySection(of: .technique)
        }

        currentItemIndex = 0  // Start from the first item
        startItem()  // Begin the first technique/item
    }

    // Announce the end of the session
    private func announceEndOfSession() {
        let utterance = AVSpeechUtterance(string: "Congratulations! You have completed the training session.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    // Stop the countdown and speech synthesis when the view is dismissed
    private func endSession() {
        cancellable?.cancel()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // Speak the text using text-to-speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}

// Custom extension to shuffle only the techniques section
extension Array where Element == (sectionType: SectionType, item: AnyTrainingItem) {
    func shuffledBySection(of type: SectionType) -> [(sectionType: SectionType, item: AnyTrainingItem)] {
        let techniques = filter { $0.sectionType == type }.shuffled()
        let others = filter { $0.sectionType != type }
        return others + techniques
    }
}
