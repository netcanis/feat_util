//
//  HiUIViewController+Extensions.swift
//  feat_util
//
//  Created by netcanis on 11/7/24.
//

import UIKit

/// Extension to manage the top-most `UIViewController`.
public extension UIViewController {
    /// Returns the top-most view controller in the app.
    ///
    /// - Returns: The top-most `UIViewController`.
    ///
    /// ### Example
    /// ```swift
    /// if let topVC = UIViewController.hiTopMostViewController() {
    ///     print("Top ViewController: \(topVC)")
    /// }
    /// ```
    static func hiTopMostViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        return UIViewController.hiGetTopViewController(from: rootViewController)
    }

    private static func hiGetTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return hiGetTopViewController(from: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return hiGetTopViewController(from: visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return hiGetTopViewController(from: selectedViewController)
        }
        return viewController
    }
}
