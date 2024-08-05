//
//  FileManager.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 23/6/2024.
//

import Foundation

extension FileManager {

    func filesCreatedAfter(date: Date, in directoryURL: URL, type extension: String? = nil) -> [URL] {
        do {
            let fileURLs = try contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )

            return fileURLs
                .filter { fileURL in
                    if let e = `extension` {
                        guard fileURL.pathExtension == e else { return false }
                    }

                    if let creationDate = try? fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate {
                        return creationDate > date
                    }

                    return false
                }
        } catch {
            print("Error getting contents of directory: \(error)")
            return []
        }
    }

}
