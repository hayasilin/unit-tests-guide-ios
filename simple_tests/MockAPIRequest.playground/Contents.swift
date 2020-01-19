import UIKit
import Foundation
import XCTest

// Reference: https://www.amazon.co.jp/iOS%E3%82%A2%E3%83%97%E3%83%AA%E9%96%8B%E7%99%BA%E8%87%AA%E5%8B%95%E3%83%86%E3%82%B9%E3%83%88%E3%81%AE%E6%95%99%E7%A7%91%E6%9B%B8%E3%80%9CXCTest%E3%81%AB%E3%82%88%E3%82%8B%E5%8D%98%E4%BD%93%E3%83%86%E3%82%B9%E3%83%88%E3%83%BBUI%E3%83%86%E3%82%B9%E3%83%88%E3%81%8B%E3%82%89%E3%80%81CI-CD%E3%80%81%E3%83%87%E3%83%90%E3%83%83%E3%82%B0%E6%8A%80%E8%A1%93%E3%81%BE%E3%81%A7-%E5%B9%B3%E7%94%B0-%E6%95%8F%E4%B9%8B/dp/4297106299

struct GitHubRepository: Codable {
    let id: Int
    let star: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case star = "stargazers_count"
        case name
    }
}

protocol GitHubAPIClientProtocol {
    func fetchRepositories(user: String, handler: @escaping([GitHubRepository]?) -> Void)
}

class GitHubAPIClient: GitHubAPIClientProtocol {
    func fetchRepositories(user: String, handler: @escaping([GitHubRepository]?) -> Void) {
        let url = URL(string: "https://api.github.com/users/\(user)/repos")!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                handler(nil)
                return
            }

            let repos = try! JSONDecoder().decode([GitHubRepository].self, from: data)
            handler(repos)
        }
        task.resume()
    }
}

class GitHubRepositoryManager {
    private let client: GitHubAPIClientProtocol
    private var repos: [GitHubRepository]?

    var majorRepositories: [GitHubRepository] {
        guard let repositories = self.repos else { return [] }
        return repositories.filter({ $0.star >= 5 })
    }

    init(client: GitHubAPIClientProtocol) {
        self.client = client
    }

    func load(user: String, completion: @escaping () -> Void) {
        self.client.fetchRepositories(user: user) { (repositories) in
            self.repos = repositories
            completion()
        }
    }
}

var manager = GitHubRepositoryManager(client: GitHubAPIClient())
manager.load(user: "apple") {

}

// Use mock object

class MockGitHubAPIClient: GitHubAPIClientProtocol {
    var returnRepositories: [GitHubRepository]
    var argsUser: String?

    init(repositories: [GitHubRepository]) {
        self.returnRepositories = repositories
    }

    func fetchRepositories(user: String, handler: @escaping ([GitHubRepository]?) -> Void) {
        self.argsUser = user
        handler(returnRepositories)
    }
}

class GitHubRepositoryManagerTests: XCTestCase {

    func testMajorRepositories() {
        let testRepositories: [GitHubRepository] = [
            GitHubRepository(id: 0, star: 9, name: ""),
            GitHubRepository(id: 1, star: 10, name: ""),
            GitHubRepository(id: 2, star: 11, name: "")
        ]

        let mockClient = MockGitHubAPIClient(repositories: testRepositories)
        let manager = GitHubRepositoryManager(client: mockClient)

        manager.load(user: "apple") {
            XCTAssertEqual(mockClient.argsUser, "apple")

            XCTAssertEqual(manager.majorRepositories.count, 3)
            XCTAssertEqual(manager.majorRepositories[0].id, 0)
            XCTAssertEqual(manager.majorRepositories[1].id, 1)
        }
    }
}

GitHubRepositoryManagerTests.defaultTestSuite.run()
