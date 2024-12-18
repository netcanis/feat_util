//
//  HiDictionary+Extensions.swift
//  feat_util
//
//  Created by netcanis on 11/21/24.
//

import Foundation

/// Extension to work with JSON conversion for Dictionary.
public extension Dictionary where Key == String, Value: Any {
    /// Converts the dictionary to a JSON string.
    ///
    /// - Parameter prettyPrinted: Whether the JSON string should be pretty-printed.
    /// - Returns: A JSON string if the conversion succeeds, otherwise `nil`.
    ///
    /// ### Example
    /// ```swift
    /// let dict = ["name": "John", "age": 25]
    /// let jsonString = dict.hiToJSONString(prettyPrinted: true)
    /// print(jsonString ?? "Invalid JSON")
    /// ```
    func hiToJSONString(prettyPrinted: Bool = false) -> String? {
        let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
        guard JSONSerialization.isValidJSONObject(self) else {
            print("Invalid JSON object")
            return nil
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: options)
            return String(data: data, encoding: .utf8)
        } catch {
            print("JSON Serialization Error: \(error.localizedDescription)")
            return nil
        }
    }
}
