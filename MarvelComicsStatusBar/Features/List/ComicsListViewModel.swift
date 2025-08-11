import Foundation

@MainActor
final class ComicsListViewModel: ObservableObject {
    @Published var groups: [CreatorGroup] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var resetNavigationFlag: Bool = false

    private let client: MarvelService
    
    init(client: MarvelService) {
        self.client = client
    }

    struct CreatorGroup: Identifiable {
        let id = UUID()
        let creator: String
        let comics: [Comic]
    }

    func load() async {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }

        do {
            let dtos = try await client.comics(limit: 50)
            let comics = dtos.map(ComicMapper.map)
            let dict = Dictionary(grouping: comics, by: { $0.creators.first?.name ?? "Unknown" })
            groups = dict
                .map { CreatorGroup(creator: $0.key, comics: $0.value.sorted { $0.title < $1.title }) }
                .sorted { $0.creator < $1.creator }
        } catch {
            self.error = "No se pudieron cargar los cómics. Intenta nuevamente."
        }
    }
}
