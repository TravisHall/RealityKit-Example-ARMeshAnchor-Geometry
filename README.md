# RealityKit - Extracting anchor geometry to create a custom Mesh

An example project showing how to extract anchor geometry from ARMeshAnchor, create a new custom mesh and color per face in RealityKit.

## Description

This project uses the [ARMeshAnchor](https://developer.apple.com/documentation/arkit/armeshgeometry) geometry returned using the LIDAR scanner to generate a custom mesh using the new (From iOS 15 Beta) RealityKit [MeshBuffers](https://developer.apple.com/documentation/realitykit/meshbuffers) api. It uses the vertices, faces, normals and classificationIds to display a new mesh anchored at the same position. The faces are then coloured using the matching classificationIds. You can change the colors and blending mode for each classification in the example app. 

![Alt Text](https://github.com/TravisHall/RealityKit-Example-ARMeshAnchor-Geometry/blob/main/RealityKit%20Example%20ARMeshAnchor/Demo/demo.gif)
