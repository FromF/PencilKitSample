//
//  ContentView.swift
//  PencilKitSample
//
//  Created by 藤治仁 on 2023/04/12.
//

import SwiftUI
import PencilKit
import Photos
import PhotosUI

struct ContentView: View {
    private let canvasView = PKCanvasView()
    private let pkToolPicker = PKToolPicker()
    private let imageView = UIImageView()
    
    @State private var isShowPKToolPicker = false
    @State private var photoPickerSelectedImage: PhotosPickerItem? = nil

    var body: some View {
        VStack {
            HStack(spacing: 16.0) {
                Button {
                    isShowPKToolPicker.toggle()
                } label: {
                    Image(systemName: isShowPKToolPicker ? "pencil.slash" : "pencil.and.scribble")
                }
                .onChange(of: isShowPKToolPicker) { isShowPKToolPicker in
                    // PKToolPickerの表示非表示を切り替える
                    pkToolPicker.setVisible(isShowPKToolPicker, forFirstResponder: canvasView)
                }
                
                Button {
                    // 背景画像を消す
                    imageView.image = nil
                    // PKCanvasViewの中身をクリアする
                    canvasView.drawing = PKDrawing()
                } label: {
                    Image(systemName: "trash")
                }

                Button {
                    // PKCanvasViewから画像に変換する
                    let image = canvasView.toUIImage()
                    // フォトライブラリーに画像を保存する
                    saveImageToCustomAlbum(image: image, albumName: "PencilKitSample")
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                
                PhotosPicker(selection: $photoPickerSelectedImage, matching: .images, preferredItemEncoding: .automatic, photoLibrary: .shared()) {
                    Image(systemName: "photo")
                }
            }
            
            PencilView(canvasView: canvasView, pkToolPicker: pkToolPicker)
                .border(Color.gray, width: 1)
                .frame(width: 200)
                .padding()
                
        }
        .onChange(of: photoPickerSelectedImage) { photosPickerItem in
            // 選択した写真があるとき
            if let photosPickerItem {
                // Data型で写真を取り出す
                photosPickerItem.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        // 写真があるとき
                        if let data {
                            DispatchQueue.main.async {
                                let image = UIImage(data: data)
                                imageView.clipsToBounds = true
                                imageView.contentMode = .scaleAspectFill
                                imageView.image = image
                                imageView.frame = canvasView.frame
                                canvasView.addSubview(imageView)
                                canvasView.sendSubviewToBack(imageView)
                                canvasView.isOpaque = false
                            }
                        }
                    case .failure:
                        return
                    }
                    // 選択された画像情報を消す
                    photoPickerSelectedImage = nil
                }
            }
        } // .onChange ここまで
    }
    

    func saveImageToCustomAlbum(image: UIImage, albumName: String) {
        // 写真のアクセス許可を確認
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges({
                    // アルバムを検索
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
                    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                    
                    let assetCreationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    
                    // アルバムを作成または取得して、写真を追加
                    if let assetCollection = collection.firstObject {
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                        let fastEnumeration = NSArray(array: [assetCreationRequest.placeholderForCreatedAsset!] as [PHObjectPlaceholder])
                        albumChangeRequest?.addAssets(fastEnumeration)
                    } else {
                        let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                        createAlbumRequest.addAssets(NSArray(object: assetCreationRequest.placeholderForCreatedAsset!) as NSFastEnumeration)
                    }
                    
                }, completionHandler: { (success, error) in
                    if success {
                        print("写真を保存しました。")
                    } else {
                        print("エラー: \(error?.localizedDescription ?? "Unknown error")")
                    }
                })
            case .denied, .restricted:
                print("アクセスが拒否されました。")
            case .notDetermined:
                // まだ決定されていない場合
                break
            @unknown default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
