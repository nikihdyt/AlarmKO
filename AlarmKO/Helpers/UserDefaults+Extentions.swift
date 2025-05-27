//
//  UserDefaults+Extentions.swift
//  AlarmKO
//
//  Created by Ziqa on 26/05/25.
//

import SwiftUI


extension UserDefaults {
    
    func set<T: RawRepresentable>(_ value: Set<T>, forKey key: String) where T.RawValue == String {
        let array = Array(value).map { $0.rawValue }
        set(array, forKey: key)
    }
    
    func getSet<T: RawRepresentable>(forKey key: String, type: T.Type) -> Set<T> where T.RawValue == String, T: CaseIterable {
        guard let array = stringArray(forKey: key) else { return [] }
        let set = Set(array.compactMap { T(rawValue: $0) })
        return set
    }
}

