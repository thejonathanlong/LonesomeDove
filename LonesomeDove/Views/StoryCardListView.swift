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
    var viewModel: StoryCardListViewModel<StoryCardViewModel>

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows(), alignment: .top) {
                AddCardView()
                    .frame(width: 422, height: 321)
                    .onTapGesture {
                        viewModel.addNewStory()
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
                        // Padding here moves the delete button to the corner.
                        // Using an offset would mess with the button style rotation.
                            .padding(8)
                        if store.state.storyListState.cardState == .deleteMode {
                            Button(role: ButtonRole.destructive) {
                                viewModel.showDeletePrompt(for: cardViewModel)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(RotatedButtonStyle(pressedAngle: Angle(degrees: 90)))
                        }
                    }
                }
            }
            .animation(.easeInOut, value: store.state.storyListState)
            .padding(32)
            .background(Color.darkBackground)
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
                viewModel.readStory(cardViewModel)

            case .deleteMode:
                break
        }
    }

    func onLongPress() {
        switch store.state.storyListState.cardState {
            case .normal:
                viewModel.enterDeleteMode()

            case .deleteMode:
                viewModel.exitDeleteMode()
        }
    }
}

struct AddViewModel: StoryCardDisplayable {
    var storyURL: URL?

    var type: StoryType = .add

    func toggleFavorite() {

    }

    var title: String {
        ""
    }

    var timeStamp: String {
        ""
    }

    var duration: TimeInterval {
        100
    }

    var numberOfPages: Int {
        0
    }

    var posterImage: UIImage {
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
        StoryCardListView(viewModel: StoryCardListViewModel(store: nil))
            .environmentObject(StoryCardListView_Previews.store)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
 }
