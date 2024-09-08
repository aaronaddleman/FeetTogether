//
//  iPhoneSessionManager.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import WatchConnectivity
import AVFoundation
import Foundation

class iPhoneSessionManager: NSObject, WCSessionDelegate {
    var session: WCSession
    var speechSynthesizer = AVSpeechSynthesizer()
    var countdownActive = false
    var countdownTimer: Timer?
    var countdownSeconds = 3

    override init() {
        session = WCSession.default
        super.init()
        session.delegate = self
        
        // Activate WCSession to enable communication with the Apple Watch
        if WCSession.isSupported() {
            session.activate()
        }
    }

    // Handle the message from the watch when the "Weapon Sheath" gesture is detected
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let gestureDetected = message["weaponSheathGesture"] as? Bool, gestureDetected {
            if !countdownActive {
                startCountdown()
            }
        }
    }

    // Add required delegate method stubs to conform to WCSessionDelegate
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session inactive state
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
        session.activate()  // Reactivate the session after deactivation
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        // Handle changes in reachability
    }

    // This is the only valid declaration for this method
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error)")
        } else {
            print("WCSession activated successfully.")
        }
    }

    // Start the countdown with text-to-speech
    private func startCountdown() {
        countdownActive = true
        countdownSeconds = 3
        
        // Speak the message "Moving to next technique"
        speakText("Moving to next technique")
        
        // Start the countdown timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdownSeconds > 0 {
                self.speakText("\(self.countdownSeconds)")
                self.countdownSeconds -= 1
            } else {
                self.countdownTimer?.invalidate()
                self.moveToNextTechnique()
                self.countdownActive = false
            }
        }
    }

    // Stop the countdown if interrupted
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownActive = false
        speakText("Countdown stopped")
    }

    // Move to the next technique
    private func moveToNextTechnique() {
        speakText("Next technique")
        // Add logic to move to the next technique in your training session
    }

    // Speak text using text-to-speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}
