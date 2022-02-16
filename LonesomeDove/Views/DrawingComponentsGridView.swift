//
//  DrawingComponentsGridView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/6/22.
//

import SwiftUI

protocol DrawingDisplayable {
    var drawingImage: UIImage? { get }
}

class DrawingComponentsGridViewModel: ObservableObject {
    var drawingDisplayables: [DrawingDisplayable]
    
    var drawings: [UIImage] {
        drawingDisplayables.compactMap { $0.drawingImage }
    }
    
    init(drawingDisplayables: [DrawingDisplayable]) {
        self.drawingDisplayables = drawingDisplayables.filter { $0.drawingImage != nil }
    }
    
    func didTap(drawingDisplayable: DrawingDisplayable) {
        
    }
}

struct DrawingComponentsGridView: View {
    
    @ObservedObject var viewModel: DrawingComponentsGridViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows(), spacing: 16) {
                ForEach(0..<viewModel.drawings.count) { index in
                    view(at: index)
                        .cornerRadius(16)
                }
            }
        }
    }
    
    func view(at index: Int) -> some View {
        let drawing = viewModel.drawings[index]
        let drawingDisplayable = viewModel.drawingDisplayables[index]
        return Image(uiImage: drawing)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
                viewModel.didTap(drawingDisplayable: drawingDisplayable)
            }
    }
    
    func rows() -> [GridItem] {
        Array(repeating: GridItem(.fixed(150), spacing: 16, alignment: .center), count: 3)
    }
}

struct Preview_DrawingDisplayable: DrawingDisplayable {
    var drawingImage: UIImage? {
        return UIImage(named: "test_image")!
    }
    
}

struct DrawingComponentsGridView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingComponentsGridView(viewModel: DrawingComponentsGridViewModel(drawingDisplayables: [
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
