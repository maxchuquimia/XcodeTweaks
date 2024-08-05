//
//  Optional.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 23/6/2024.
//

import Foundation

extension Optional {

    func get() throws -> Wrapped {
        guard let value = self else { throw "Unable to unwrap value" }
        return value
    }

}
