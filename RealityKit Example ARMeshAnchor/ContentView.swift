//
//  ContentView.swift
//  RealityKit Example ARMeshAnchor
//
//  Created by Travis Hall on 24/11/2021.
//

import SwiftUI
import RealityKit
import ARKit

let delegate = SessionDelegate()

class Settings: ObservableObject {
    /// Set the initial colours used for each classification
    @Published var colorZero = Color.gray
    @Published var colorOne = Color.green
    @Published var colorTwo = Color.red
    @Published var colorThree = Color.cyan
    @Published var colorFour = Color.yellow
    @Published var colorFive = Color.purple
    @Published var colorSix = Color.blue
    @Published var colorSeven = Color.brown
    
    @Published var update = true
}

struct ContentView : View {
    @EnvironmentObject var settings: Settings
    @State private var present = true
    
    var body: some View {
        return (
            ZStack(alignment: .bottom) {
                ARViewContainer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .sheet(isPresented: $present) {
                    HalfSheet {
                        ColorPickerContainer()
                    }}
                HStack() {
                    Button {
                        present = true
                    } label: {
                        Text("Settings")
                    }.frame(height: 48, alignment: .center)
                        .buttonStyle(.borderedProminent)
                        .padding(.all, 24)
                        
                }.padding(.all, 16)
            }
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct ColorPickerContainer: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        return (
            VStack(alignment: .leading, spacing: 16){
                Toggle("Update Mesh", isOn: $settings.update)
                ColorPicker(".None", selection: $settings.colorZero)
                ColorPicker(".Wall", selection: $settings.colorOne)
                ColorPicker(".Floor", selection: $settings.colorTwo)
                ColorPicker(".Ceiling", selection: $settings.colorThree)
                ColorPicker(".Table", selection: $settings.colorFour)
                ColorPicker(".Seat", selection: $settings.colorFive)
                ColorPicker(".Window", selection: $settings.colorSix)
                ColorPicker(".Door", selection: $settings.colorSeven)
            }.padding(.all, 16)
        )
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var settings: Settings
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .meshWithClassification
        config.worldAlignment = .gravity
        
        delegate.set(arView: arView, settings: _settings)
        arView.session.delegate = delegate
        arView.debugOptions = []
        arView.session.run(config)
        
        // SetupAnchor
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.name = "Global"
        arView.scene.addAnchor(anchorEntity)
        arView.physicsOrigin = anchorEntity
        
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

final class SessionDelegate: NSObject, ARSessionDelegate {
    var arView: ARView!
    var settings: EnvironmentObject<Settings>!
    
    func set(arView: ARView, settings: EnvironmentObject<Settings>) {
        self.arView = arView
        self.settings = settings
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if settings.wrappedValue.update == true {
            for anchor in anchors {
                if anchor is ARMeshAnchor {
                    let meshAnchor = anchor as! ARMeshAnchor
                    addMeshEntity(with: meshAnchor, to: self.arView, settings: settings)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if settings.wrappedValue.update == true{
            for anchor in anchors {
                if anchor is ARMeshAnchor {
                    let meshAnchor = anchor as! ARMeshAnchor
                    updateMeshEntity(with: meshAnchor, in: self.arView, settings: settings)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        if settings.wrappedValue.update == true {
            for anchor in anchors {
                if anchor is ARMeshAnchor {
                    let meshAnchor = anchor as! ARMeshAnchor
                    removeMeshEntity(with: meshAnchor, from: self.arView)
                }
            }
        }
    }
}

class HalfSheetController<Content>: UIHostingController<Content> where Content : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let presentation = sheetPresentationController {
            // configure at will
            presentation.detents = [.medium()]
            presentation.prefersGrabberVisible = true
            presentation.prefersEdgeAttachedInCompactHeight = true
            presentation.prefersScrollingExpandsWhenScrolledToEdge = false
            presentation.largestUndimmedDetentIdentifier = .medium
        }
    }
}

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {
    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_: HalfSheetController<Content>, context: Context) {
        
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
