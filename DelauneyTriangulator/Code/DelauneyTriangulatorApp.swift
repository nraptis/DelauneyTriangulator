//
//  DelauneyTriangulatorApp.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import SwiftUI

@main
struct DelauneyTriangulatorApp: App {
    
    @State var sceneViewModel = SceneViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environment(sceneViewModel)
        }
    }
}
