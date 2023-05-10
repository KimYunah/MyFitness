//
//  UIViewController.swift
//  MyFitness
//
//  Created by UMCios on 2023/05/10.
//

import UIKit

extension UIViewController {
    
    var className: String? {
        get {
            return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last
        }
    }
    
    func finish(_ animated: Bool) {
        guard let presentingViewController = presentingViewController else {
            navigationController?.popViewController(animated: animated)
            return
        }
        presentingViewController.dismiss(animated: animated, completion: nil)
    }
    
    func isVisible() -> Bool {
        return self.isViewLoaded && self.view.window != nil
    }

    func topMostViewController() -> UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.topMostViewController() ?? self
        } else if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.topMostViewController()
            } else {
                if let firstViewController = tabBarController.viewControllers?.first {
                    return firstViewController.topMostViewController()
                }
                return tabBarController.topMostViewController() //Possibly loop
            }
        } else if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        } else {
            return self
        }
    }
    
    class func instance(_ storyboardName: String) -> Self {
        func instantiateFromStoryboard<T: UIViewController>(_ storyboardName: String) -> T {
            let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
            let identifier = String(describing: self)
            return storyboard.instantiateViewController(withIdentifier: identifier) as! T
        }
        return instantiateFromStoryboard(storyboardName)
    }
    
}
