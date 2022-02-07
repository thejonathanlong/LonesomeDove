//
//  DrawingComponentsGridView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/6/22.
//

import SwiftUI

protocol DrawingDisplayable {
    var drawingImage: UIImage { get }
}

class DrawingComponentsGridViewModel: ObservableObject {
    var drawingDisplayables: [DrawingDisplayable]
    
    var gridItems: [GridItem] {
        drawingDisplayables.map { _ in
            GridItem(GridItem.Size.adaptive(minimum: 10, maximum: 100), spacing: 16, alignment: .center)
        }
    }
    
    init(drawingDisplayables: [DrawingDisplayable]) {
        self.drawingDisplayables = drawingDisplayables
    }
    
    
}

struct DrawingComponentsGridView: View {
    
    @ObservedObject var viewModel: DrawingComponentsGridViewModel
    
    var body: some View {
        LazyHGrid(rows: viewModel.gridItems, alignment: .center, spacing: 16) {
            ForEach(0..<viewModel.drawingDisplayables.count) { index in
                view(at: index)
            }
        }
    }
    
    func view(at index: Int) -> some View {
        Image(uiImage: viewModel.drawingDisplayables[index].drawingImage)
    }
}

struct Preview_DrawingDisplayable: DrawingDisplayable {
    var drawingImage: UIImage {
        return UIImage(named: <#T##String#>)
    }
    
}

struct DrawingComponentsGridView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingComponentsGridView(viewModel: DrawingComponentsGridViewModel(drawingDisplayables: [
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable(),
            Preview_DrawingDisplayable()
        ]))
    }
}
