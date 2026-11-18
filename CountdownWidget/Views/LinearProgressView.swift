//
//  LinearProgressView.swift
//  Countie
//
//  From: https://stackoverflow.com/a/79056508
//
import SwiftUI

struct LinearProgressView<Shape: SwiftUI.Shape>: View {
    var value: Double
    var shape: Shape
    
    var body: some View {
        GeometryReader { proxy in
            
            ZStack{
                
                
                shape.fill(.foreground.quaternary)
                    .overlay(alignment: .leading) {
                        GeometryReader { proxy in
                            
                            shape.fill(.tint)
                                .frame(width: proxy.size.width * value)
                            
                            
                        }
                    }
                    .clipShape(shape)
                
//                Text("\(Int(value * 100))%")
//                    .padding(2)
//                    .padding(.horizontal, 4)
//                    .foregroundStyle(.white)
//                    .background(
//                        RoundedRectangle(cornerRadius: 28)
//                            .fill(
//                                .tint
//                            )
//                            
//                                
//                    )
//                    .font(.system(size: 10))
//                    .position(x: proxy.size.width * value, y: proxy.size.height/2)
//                    .shadow(radius: 4)
                
                
                
            }
        }
    }
}
