//
//  ContentView.swift
//  Speech Recognition
//
//  Created by Satish Bandaru on 15/08/21.
//

import AVFAudio
import Speech
import SwiftUI

struct ContentView: View {
    @State var recording: Bool = false
    @State var speech: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if !speech.isEmpty {
                    Text(speech)
                        .font(.largeTitle)
                        .lineLimit(nil)
                } else {
                    Text("Speech will go here...")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                }
                
                Spacer()
                
                if recording {
                    Button(action: stopRecording) {
                        ButtonLabel("Stop Recording", background: .red)
                    }
                } else {
                    Button(action: startRecording) {
                        ButtonLabel("Start Recording", background: .blue)
                    }
                }
            }.padding()
            .navigationBarTitle(Text("Speech Recognition"), displayMode: .inline)
        }
    }
    
    private let recognizer: SpeechRecognizer
    
    init() {
        guard let recognizer = SpeechRecognizer() else {
            fatalError("Something went wrong...")
        }
        self.recognizer = recognizer
    }
    
    private func startRecording() {
        self.recording = true
        self.speech = ""
        
        recognizer.startRecording { result in
            if let text = result {
                self.speech = text
            } else {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        self.recording = false
        recognizer.stopRecording()
    }
}

struct ButtonLabel: View {
    private let title: String
    private let background: Color
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Spacer()
        }.padding().background(background).cornerRadius(10)
    }
    
    init(_ title: String, background: Color) {
        self.title = title
        self.background = background
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
