//
//  PlayerViewModelFactory.swift
//  LonesomeDove
//
//  Created on 1/22/22.
//

import AVFoundation
import Foundation
import Media
import UIKit

protocol PlayerViewModelProvider {
    func playerViewModel(from storyCardViewModel: StoryCardViewModel) async throws -> PlayerViewModel
}

struct PlayerViewModelFactory: PlayerViewModelProvider {

    enum PlayerViewModelError: Error {
        case failedToCreatePlayerViewModel
    }

    func playerViewModel(from storyCardViewModel: StoryCardViewModel) async throws -> PlayerViewModel {
        guard let url = storyCardViewModel.storyURL
        else {
            throw PlayerViewModelError.failedToCreatePlayerViewModel
        }

        let asset = AVURLAsset(url: url)
        await asset.loadValues(forKeys: ["tracks", "duration", "metadata"])
        let timedMetadataReader = TimedMetadataReader(asset: asset)
        let timedMetadata = await timedMetadataReader.readTimedMetadata()
        let imageTimedMetadata = timedMetadata
            .flatMap { $0 }
            .filter { $0.items.first?.identifier == StoryTimeMediaIdentifiers.imageTimedMetadataIdentifier.metadataIdentifier }

        let images = imageTimedMetadata
            .flatMap { $0.items }
            .compactMap { $0.dataValue }
            .compactMap { UIImage(data: $0) }
        let timeRanges = imageTimedMetadata.map { $0.timeRange }

        return PlayerViewModel(asset: asset, images: images, timeRanges: timeRanges)
    }

}
