import SwiftUI
import AVFoundation

struct StartTrainingView: View {
    var session: TrainingSession  // This is immutable
    @State private var trainingItems: [AnyTrainingItem] = []  // Mutable copy of session's items
    @State private var currentItemIndex = 0
    @State private var isSessionComplete = false
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if isSessionComplete {
                Text("Session Complete!")
                    .font(.largeTitle)
                    .padding()
            } else if let currentItem = getCurrentItem() {
                Text(currentItem.name)
                    .font(.largeTitle)
                    .padding()

                Button("Next") {
                    moveToNextItem()
                }
                .padding()
            }
        }
        .onAppear {
            startSession()
        }
    }

    private func getCurrentItem() -> AnyTrainingItem? {
        guard currentItemIndex < trainingItems.count else { return nil }
        return trainingItems[currentItemIndex]
    }

    private func moveToNextItem() {
        if currentItemIndex < trainingItems.count - 1 {
            currentItemIndex += 1
            speakText(trainingItems[currentItemIndex].name)
        } else {
            isSessionComplete = true
        }
    }

    private func startSession() {
        trainingItems = session.sections.flatMap { $0.items }  // Flatten all items into one list
        if session.randomizeTechniques {
            trainingItems.shuffle()  // Now mutable
        }
        speakText(trainingItems[currentItemIndex].name)
    }

    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}

