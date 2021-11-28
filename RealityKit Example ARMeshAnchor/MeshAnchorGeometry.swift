//
//  MeshAnchorGeo.swift
//  MeshAnchorGeo
//
//  Created by Travis Hall on 24/11/2021.
//

import ARKit
import RealityKit
import Metal
import SwiftUI

struct generatedMesh {
    var vertices: [SIMD3<Float>] = []
    var triangles: [faceObj] = []
    var normals: [SIMD3<Float>] = []
}

struct faceObj {
    var classificationId: UInt32
    var triangles: [UInt32] = []
}

// The ARMeshAnchor contains polygonal geometry which we can use to create our own entity
func addMeshEntity(with anchor: ARMeshAnchor, to view: ARView, settings: EnvironmentObject<Settings>) {
    /// 1. Create two entities, an AnchorEntity using the ARMeshAnchors position
    /// And a ModelEntity used to store our extracted mesh
    let meshAnchorEntity = AnchorEntity(world: anchor.transform)
    let meshModelEntity = createMeshEntity(with: anchor, from: view, settings: settings)
    meshAnchorEntity.name = anchor.identifier.uuidString + "_anchor"
    meshModelEntity.name = anchor.identifier.uuidString + "_model"
    
    /// 2. Add to scene
    meshAnchorEntity.addChild(meshModelEntity)
    view.scene.addAnchor(meshAnchorEntity)
}

func createMeshEntity(with anchor: ARMeshAnchor, from arView: ARView, settings: EnvironmentObject<Settings>) -> ModelEntity {
    /// 1. Extract the the geometry from the ARMeshAnchor. Geometry is stored in a buffer-based array, format before using in MeshBuffers
    let anchorMesh = extractARMeshGeometry(with: anchor, in: arView)

    /// 2. Create a custom MeshDescriptor using the extracted mesh
    let mesh = createCustomMesh(name: "mesh", geometry: anchorMesh)
    
    /// 3. Create a new model entity for our mesh
    let generatedModel = ModelEntity(
        mesh: try! .generate(from: [mesh]),
        materials: generateMaterials(settings: settings)
    )
    return generatedModel
}

func removeMeshEntity(with anchor: ARMeshAnchor, from arView: ARView) {
    guard let meshAnchorEntity = arView.scene.findEntity(named: anchor.identifier.uuidString+"_anchor") else { return }
    arView.scene.removeAnchor(meshAnchorEntity as! AnchorEntity)
}

func updateMeshEntity(with anchor: ARMeshAnchor, in view: ARView, settings: EnvironmentObject<Settings> ) {
    /// 1.Find the previously added meshes
    guard let entity = view.scene.findEntity(named: anchor.identifier.uuidString+"_model") else { return }
    let modelEntity = entity as! ModelEntity

    /// 2. Extact new geometry
    let anchorMesh = extractARMeshGeometry(with: anchor, in: view)

    /// 3. Create a new MeshDescriptor using the extracted mesh
    let mesh = createCustomMesh(name: "mesh", geometry: anchorMesh)
    
    /// 4. Try to update the mesh with the new geometry
    do {
        modelEntity.model!.mesh = try .generate(from: [mesh])
        modelEntity.model!.materials = generateMaterials(settings: settings)
    } catch {
        print("Error updating mesh geometry")
    }
}

func extractARMeshGeometry(with anchor: ARMeshAnchor, in view: ARView) -> generatedMesh {
    var vertices: [SIMD3<Float>] = []
    var triangles: [faceObj] = []
    var normals: [SIMD3<Float>] = []

    /// Extract the vertices using the Extension from Apple (VisualizingSceneSemantics)
    for index in 0..<anchor.geometry.vertices.count {
        let vertex = anchor.geometry.vertex(at: UInt32(index))
        let vertexPos = SIMD3<Float>(x: vertex.0, y: vertex.1, z: vertex.2)
        vertices.append(vertexPos)
    }
    /// Extract the faces
    for index in 0..<anchor.geometry.faces.count {
        let face = anchor.geometry.vertexIndicesOf(faceWithIndex: Int(index))
        let meshClassification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index)
        triangles.append(faceObj(classificationId: UInt32(meshClassification.rawValue), triangles: [face[0],face[1],face[2]]))
    }
    /// Extract the normals. Normals uses an additional extension "normalsOf()"
    for index in 0..<anchor.geometry.normals.count {
        let normal = anchor.geometry.normalsOf(at: UInt32(index))
        normals.append(SIMD3<Float>(normal.0, normal.1, normal.2))
    }
    
    let extractedMesh = generatedMesh(vertices: vertices, triangles: triangles, normals: normals)
    return extractedMesh
}

func createCustomMesh(name: String, geometry: generatedMesh ) -> MeshDescriptor{
    /// Create a new MeshDescriptor using the generate geometry
    var mesh = MeshDescriptor(name: name)
    let faces = geometry.triangles.flatMap{ $0.triangles }
    let faceMaterials = geometry.triangles.compactMap{ $0.classificationId }
    let positions = MeshBuffers.Positions(geometry.vertices)
    let triangles = MeshDescriptor.Primitives.triangles(faces)
    let normals = MeshBuffers.Normals(geometry.normals)

    mesh.positions = positions
    mesh.primitives = triangles
    mesh.normals = normals
    
    /// Use the classificationIds to set the material on each face
    mesh.materials = MeshDescriptor.Materials.perFace(faceMaterials)
    
    return mesh
}

func generateMaterials(settings: EnvironmentObject<Settings>) -> [PhysicallyBasedMaterial] {
    /// This could be alot tidier
    /// We're creating materials for each classification with the colors in settings
    
    //case 0 .none
    var material0 = PhysicallyBasedMaterial()
    material0.baseColor = PhysicallyBasedMaterial.BaseColor(tint:UIColor( settings.wrappedValue.colorZero))
    material0.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorZero.cgColor?.alpha ?? 0.8)))
    
    //case 1 .wall
    var material1 = PhysicallyBasedMaterial()
    material1.baseColor = PhysicallyBasedMaterial.BaseColor(tint:UIColor( settings.wrappedValue.colorOne))
    material1.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorOne.cgColor?.alpha ?? 0.8)))
    
    //case 2 .floor
    var material2 = PhysicallyBasedMaterial()
    material2.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor( settings.wrappedValue.colorTwo))
    material2.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorTwo.cgColor?.alpha ?? 0.8)))
    
    //case 3  .ceiling
    var material3 = PhysicallyBasedMaterial()
    material3.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor( settings.wrappedValue.colorThree))
    material3.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorThree.cgColor?.alpha ?? 0.8)))
    
    //case 4  .table
    var material4 = PhysicallyBasedMaterial()
    material4.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor( settings.wrappedValue.colorFour))
    material4.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorFour.cgColor?.alpha ?? 0.8)))
    
    //case 5  .seat
    var material5 = PhysicallyBasedMaterial()
    material5.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor( settings.wrappedValue.colorFive))
    material5.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorFive.cgColor?.alpha ?? 0.8)))
    
    //case 6  .window
    var material6 = PhysicallyBasedMaterial()
    material6.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor( settings.wrappedValue.colorSix))
    material6.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorSix.cgColor?.alpha ?? 0.8)))
    
    //case 7  .door
    var material7 = PhysicallyBasedMaterial()
    material7.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor( settings.wrappedValue.colorSeven))
    material7.blending = .transparent(opacity: .init(floatLiteral: Float(settings.wrappedValue.colorSeven.cgColor?.alpha ?? 0.8)))
    
    return [material0, material1, material2, material3, material4, material5, material6, material7]
}
