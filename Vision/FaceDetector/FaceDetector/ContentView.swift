//
//  ContentView.swift
//  FaceDetector
//
//  Created by Satish Bandaru on 11/08/21.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var imagePickerOpen: Bool = false
    @State private var cameraOpen: Bool = false
    @State private var image: UIImage? = nil
    @State private var faces: [VNFaceObservation]? = nil
    
    private var faceCount: Int {
        return faces?.count ?? 0
    }
    
    private let placeHolderImage = UIImage(named: "placeHolder")!
    private var cameraEnabled: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    private var detectionEnabled: Bool {
        image != nil && faces == nil
    }
    
    var body: some View {
        if imagePickerOpen { return imagePickerView() }
        if cameraOpen { return cameraView() }
        return mainView()
    }
    
    private func getFaces() {
        self.faces = []
        self.image?.detectFaces { result in
            self.faces = result
            
            if let image = self.image,
               let annotatedImage = result?.drawOn(image) {
                self.image = annotatedImage
            }
        }
    }
    
    private func summonImagePicker() {
        imagePickerOpen = true
    }
    
    private func summonCamera() {
        cameraOpen = true
    }
    
    private func controlReturned(image: UIImage?) {
        self.image = image?.fixOrientation()
        self.faces = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    private func mainView() -> AnyView {
        return AnyView(NavigationView {
            MainView(image: image ?? placeHolderImage,
                     text: "\(faceCount) face\(faceCount == 1 ? "" : "s")") {
                TwoStateButton(text: "Detect Faces",
                               disabled: !detectionEnabled,
                               action: getFaces)
            }
            .padding()
            .navigationBarTitle(Text("FDDemo"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: summonImagePicker) {
                    Text("Select")
                },
                trailing: Button(action: summonCamera) {
                    Image(systemName: "camera")
                }.disabled(!cameraEnabled)
            )
        })
    }
    
    private func imagePickerView() -> AnyView {
        return AnyView(ImagePicker { result in
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        })
    }
    
    private func cameraView() -> AnyView {
        return AnyView(ImagePicker(camera: true) { result in
            self.controlReturned(image: result)
            self.cameraOpen = false
        })
    }
}
