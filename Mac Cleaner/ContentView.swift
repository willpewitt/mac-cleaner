import SwiftUI

enum AppScreen {
    case picking
    case reviewing(FileReviewModel)
    case summary(FileReviewModel)
}

struct ContentView: View {
    @State private var screen: AppScreen = .picking

    var body: some View {
        Group {
            switch screen {
            case .picking:
                DirectoryPickerView { urls in
                    screen = .reviewing(FileReviewModel(files: urls))
                }
            case .reviewing(let model):
                FileReviewView(model: model) {
                    screen = .summary(model)
                }
            case .summary(let model):
                SummaryView(model: model) {
                    screen = .picking
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
