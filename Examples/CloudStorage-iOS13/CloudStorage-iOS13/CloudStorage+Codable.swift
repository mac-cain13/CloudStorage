//
//  CloudStorage+Codable.swift
//  CloudStorage-iOS13
//
//  Created by Tom Lokhorst on 2020-07-18.
//

import SwiftUI
import CloudStorage

private let sync = CloudStorageSync.shared

extension CloudStorage where Value: Codable {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding {
            guard let data = sync.data(for: key) else { return wrappedValue }
            do {
                let decoder = PropertyListDecoder()
                let value = try decoder.decode(Value.self, from: data)
                return value
            } catch {
                assertionFailure("\(error)")
                return wrappedValue
            }
        }
        set: { newValue in
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(newValue)
                sync.set(data, for: key)
            } catch {
                assertionFailure("\(error)")
            }
        }
        self.init(keyName: key, syncBinding: binding)
    }
}
