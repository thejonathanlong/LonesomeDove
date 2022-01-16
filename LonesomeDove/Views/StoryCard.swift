//
//  StoryCard.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

// MARK: - StoryCardDisplayable
protocol StoryCardDisplayable: Identifiable {
    var title: String { get }
    var duration: String { get }
    var numberOfPages: Int { get }
    var image: UIImage { get }
    var isFavorite: Bool { get }
    var storyURL: URL? { get }

    func toggleFavorite()

    var id: UUID { get }
}

// MARK: - StoryCard
struct StoryCard<ViewModel>: View where ViewModel: StoryCardDisplayable {

    let viewModel: ViewModel
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: viewModel.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minHeight: 150, maxHeight: 300)
                .cornerRadius(17)
            heading
        }
        .padding()
        .cornerRadius(25, corners: .allCorners, backgroundColor: Color.funColor(for: store.state.storyListState.storyCardViewModels.firstIndex(where: { $0.id == viewModel.id }) ?? 0))
        .shadow(color: Color.defaultShadowColor, radius: 3, x: 1, y: 1)
    }

    var heading: some View {
        VStack(alignment: .leading, spacing: 10) {
            title
            Divider()
            info
        }
    }

    var info: some View {
        HStack {
            Label(viewModel.duration, systemImage: "clock")
            Text("|")
            Label("\(viewModel.numberOfPages) pages", systemImage: "book")
            Spacer()
            Button {
                viewModel.toggleFavorite()
            } label: {
                favoriteLabel
            }

        }
        .font(.title3)
        .foregroundColor(Color.black)
        .shadow(color: Color.defaultShadowColor, radius: 1, x: 1, y: 1)
    }

    var title: some View {
        Text(viewModel.title)
            .lineLimit(2)
            .font(.title2)
            .foregroundColor(Color.defaultTextColor)
            .frame(maxWidth: 400)
    }

    var favoriteLabel: some View {
        Label("Favorite", systemImage: viewModel.isFavorite ? "heart.fill" : "heart")
            .labelStyle(IconOnlyLabelStyle())
            .foregroundColor(viewModel.isFavorite ? Color.red : Color.black)
            .padding(4)
    }
}

// MARK: - Preview
struct Preview_StoryDisplayable: StoryCardDisplayable {
    var id = UUID()

    var title = "The Great adventures of the Cat blah blah blah"
    var duration = "1:30"
    var image = UIImage(named: "test_image")!
    var numberOfPages = 5
    var isFavorite: Bool
    var storyURL: URL? = FileManager.default.temporaryDirectory

    init(isFavorite: Bool = false) {
        self.isFavorite = isFavorite
    }

    func toggleFavorite() {

    }
}

struct StoryCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: Array(repeating: .init(.fixed(350)), count: 2), alignment: .top) {
                StoryCard(viewModel: Preview_StoryDisplayable())
                    .environmentObject(Store(initialState: AppState(), reducer: appReducer))
            }
        }
        .previewInterfaceOrientation(.landscapeLeft)
        .preferredColorScheme(.dark)

    }
}
