//
//  GitHubUpdateChecker.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 25/2/2025.
//

import Foundation

private struct GitHubRelease: Decodable {
    let tag_name: String
    let html_url: String
    let body: String
}

final class GitHubUpdateChecker {

    let currentVersion: String
    private(set) var isUpdateAvailable: Bool?
    private(set) var latestVersion: String?
    private(set) var webURL: URL?
    private(set) var releaseNotes: String?
    private let repoSlug: String
    private let apiURL: URL

    init(repoSlug: String) {
        self.repoSlug = repoSlug
        self.currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        self.apiURL = URL(string: "https://api.github.com/repos/\(repoSlug)/releases/latest")!
    }

    func checkForUpdate() async throws -> (latestVersion: String, releaseNotes: String, webURL: URL)? {
        var request = URLRequest(url: apiURL)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let (data, _) = try await URLSession.shared.data(for: request)
        let latestRelease = try JSONDecoder().decode(GitHubRelease.self, from: data)

        isUpdateAvailable = isNewerVersion(latestRelease.tag_name, comparedTo: currentVersion)
        let latestVersion = latestRelease.tag_name
        let webURL = URL(string: latestRelease.html_url) ?? URL(string: "https://github.com/\(repoSlug)/releases")!
        let releaseNotes = latestRelease.body
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        self.latestVersion = latestVersion
        self.webURL = webURL
        self.releaseNotes = releaseNotes

        return isUpdateAvailable == true ? (latestVersion, releaseNotes, webURL) : nil
    }

    private func isNewerVersion(_ newVersion: String, comparedTo oldVersion: String) -> Bool {
        newVersion.compare(oldVersion, options: .numeric) == .orderedDescending
    }

}
