import XCTest
@testable import MarvelComicsStatusBar

@MainActor
final class ComicsListViewModelTests: XCTestCase {
    func test_grouping_by_first_creator() async {
        let vm = makeViewModel(with: [
            makeDTO(id: 1, title: "A", creators: ["Lee"]),
            makeDTO(id: 2, title: "B", creators: ["Kirby"])
        ])
        await vm.load()

        XCTAssertEqual(vm.groups.count, 2)
        XCTAssertEqual(vm.groups.map(\.creator).sorted(), ["Kirby","Lee"])
    }

    func test_groups_are_sorted_by_creator_name() async {
        let vm = makeViewModel(with: [
            makeDTO(id: 1, title: "X", creators: ["Zeta"]),
            makeDTO(id: 2, title: "Y", creators: ["Alpha"]),
            makeDTO(id: 3, title: "W", creators: ["Beta"])
        ])
        await vm.load()

        XCTAssertEqual(vm.groups.map(\.creator), ["Alpha","Beta","Zeta"])
    }

    func test_comics_sorted_by_title_within_group() async {
        let vm = makeViewModel(with: [
            makeDTO(id: 1, title: "Gamma", creators: ["Lee"]),
            makeDTO(id: 2, title: "Alpha", creators: ["Lee"]),
            makeDTO(id: 3, title: "Beta",  creators: ["Lee"])
        ])
        await vm.load()

        XCTAssertEqual(vm.groups.count, 1)
        let titles = vm.groups.first?.comics.map(\.title)
        XCTAssertEqual(titles, ["Alpha","Beta","Gamma"])
    }

    // MARK: - Missing / Unknown Creator

    func test_missing_creator_maps_to_unknown_group() async {
        let vm = makeViewModel(with: [
            makeDTOWithEmptyCreators(id: 1, title: "A"), // creators.items vacío
            makeDTO(id: 2, title: "B", creators: ["Lee"])
        ])
        await vm.load()

        let creators = Set(vm.groups.map(\.creator))
        XCTAssertTrue(creators.contains("Unknown"))
        XCTAssertTrue(creators.contains("Lee"))
    }

    func test_empty_results_produce_empty_groups() async {
        let vm = makeViewModel(with: [])
        await vm.load()

        XCTAssertTrue(vm.groups.isEmpty)
        XCTAssertNil(vm.error)
    }

    func test_error_sets_error_message_and_clears_groups() async {
        let vm = makeFailingViewModel(error: URLError(.badServerResponse))
        await vm.load()

        XCTAssertEqual(vm.error, "No se pudieron cargar los cómics. Intenta nuevamente.")
        XCTAssertTrue(vm.groups.isEmpty)
    }

    func test_isLoading_toggles_true_then_false_even_on_success() async {
        let delayed = MarvelServiceDelayedStub(dtos: [
            makeDTO(id: 1, title: "A", creators: ["Lee"])
        ], delay: 0.2)
        let vm = ComicsListViewModel(client: delayed)

        let task = Task {
            await vm.load()
        }

        try? await Task.sleep(nanoseconds: 10_000_00)
        XCTAssertTrue(vm.isLoading)

        await task.value
        XCTAssertFalse(vm.isLoading)
    }

    func test_isLoading_toggles_true_then_false_even_on_failure() async {
        let delayedFail = MarvelServiceDelayedFailingStub(errorToThrow: URLError(.badServerResponse), delay: 0.2)
        let vm = ComicsListViewModel(client: delayedFail)

        let task = Task {
            await vm.load()
        }

        try? await Task.sleep(nanoseconds: 10_000_00)
        XCTAssertTrue(vm.isLoading)

        await task.value
        XCTAssertFalse(vm.isLoading)
    }
}

private extension ComicsListViewModelTests {
    func makeDTO(id: Int, title: String, creators: [String]?) -> ComicDTO {
        ComicDTO(
            id: id,
            title: title,
            description: nil,
            issueNumber: 1,
            pageCount: nil,
            series: nil,
            dates: nil,
            prices: nil,
            thumbnail: nil,
            images: nil,
            urls: nil,
            creators: creators.map { names in
                CreatorsDTO(items: names.map { CreatorItemDTO(name: $0, role: nil) })
            },
            characters: nil
        )
    }

    func makeDTOWithEmptyCreators(id: Int, title: String) -> ComicDTO {
        ComicDTO(
            id: id,
            title: title,
            description: nil,
            issueNumber: 1,
            pageCount: nil,
            series: nil,
            dates: nil,
            prices: nil,
            thumbnail: nil,
            images: nil,
            urls: nil,
            creators: CreatorsDTO(items: []),
            characters: nil
        )
    }

    func makeViewModel(with dtos: [ComicDTO]) -> ComicsListViewModel {
        let stub = MarvelServiceStub(dtos: dtos)
        return ComicsListViewModel(client: stub)
    }

    func makeFailingViewModel(error: Error) -> ComicsListViewModel {
        let failing = MarvelServiceFailingStub(errorToThrow: error)
        return ComicsListViewModel(client: failing)
    }
}
