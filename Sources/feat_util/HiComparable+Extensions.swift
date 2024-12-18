//
//  HiComparable+Extensions.swift
//  feat_util
//
//  Created by netcanis on 12/13/24.
//

import Foundation

/// Extension to clamp values within a specified range.
public extension Comparable {
    /// Clamps the value to a given range.
    ///
    /// - Parameter limits: A closed range within which the value is clamped.
    /// - Returns: The clamped value.
    ///
    /// ### Example
    /// ```swift
    /// let value = 10
    /// let clampedValue = value.hiClamped(to: 5...8)
    /// print(clampedValue) // Output: 8
    /// ```
    func hiClamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
