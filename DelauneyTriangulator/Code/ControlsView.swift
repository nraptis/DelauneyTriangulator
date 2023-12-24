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
        @Bindable var sceneViewModel = sceneViewModel
        HStack {
            Spacer()
            VStack {
                
                HStack {
                    VStack {
                        VStack {
                            VStack {
                                HStack {
                                    Text("# Hull Points:")
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 18.0))
                                        .foregroundColor(Color(red: 0.83,
                                                               green: 0.83,
                                                               blue: 0.83))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8.0)
                                .padding(.top, 6.0)
                                
                                TextField(text: $sceneViewModel.polygonPointCountString) {
                                    Text("")
                                }
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 22.0).bold())
                                .frame(width: 152.0)
                                .textFieldStyle(.roundedBorder)
                                .padding(.bottom, 8.0)
                            }
                            .frame(width: 174.0)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(style: .init(lineWidth: 2.0)).foregroundStyle(Color(red: 0.64, green: 0.64, blue: 0.64)))
                            
                            Button(action: {
                                let count = Int(sceneViewModel.polygonPointCountString) ?? 32
                                sceneViewModel.generateRandomPolygon(width: sceneViewModel.width,
                                                                     height: sceneViewModel.height,
                                                                     count: count)
                            }, label: {
                                ZStack {
                                    Text("Random Polygon")
                                        .font(.system(size: 18.0))
                                }
                                .frame(width: 152.0)
                            })
                            .buttonStyle(.borderedProminent)
                            
                            Button(action: {
                                sceneViewModel.polygon.removeAll(keepingCapacity: true)
                            }, label: {
                                ZStack {
                                    Text("Delete Polygon")
                                        .font(.system(size: 18.0))
                                    
                                }
                                .frame(width: 152.0)
                            })
                            .buttonStyle(.borderedProminent)
                            
                        }
                        .padding(.all, 12.0)
                    }
                    .background(RoundedRectangle(cornerRadius: 12.0).foregroundStyle(Color(red: 0.125,
                                                                                           green: 0.125,
                                                                                           blue: 0.125)))
                    
                    
                    VStack {
                        VStack {
                            VStack {
                                HStack {
                                    Text("# Free Points:")
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 18.0))
                                        .foregroundColor(Color(red: 0.83,
                                                               green: 0.83,
                                                               blue: 0.83))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8.0)
                                .padding(.top, 6.0)
                                
                                TextField(text: $sceneViewModel.innerPointCountString) {
                                    Text("")
                                }
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 22.0).bold())
                                .frame(width: 152.0)
                                .textFieldStyle(.roundedBorder)
                                .padding(.bottom, 8.0)
                            }
                            .frame(width: 174.0)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(style: .init(lineWidth: 2.0)).foregroundStyle(Color(red: 0.64, green: 0.64, blue: 0.64)))
                            
                            Button(action: {
                                let count = Int(sceneViewModel.innerPointCountString) ?? 32
                                sceneViewModel.generateRandomPoints(width: sceneViewModel.width,
                                                                    height: sceneViewModel.height,
                                                                    count: count)
                            }, label: {
                                ZStack {
                                    Text("Random Points")
                                        .font(.system(size: 18.0))
                                        .padding(.vertical, 2.0)
                                    
                                }
                                .frame(width: 152.0)
                            })
                            .buttonStyle(.borderedProminent)
                            
                            Button(action: {
                                sceneViewModel.innerPoints.removeAll(keepingCapacity: true)
                            }, label: {
                                ZStack {
                                    Text("Delete All Points")
                                        .font(.system(size: 18.0))
                                        .padding(.vertical, 2.0)
                                    
                                }
                                .frame(width: 152.0)
                            })
                            .buttonStyle(.borderedProminent)
                            
                        }
                        .padding(.all, 12.0)
                    }
                    .background(RoundedRectangle(cornerRadius: 12.0).foregroundStyle(Color(red: 0.125,
                                                                                           green: 0.125,
                                                                                           blue: 0.125)))
                    
                }
                
                HStack {
                    Picker("", selection: $sceneViewModel.triangulationMode) {
                        
                        ForEach(SceneViewModel.TriangulationMode.allCases) { triangulationMode in
                            Text(triangulationMode.description).tag(triangulationMode)
                        }
                        
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 6.0)
            }
            .frame(width: 420.0, height: 258.0)
            Spacer()
        }
        .background(Color(red: 0.22, green: 0.22, blue: 0.22))
    }
}

#Preview {
    ControlsView()
}
