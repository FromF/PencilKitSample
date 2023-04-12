//
//  PencilView.swift
//  PencilKitSample
//
//  Created by 藤治仁 on 2023/04/12.
//

import SwiftUI
import PencilKit

struct PencilView: UIViewRepresentable {
    let canvasView: PKCanvasView
    let pkToolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 30)
        canvasView.drawingPolicy = .anyInput
        pkToolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // nop
    }
}
