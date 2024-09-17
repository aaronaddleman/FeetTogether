import SwiftUI
import CoreData
import AVFoundation
import Combine

struct StartTrainingView: View {
    var sessionEntity: TrainingSessionEntity  // Accept the Core Data entity
    @State private var session: TrainingSession? = nil  // The Swift model for session
    @State private var currentSectionIndex = 0
    @State private var currentItemIndex = 0
    @State private var isSessionComplete = false
    @State private var countdownSeconds = 0
    @State private var countdownActive = false
    @State private var isSessionStarted = false
    @State private var cancellable: AnyCancellable? = nil
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if let session = session {  // Only proceed if session is loaded
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
            } else {
                Text("Loading session...")
                    .font(.title)
                    .padding()
            }
        }
        .onAppear {
            guard !isSessionStarted else { return }
            isSessionStarted = true
            loadSessionFromCoreData()  // Load the session data from Core Data
        }
        .onDisappear {
            endTrainingSession()
        }
    }

    // Load session data from Core Data and convert it to the Swift model
    private func loadSessionFromCoreData() {
        // Convert Core Data sessionEntity to Swift TrainingSession model
        var sections: [TrainingSection] = []
        if let coreDataSections = sessionEntity.sections as? Set<TrainingSectionEntity> {
            for sectionEntity in coreDataSections {
                let items = (sectionEntity.items as? Set<TrainingItemEntity>)?.map { itemEntity in
                    AnyTrainingItem(id: itemEntity.id ?? UUID(), name: itemEntity.name ?? "Unnamed Item", category: itemEntity.category ?? "")
                } ?? []
                let section = TrainingSection(type: SectionType(rawValue: sectionEntity.type ?? "unknown") ?? .technique, items: items)
                sections.append(section)
            }
        }

        // Initialize the Swift model with the loaded data
        session = TrainingSession(
            id: sessionEntity.id ?? UUID(),
            name: sessionEntity.name ?? "Unnamed Session",
            timeBetweenTechniques: Int(sessionEntity.timeBetweenTechniques),
            isFeetTogetherEnabled: sessionEntity.isFeetTogetherEnabled,
            randomizeTechniques: sessionEntity.randomizeTechniques,
            sections: sections
        )
    }

    // Get the current item to display
    private func getCurrentItem() -> AnyTrainingItem? {
        guard let session = session, currentSectionIndex < session.sections.count else { return nil }
        let currentSection = session.sections[currentSectionIndex]
        guard currentItemIndex < currentSection.items.count else { return nil }
        return currentSection.items[currentItemIndex]
    }

    // Start the countdown and move to the next item
    private func startCurrentItem() {
        if let currentItem = getCurrentItem() {
            speakText(currentItem.name)
            countdownActive = true
            startCountdown(seconds: session?.timeBetweenTechniques ?? 0)
        }
    }

    // Start countdown using Combine's Timer publisher
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

    // Move to the next item in the session
    private func moveToNextItem() {
        cancellable?.cancel()
        
        if let session = session {
            if currentItemIndex < session.sections[currentSectionIndex].items.count - 1 {
                currentItemIndex += 1
            } else if currentSectionIndex < session.sections.count - 1 {
                currentItemIndex = 0
                currentSectionIndex += 1
            } else {
                isSessionComplete = true
                announceEndOfSession()
            }
        }

        startCurrentItem()
    }

    // Restart the session
    private func restartSession() {
        isSessionComplete = false
        isSessionStarted = false
        currentSectionIndex = 0
        currentItemIndex = 0
        startCurrentItem()
    }

    // End the session and stop any active countdown
    private func endTrainingSession() {
        cancellable?.cancel()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // Announce the current item using text-to-speech
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
