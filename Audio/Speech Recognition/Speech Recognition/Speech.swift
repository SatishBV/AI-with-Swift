//
//  Speech.swift
//  Speech Recognition
//
//  Created by Satish Bandaru on 15/08/21.
//

import Foundation
import AVFAudio
import Speech

class SpeechRecognizer {
    /// Used to perform audio input or output
    private let audioEngine: AVAudioEngine
    
    /// Helps specify the kind of audio
    private let session: AVAudioSession
    
    /// Initiates speech recognition task
    private let recognizer: SFSpeechRecognizer
    
    /// Both bus and nodes are to establish connections with the input hardware, i.e. microphones
    private let inputBus: AVAudioNodeBus
    private let inputNode: AVAudioInputNode
    
    /// Captures audio from a live buffer in order to recognize speech
    private var request: SFSpeechAudioBufferRecognitionRequest?
    
    /// Denotes the ongoing speech recognition task. Can be used for monitoring the current task.
    private var task: SFSpeechRecognitionTask?
    private var permissions: Bool = false
    
    init?(inputBus: AVAudioNodeBus = 0) {
        self.audioEngine = AVAudioEngine()
        self.session = AVAudioSession.sharedInstance()
        
        guard let recognizer = SFSpeechRecognizer() else { return nil }
        self.recognizer = recognizer
        self.inputBus = inputBus
        self.inputNode = audioEngine.inputNode
    }
    
    /// Checks permissions for microphone access
    func checkSessionPermission(_ session: AVAudioSession, completion: @escaping (Bool) -> Void) {
        if session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
            session.requestRecordPermission(completion)
        }
    }
    
    func startRecording(completion: @escaping (String?) -> Void) {
        audioEngine.prepare()
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        
        // microphone access permissions
        checkSessionPermission(session) { success in
            self.permissions = success
        }
        
        // Configure the sesion and start engine.
        guard let _ = try? session.setCategory(.record, mode: .measurement, options: .duckOthers),
              let _ = try? session.setActive(true, options: .notifyOthersOnDeactivation),
              let _ = try? audioEngine.start(),
              let request = self.request else {
            return completion(nil)
        }
        
        // Set the recording format and create necessary buffer
        let recordingFormat = inputNode.outputFormat(forBus: inputBus)
        inputNode.installTap(onBus: inputBus, bufferSize: 1024, format: recordingFormat) { buffer, audioTime in
            self.request?.append(buffer)
        }
        
        task = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                let transcript = result.bestTranscription.formattedString
                print("Heard: \(transcript)")
                completion(transcript)
            }
            
            /// If there is an error, or the recognition has ended after user paused
            if error != nil || result?.isFinal == true {
                self.stopRecording()
                completion(nil)
            }
        }
    }
    
    func stopRecording() {
        request?.endAudio()
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        request = nil
        task = nil
    }
}
