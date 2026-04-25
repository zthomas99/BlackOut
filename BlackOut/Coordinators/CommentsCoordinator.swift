//
//  CommentsCoordinator.swift
//  BlackOut
//
//  Created by Codex on 4/17/26.
//

import UIKit

protocol CommentsCoordinating {
    func showAddAdvice(from viewController: UIViewController)
    func showAddReply(from viewController: UIViewController)
    func showReplyReply(from viewController: UIViewController)
    func showUserReports(from viewController: UIViewController)
    func dismiss(from viewController: UIViewController)
}

final class CommentsCoordinator: CommentsCoordinating, @unchecked Sendable {

    static let shared = CommentsCoordinator()

    private init() {}

    func showAddAdvice(from viewController: UIViewController) {
        viewController.performSegue(withIdentifier: "ShowAddAdvice", sender: viewController)
    }

    func showAddReply(from viewController: UIViewController) {
        viewController.performSegue(withIdentifier: "ShowAddReply", sender: viewController)
    }

    func showReplyReply(from viewController: UIViewController) {
        viewController.performSegue(withIdentifier: "ShowReplyReply", sender: nil)
    }

    func showUserReports(from viewController: UIViewController) {
        viewController.performSegue(withIdentifier: "ShowUserReports", sender: nil)
    }

    func dismiss(from viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
