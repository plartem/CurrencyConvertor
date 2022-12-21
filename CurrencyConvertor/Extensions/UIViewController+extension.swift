//
//  UIViewController+extension.swift
//  CurrencyConvertor
//
//

import Foundation
import UIKit

extension UIViewController {
    enum PresentError: Error {
        case alreadyPresentingOther
    }
    func pushOrPresent(_ viewController: UIViewController) throws {
        if let navController = navigationController {
            navController.pushViewController(viewController, animated: true)
        } else if presentedViewController == nil {
            present(viewController, animated: true, completion: nil)
        } else {
            throw PresentError.alreadyPresentingOther
        }
    }
    func popOrDismiss() throws {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else if presentedViewController == self {
            dismiss(animated: true)
        } else {
            throw PresentError.alreadyPresentingOther
        }
    }
}
