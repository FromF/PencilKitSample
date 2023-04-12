//
//  ContentView.swift
//  PencilKitSample
//
//  Created by 藤治仁 on 2023/04/12.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    private let canvasView = PKCanvasView()
    private let pkToolPicker = PKToolPicker()
    @State private var isShowPKToolPicker = false

    var body: some View {
        VStack {
            HStack {
                Button {
                    isShowPKToolPicker.toggle()
                } label: {
                    Text(isShowPKToolPicker ? "Hide" : "Show")
                }
                .padding(.horizontal)
                .onChange(of: isShowPKToolPicker) { isShowPKToolPicker in
                    // PKToolPickerの表示非表示を切り替える
                    pkToolPicker.setVisible(isShowPKToolPicker, forFirstResponder: canvasView)
                }
                
                Button {
                    // PKCanvasViewの中身をクリアする
                    canvasView.drawing = PKDrawing()
                } label: {
                    Text("Clear")
                }
                .padding(.horizontal)

                Button {
                    // PKCanvasViewから画像に変換する
                    let image = canvasView.drawing.image(from: canvasView.frame, scale: 1.0)
                    // フォトライブラリーに画像を保存する
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    Text("Save")
                }
                .padding(.horizontal)
            }
            
            PencilView(canvasView: canvasView, pkToolPicker: pkToolPicker)
                .border(Color.gray, width: 1)
                .frame(width: 200)
                .padding()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
