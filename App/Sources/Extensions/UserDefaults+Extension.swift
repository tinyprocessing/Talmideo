import Foundation

extension UserDefaults {
    /// Caches single value per type identifier
    func cache<T: Encodable>(_ value: T, with encoder: JSONEncoder = JSONEncoder()) {
        let encoded = try? encoder.encode(value)
        setValue(encoded, forKey: String(describing: T.self))
    }

    /// Returns cached value from its type identifier
    func getCachedObject<T: Decodable>(of type: T.Type, with decoder: JSONDecoder = JSONDecoder())
        -> T? {
        guard let data = object(forKey: String(describing: T.self)) as? Data else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }
}
