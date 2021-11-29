# RealityKit - Extracting anchor geometry to create a custom Mesh

An example project showing how to extract anchor geometry from ARMeshAnchor, create a new custom mesh and color per face in RealityKit.

## Description
Last year, ARKit 3.5 introduced the ability to use the LIDAR sensor to understand more about the scene and surroudings. At the time you were limited by RealityKit's lack of procedural geometry, if you wanted to visualise the scene understanding with custom models you needed to use SceneKit. With ARKit 5, Apple has introduced a way to create procedural meshes, so we can now use the geometry to create custom model entities in RealityKit.

This project uses the [ARMeshAnchor](https://developer.apple.com/documentation/arkit/armeshgeometry) geometry returned using the LIDAR scanner with scene reconstruction to generate a custom mesh using the new (From iOS 15 Beta) RealityKit [MeshBuffers](https://developer.apple.com/documentation/realitykit/meshbuffers) api. It uses the **vertices**, **faces**, **normals** and **classificationIds** to display a new mesh anchored at the same position. The faces are then coloured using the matching classificationIds. You can change the colors and blending mode for each classification in the example app. 

Visualising the ARMeshAnchor geometry. 

![Alt Text](https://github.com/TravisHall/RealityKit-Example-ARMeshAnchor-Geometry/blob/main/RealityKit%20Example%20ARMeshAnchor/Demo/demo2.gif)

Changing colours of the classifications. 

![Alt Text](https://github.com/TravisHall/RealityKit-Example-ARMeshAnchor-Geometry/blob/main/RealityKit%20Example%20ARMeshAnchor/Demo/demo.gif)



## Further reading
**[Max Cobb - Getting Started with RealityKit: Procedural Geometries](https://maxxfrazer.medium.com/getting-started-with-realitykit-procedural-geometries-5dd9eca659ef)**.  

**[Visualizing and Interacting with a Reconstructed Scene](https://developer.apple.com/documentation/arkit/content_anchors/visualizing_and_interacting_with_a_reconstructed_scene)**

