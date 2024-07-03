//
//  UserDefaults+Extensions.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 01/11/2023.
//

import Foundation

public extension UserDefaults {

    func decodeObject<T>(forKey key: String) -> T? where T: Decodable {
        guard let saved = self.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        let loaded = try? decoder.decode([T].self, from: saved).first
        return loaded
    }

    func encode<T>(_ value: T?, forKey key: String) where T: Encodable {

        let string = "\(UserDefaults.didChangeNotification.rawValue)-\(key)"
        let name = NSNotification.Name(rawValue: string)

        let encoder = JSONEncoder()
        guard let value = value, let encoded = try? encoder.encode([value]) else {
            self.removeObject(forKey: key)
            NotificationCenter.default.post(name: name, object: nil)
            return
        }
        self.set(encoded, forKey: key)
        NotificationCenter.default.post(name: name, object: nil)
    }

    func hasValue(forKey key: String) -> Bool {
        return nil != object(forKey: key)
    }
}

@propertyWrapper
open class UserDefault<Value: Codable> {

    fileprivate var key: String
    fileprivate var defaultValue: Value

    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    open var wrappedValue: Value {
        get { UserDefaults.standard.decodeObject(forKey: key) ?? self.defaultValue }
        set { UserDefaults.standard.encode(newValue, forKey: key) }
    }
}

@propertyWrapper
open class UserDefaultOptional<Value: Codable> {

    fileprivate var key: String

    public  init(_ key: String) {
        self.key = key
    }

    open var wrappedValue: Value? {
        get { UserDefaults.standard.decodeObject(forKey: key) }
        set { UserDefaults.standard.encode(newValue, forKey: key) }
    }
}
