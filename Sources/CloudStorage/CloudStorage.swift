//
//  CloudStorage.swift
//  CloudStorage
//
//  Created by Tom Lokhorst on 2020-07-05.
//

import SwiftUI
import Combine

private let sync = CloudStorageSync.shared

@propertyWrapper public struct CloudStorage<Value>: DynamicProperty {
    @ObservedObject private var object: CloudStorageObject<Value>

    public var wrappedValue: Value {
        get { object.value }
        nonmutating set { object.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        Binding { object.value } set: { object.value = $0 }
    }

    public init(keyName key: String, syncBinding: Binding<Value>) {
        self.object = CloudStorageObject(key: key, syncBinding: syncBinding)
    }
}

internal class CloudStorageObject<Value>: ObservableObject {
    private let syncBinding: Binding<Value>

    var value: Value {
        get { syncBinding.wrappedValue }
        set {
            syncBinding.wrappedValue = newValue
            sync.synchronize()
            objectWillChange.send()
        }
    }

    init(key: String, syncBinding: Binding<Value>) {
        self.syncBinding = syncBinding

        sync.addObserver(for: key, publisher: objectWillChange)
    }

    deinit {
        sync.removeObserver(publisher: objectWillChange)
    }
}

extension CloudStorage where Value == Bool {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.bool(for: key) ?? wrappedValue } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Int {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.int(for: key) ?? wrappedValue } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Double {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.double(for: key) ?? wrappedValue } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == String {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.string(for: key) ?? wrappedValue } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == URL {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.url(for: key) ?? wrappedValue } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Data {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.data(for: key) ?? wrappedValue } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value: RawRepresentable, Value.RawValue == Int {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.int(for: key).flatMap(Value.init) ?? wrappedValue } set: { sync.set($0.rawValue, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value: RawRepresentable, Value.RawValue == String {
    public init(wrappedValue: Value, _ key: String) {
        let binding = Binding { sync.string(for: key).flatMap(Value.init) ?? wrappedValue } set: { sync.set($0.rawValue, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Bool? {
    public init(_ key: String) {
        let binding = Binding { sync.bool(for: key) } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Int? {
    public init(_ key: String) {
        let binding = Binding { sync.int(for: key) } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Double? {
    public init(_ key: String) {
        let binding = Binding { sync.double(for: key) } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == String? {
    public init(_ key: String) {
        let binding = Binding { sync.string(for: key) } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == URL? {
    public init(_ key: String) {
        let binding = Binding { sync.url(for: key) } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}

extension CloudStorage where Value == Data? {
    public init(_ key: String) {
        let binding = Binding { sync.data(for: key) } set: { sync.set($0, for: key) }
        self.init(keyName: key, syncBinding: binding)
    }
}
