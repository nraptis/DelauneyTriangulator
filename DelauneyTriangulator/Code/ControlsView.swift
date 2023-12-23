//
//  ControlsView.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import SwiftUI

struct ControlsView: View {
    @Environment(SceneViewModel.self) var sceneViewModel
    
    var body: some View {
        VStack {
            Text("Number: \(sceneViewModel.number)")
            Button(action: {
                sceneViewModel.number += 1
            }, label: {
                Text("Button")
            })
        }
        .frame(width: 800, height: 120)
        .background(Color.red)
    }
}

#Preview {
    ControlsView()
}
