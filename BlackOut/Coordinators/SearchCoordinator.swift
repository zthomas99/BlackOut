//
//  SearchCoordinator.swift
//  BlackOut
//
//  Created by Codex on 4/17/26.
//

import UIKit

protocol SearchCoordinating {
    func presentPlaces(from viewController: UIViewController,
                       searchText: UITextField,
                       delegate: PlacesViewControllerDelegate,
                       transitioningDelegate: UIViewControllerTransitioningDelegate?)
}

final class SearchCoordinator: SearchCoordinating {

    static let shared = SearchCoordinator()

    private init() {}

    func presentPlaces(from viewController: UIViewController,
                       searchText: UITextField,
                       delegate: PlacesViewControllerDelegate,
                       transitioningDelegate: UIViewControllerTransitioningDelegate?) {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let places = storyboard.instantiateViewController(withIdentifier: "PlacesController") as? PlacesViewController

        guard let placesViewController = places else { return }

        placesViewController.searchText = searchText
        placesViewController.modalPresentationStyle = .fullScreen
        placesViewController.delegate = delegate
        placesViewController.transitioningDelegate = transitioningDelegate

        viewController.present(placesViewController, animated: true, completion: nil)
    }
}
