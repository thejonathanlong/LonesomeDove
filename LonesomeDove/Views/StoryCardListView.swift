//
//  StoryCardListView.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import SwiftUI
import SwiftUIFoundation

struct StoryCardListView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows(), alignment: .top) {
                AddCardView()
                    .frame(width: 422, height: 321)
                    .onTapGesture {
                        store.dispatch(.storyCard(.newStory))
                    }
                ForEach(store.state.storyListState.storyCardViewModels) { cardViewModel in
                    ZStack(alignment: .topLeading) {
                        StoryCard(viewModel: cardViewModel)
                            .onTapGesture {
                                onTap(of: cardViewModel)
                            }
                            .onLongPressGesture {
                                onLongPress()
                            }
                            .padding(8)
                        deleteButton
                    }
                }
            }
            .padding(32)
        }
    }

    var deleteButton: some View {
        Group {
            if store.state.storyListState.cardState == .deleteMode {
                Button(role: ButtonRole.destructive) {
                    // Delete here
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .buttonStyle(TransformedButtonStyle(pressedAngle: Angle(degrees: 90), pressedTransform: CGAffineTransform.identity, unPressedTransform: CGAffineTransform.identity))
            }
        }
    }

    func rows() -> [GridItem] {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return Array(repeating: GridItem(.fixed(325)), count: 2)
        default:
            return Array(repeating: GridItem(.fixed(325)), count: 1)
        }
    }

    func onTap(of cardViewModel: StoryCardViewModel) {
        switch store.state.storyListState.cardState {
            case .normal:
                store.dispatch(.storyCard(.readStory(cardViewModel)))

            case .deleteMode:
                break
        }
    }

    func onLongPress() {
        switch store.state.storyListState.cardState {
            case .normal:
                store.dispatch(.storyCard(.enterDeleteMode))

            case .deleteMode:
                store.dispatch(.storyCard(.exitDeleteMode))
        }
    }
}

struct AddViewModel: StoryCardDisplayable {
    var storyURL: URL = FileManager.documentsDirectory

    func toggleFavorite() {

    }

    var title: String {
        ""
    }

    var duration: String {
        ""
    }

    var numberOfPages: Int {
        0
    }

    var image: UIImage {
        UIImage(systemName: "plus.circle") ?? UIImage()
    }

    var isFavorite: Bool {
        false
    }

    var id = UUID()

}

 struct StoryCardListView_Previews: PreviewProvider {

     static var store: AppStore {
         let store = Store(initialState: AppState(), reducer: appReducer)
         store.dispatch(.storyCard(.updatedStoryList([StoryCardViewModel(title: "Blah", duration: 100, numberOfPages: 3, image: UIImage(named: "test_image"), storyURL: FileManager.default.temporaryDirectory)])))
         store.dispatch(.storyCard(.enterDeleteMode))

         return store
     }

    static var previews: some View {
        StoryCardListView()
            .environmentObject(StoryCardListView_Previews.store)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
 }
