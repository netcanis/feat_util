//
//  HiString+Extensions.swift
//  feat_util
//
//  Created by netcanis on 11/11/24.
//

import Foundation

/// Extension for adding utility functions to `String`.
public extension String {
    /// Load a string value from UserDefaults.
    ///
    /// - Returns: The stored string value or an empty string if not found.
    ///
    /// ### Example
    /// ```swift
    /// let loadedValue = "username".hiLoad()
    /// print(loadedValue)
    /// ```
    func hiLoad() -> String {
        return UserDefaults.standard.string(forKey: self) ?? ""
    }

    /// Save the string value to UserDefaults.
    ///
    /// - Parameter key: The key to associate with the value.
    ///
    /// ### Example
    /// ```swift
    /// "JohnDoe".hiSave(forKey: "username")
    /// ```
    func hiSave(forKey key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }

    /// Remove the value associated with the string key from UserDefaults.
    ///
    /// ### Example
    /// ```swift
    /// "username".hiRemove()
    /// ```
    func hiRemove() {
        UserDefaults.standard.removeObject(forKey: self)
    }

    /// Returns a substring from the start index to the specified end index.
    ///
    /// - Parameter to: The end index (exclusive).
    /// - Returns: A substring.
    ///
    /// ### Example
    /// ```swift
    /// let result = "HelloWorld".hiSubstring(to: 5)
    /// print(result) // Output: Hello
    /// ```
    func hiSubstring(to: Int) -> String {
        guard to >= 0 else { return "" }
        let endIndex = index(startIndex, offsetBy: min(to, count), limitedBy: endIndex) ?? endIndex
        return String(self[..<endIndex])
    }

    /// Returns a substring starting from the specified index to the end.
    ///
    /// - Parameter from: The starting index.
    /// - Returns: A substring.
    ///
    /// ### Example
    /// ```swift
    /// let result = "HelloWorld".hiSubstring(from: 5)
    /// print(result) // Output: World
    /// ```
    func hiSubstring(from: Int) -> String {
        guard from < count else { return "" }
        let startIndex = index(self.startIndex, offsetBy: max(0, from), limitedBy: endIndex) ?? endIndex
        return String(self[startIndex...])
    }

    /// Returns a substring within a specified range of indices.
    ///
    /// - Parameter range: A `ClosedRange` representing the start and end indices.
    /// - Returns: A substring from the specified range.
    ///
    /// ### Example
    /// ```swift
    /// let result = "HelloWorld".hiSubstring(0...4)
    /// print(result) // Output: Hello
    /// ```
    func hiSubstring(_ range: ClosedRange<Int>) -> String {
        let lowerBound = range.lowerBound.hiClamped(to: 0...count - 1)
        let upperBound = range.upperBound.hiClamped(to: lowerBound...count - 1)
        let startIndex = self.index(self.startIndex, offsetBy: lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: upperBound + 1)
        return String(self[startIndex..<endIndex])
    }

    /// Sanitizes a string by removing control characters.
    ///
    /// - Returns: A sanitized string.
    ///
    /// ### Example
    /// ```swift
    /// let dirtyString = "Hello\u{0008}World"
    /// let sanitized = dirtyString.hiSanitize()
    /// print(sanitized) // Output: HelloWorld
    /// ```
    func hiSanitize() -> String {
        return self.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }.reduce("") { $0 + String($1) }
    }
}



public extension String {
    /// Checks whether the string is a valid Luhn number.
    ///
    /// - Returns: `true` if valid, otherwise `false`.
    ///
    /// ### Example
    /// ```swift
    /// let isValid = "79927398713".hiLuhnValidation
    /// print(isValid) // Output: true
    /// ```
    var hiLuhnValidation: Bool {
        guard self.allSatisfy({ $0.isNumber }) else { return false }

        var sum = 0
        let reversedDigits = self.reversed().compactMap { Int(String($0)) }

        for (index, digit) in reversedDigits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }

        return sum % 10 == 0
    }

    /// Converts a decimal string to a base-20 encoded string.
    ///
    /// - Returns: A base-20 encoded string.
    ///
    /// ### Example
    /// ```swift
    /// let result = "123456".hiDecimalToBase20()
    /// print(result) // Output: 00000FHL
    /// ```
    func hiDecimalToBase20() -> String {
        guard let decimal = UInt64(self) else { return "0" }

        let conversionTable: [UInt8] = [
            48, 49, 50, 51, 52, 53, 54, 55, 56, 57, // 0-9
            65, 98, 67, 100, 69, 70, 72, 76, 80, 85 // A, b, C, d, E, F, H, L, P, U
        ]

        var num = decimal
        var result = ""

        while num > 0 {
            let mod = num % 20
            let char = conversionTable[Int(mod)]
            result.insert(Character(UnicodeScalar(char)), at: result.startIndex)
            num /= 20
        }

        while result.count < 9 {
            result = "0" + result
        }

        return result.isEmpty ? "0" : result
    }

    /// Converts a base-20 encoded string to a decimal number (UInt64).
    ///
    /// This method supports a custom base-20 encoding scheme where characters `0-9`
    /// and `A, b, C, d, E, F, H, L, P, U` (case-insensitive) represent the values 0 to 19.
    ///
    /// - Returns: The decimal equivalent of the base-20 string as `UInt64`.
    ///
    /// ### Example
    /// ```swift
    /// let base20String = "FHL"
    /// let decimalValue = base20String.hiBase20ToDecimal()
    /// print(decimalValue) // Output: 123456
    /// ```
    func hiBase20ToDecimal() -> UInt64 {
        let conversionTable: [Character: UInt64] = [
            "0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
            "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
            "A": 10, "a": 10, "b": 11, "B": 11,
            "C": 12, "c": 12, "d": 13, "D": 13,
            "E": 14, "e": 14, "F": 15, "f": 15,
            "H": 16, "h": 16, "L": 17, "l": 17,
            "P": 18, "p": 18, "U": 19, "u": 19
        ]

        var result: UInt64 = 0

        for char in self {
            if let value = conversionTable[char] {
                result = result * 20 + value
            }
        }

        return result
    }

    /// Converts a hexadecimal string to `Data`.
    ///
    /// - Returns: A `Data` object if the conversion is successful, otherwise `nil`.
    ///
    /// ### Example
    /// ```swift
    /// let hexString = "48656C6C6F" // "Hello" in hex
    /// if let data = hexString.hiHexStringToData() {
    ///     print(String(data: data, encoding: .utf8)!) // Output: Hello
    /// }
    /// ```
    func hiHexToData() -> Data? {
        guard !self.isEmpty else {
            print("Empty string cannot be converted to Data.")
            return nil
        }

        var data = Data()
        var tempHex = self

        // Ensure even-length string by padding with "0" if necessary
        if tempHex.count % 2 != 0 {
            tempHex = "0" + tempHex
        }

        // Convert hex string to bytes
        for i in stride(from: 0, to: tempHex.count, by: 2) {
            let start = tempHex.index(tempHex.startIndex, offsetBy: i)
            let end = tempHex.index(start, offsetBy: 2)
            let byteString = tempHex[start..<end]

            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                print("Invalid hex byte: \(byteString)")
                return nil
            }
        }

        return data
    }
}
