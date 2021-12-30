//
//  TimerView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/27/21.
//

import SwiftUI

protocol TimerDisplayable: ObservableObject {
    var time: Int { get }
    var timeString: String { get }
}

extension TimerDisplayable {
    var timeString: String {
        let minutes = time / 60
        let seconds = time - (60 * minutes)
        
        return "\(minutes):\(seconds > 10 ? "\(seconds)" : "0" + "\(seconds)")"
    }
}

struct TimerView<ViewModel>: View where ViewModel : TimerDisplayable {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text("\(viewModel.timeString)")
    }
    
    
}

class TimerView_PreviewModel: TimerDisplayable {
    var time: Int {
        351
    }
}
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(viewModel: TimerView_PreviewModel())
    }
}
