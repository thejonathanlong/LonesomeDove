//
//  DrawingComponentsGridView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/6/22.
//

import SwiftUI

struct StickerGridView: View {
    
    @ObservedObject var viewModel: StickersGridViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows(), spacing: 16) {
                ForEach(0..<viewModel.stickers.count) { index in
                    view(at: index)
                        .cornerRadius(16)
                }
            }
        }
    }
    
    func view(at index: Int) -> some View {
        let drawing = viewModel.stickers[index]
        let drawingDisplayable = viewModel.stickerDisplayables[index]
        return Image(uiImage: drawing)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
                viewModel.didTap(stickerDisplayable: drawingDisplayable)
            }
    }
    
    func rows() -> [GridItem] {
        Array(repeating: GridItem(.fixed(150), spacing: 16, alignment: .center), count: 3)
    }
}

struct Preview_DrawingDisplayable: StickerDisplayable {
    var stickerData: Data {
        Data()
    }
    
    var stickerImage: UIImage? {
        return UIImage(named: "test_image")!
    }
    
}

struct DrawingComponentsGridView_Previews: PreviewProvider {
    static var previews: some View {
        StickerGridView(viewModel: StickersGridViewModel(stickerDisplayables: [
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable()
        ]))
    }
}
