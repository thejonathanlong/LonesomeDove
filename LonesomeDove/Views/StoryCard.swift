//
//  StoryCard.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

// MARK: - StoryCardDisplayable
protocol StoryCardDisplayable: Identifiable, ObservableObject {
    var title: String { get }
    var timeStamp: String { get }
    var duration: TimeInterval { get }
    var numberOfPages: Int { get }
    var posterImage: UIImage? { get }
    var placeHolderPosterImage: UIImage { get }
    var isFavorite: Bool { get }
    var storyURL: URL? { get }
    var type: StoryType { get }

//    func toggleFavorite()
    
//    func shareStory()

    var id: UUID { get }
}

// MARK: - StoryCard
struct StoryCard<ViewModel>: View where ViewModel: StoryCardDisplayable {

    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: viewModel.posterImage ?? viewModel.placeHolderPosterImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 150, maxHeight: 300)
                    .cornerRadius(17)
                badges
                    .padding()
            }

            heading
        }
        .padding()
        .cornerRadius(25, corners: .allCorners, backgroundColor: Color.funColor(for: viewModel.duration))
        .shadow(color: Color.defaultShadowColor, radius: 3, x: 1, y: 1)
    }

    var heading: some View {
        VStack(alignment: .leading, spacing: 10) {
            title
            Divider()
            info
        }
    }

    var badges: some View {
        HStack {
            if viewModel.type == .draft {
                draftBadge
            }
        }
    }

    var draftBadge: some View {
        Text(viewModel.type.description)
            .font(.caption)
            .foregroundColor(.defaultTextColor)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(Color.badgeBackgroundColor .clipShape(RoundedRectangle(cornerRadius: 12)))
    }
    
    var info: some View {
        HStack {
            Label(viewModel.timeStamp, systemImage: "clock")
            Text("|")
            Label("\(viewModel.numberOfPages) pages", systemImage: "book")
            Spacer()
            if viewModel.type == .finished {
                Button {
                    store.dispatch(.storyCard(.shareStory(viewModel.storyURL, CGRect.zero)))
                } label: {
                    shareLabel
                }
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
    
    var shareLabel: some View {
        Label("Share", systemImage: "square.and.arrow.up")
            .labelStyle(IconOnlyLabelStyle())
            .foregroundColor(Color.black)
            .padding(4)
    }

    var favoriteLabel: some View {
        Label("Favorite", systemImage: viewModel.isFavorite ? "heart.fill" : "heart")
            .labelStyle(IconOnlyLabelStyle())
            .foregroundColor(viewModel.isFavorite ? Color.red : Color.black)
            .padding(4)
    }
}

// MARK: - Preview
class Preview_StoryDisplayable: StoryCardDisplayable {
    
    var placeHolderPosterImage: UIImage = UIImage()
    
    var duration: TimeInterval {
        100
    }

    var id = UUID()

    var title = "The Great adventures of the Cat blah blah blah"
    var timeStamp = "1:30"
    var posterImage = UIImage(named: "placeholder")
    var numberOfPages = 5
    var isFavorite: Bool
    var storyURL: URL? = FileManager.default.temporaryDirectory

    var type = StoryType.draft

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
