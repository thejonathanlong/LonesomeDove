//
//  QuipsLoadingViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/11/22.
//

import Combine
import Foundation

class QuipsLoadingViewModel: LoadingViewDisplayable {
    @Published var title: String
    
    let quips: [String]
    
    var cancellables = Set<AnyCancellable>()
    
    var quipsIterator: IndexingIterator<[String]>
    
    init(quips: [String] = [
        "Saddling unicorns...",
        "Slaying dragons...",
        "Putting pots of gold at end of rainbows...",
        "Preparing flying carpets...",
        "Placing swords in stones...",
        "Burying treasure...",
        "Herding the pegasi...",
        "Building the wooden horse...",
        "Leaving the glass slipper...",
        "Educating the talking animals...",
        "Making the bears pooridge...",
    ]) {
        self.quips = quips
        self.quipsIterator = quips.makeIterator()
        self.title = quips.first ?? "Loading..."
    }
    
    public func start() {
        Timer
            .publish(every: 3, tolerance: nil, on: .current, in: .default, options: .none)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)
    }
    
    private func updateTitle() {
        if let next = quipsIterator.next() {
            title = next
        } else {
            quipsIterator = quips.makeIterator()
            updateTitle()
        }
    }
    
    
}
