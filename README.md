# feat_util

`feat_util` is a Swift module providing a set of utility extensions to enhance common data structures and types such as `Comparable`, `Dictionary`, `String`, and `UIViewController`. These extensions simplify operations like clamping values, JSON conversion, string manipulation, and managing top-most view controllers in iOS.

---

## Features

### 1. `Comparable` Extensions
Adds functionality to clamp values within a specific range.

#### Methods
- **`hiClamped(to:)`**: Clamps the value to a specified range.

#### Example
```swift
let value = 10
let clampedValue = value.hiClamped(to: 5...8)
print(clampedValue) // Output: 8
```

### 2. Dictionary Extensions
Provides a convenient way to convert dictionaries to JSON strings.

#### Methods
    •    hiToJSONString(prettyPrinted:): Converts a dictionary to a JSON string. Optionally supports pretty-printed output.

#### Example
```swift
let dict = ["name": "John", "age": 25]
let jsonString = dict.hiToJSONString(prettyPrinted: true)
print(jsonString ?? "Invalid JSON")
```

### 3. String Extensions
Enhances String functionality with various utility methods.

#### Methods
    •    hiLoad(): Loads a string value from UserDefaults.
    •    hiSave(forKey:): Saves the string value to UserDefaults.
    •    hiRemove(): Removes the value associated with the string key from UserDefaults.
    •    hiSubstring(to:): Returns a substring up to a specified index.
    •    hiSubstring(from:): Returns a substring starting from a specified index.
    •    hiSubstring(_ range:): Returns a substring within a specific range.
    •    hiSanitize(): Removes control characters from the string.
    •    hiLuhnValidation: Checks if the string is a valid Luhn number.
    •    hiDecimalToBase20(): Converts a decimal string to a base-20 encoded string.
    •    hiBase20ToDecimal(): Converts a base-20 encoded string to a decimal number.
    •    hiHexToData(): Converts a hexadecimal string to Data.

#### Examples
```swift
// Substring
let result = "HelloWorld".hiSubstring(0...4)
print(result) // Output: Hello

// Luhn Validation
let isValid = "79927398713".hiLuhnValidation
print(isValid) // Output: true

// Base-20 Encoding
let base20String = "123456".hiDecimalToBase20()
print(base20String) // Output: 00000FHL
```

### 4. UIViewController Extensions

Simplifies management of the top-most view controller.

#### Methods
    •    hiTopMostViewController(): Returns the top-most view controller in the app.

#### Example
```swift
if let topVC = UIViewController.hiTopMostViewController() {
    print("Top ViewController: \(topVC)")
}
```

---

## **Installation**

### **Swift Package Manager (SPM)**

1. Open your project in **Xcode**.
2. Go to **File > Add Packages...**.
3. Enter the repository URL:  https://github.com/netcanis/feat_util.git
4. Select the desired version and integrate the package into your project.

---

## **License**

feat_qr is available under the MIT License. See the LICENSE file for details.

---

## **Contributing**

Contributions are welcome! To contribute:

1. Fork this repository.
2. Create a feature branch:
```
git checkout -b feature/your-feature
```
3. Commit your changes:
```
git commit -m "Add feature: description"
```
4. Push to the branch:
```
git push origin feature/your-feature
```
5. Submit a Pull Request.

---

## **Author**

### **netcanis**
GitHub: https://github.com/netcanis

---
