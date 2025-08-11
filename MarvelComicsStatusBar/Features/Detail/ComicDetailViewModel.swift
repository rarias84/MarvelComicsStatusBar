import SwiftUI

@MainActor
final class ComicDetailViewModel: ObservableObject {
    @Published var comic: Comic
    
    let attributionText: String?
    
    init(comic: Comic, attributionText: String? = nil) {
        self.comic = comic
        self.attributionText = attributionText
    }
    
    var onsaleText: String? {
        guard let date = comic.onsaleDate else {
            return nil
        }
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }
    
    var priceText: String? {
        guard let value = comic.price else {
            return nil
        }
        return NumberFormatter.currency.string(from: NSDecimalNumber(decimal: value))
    }
}
