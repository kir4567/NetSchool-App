//
//  Network.swift
//  NetSchool App
//
//  Created by Кирилл Руднев on 06.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Reachability

/// Enumeration represents data loading status
enum Status {
    case error, loading, successful, canceled
}

class ReachabilityManager: NSObject {
    /// Shared instance
    static let shared = ReachabilityManager()
    /// Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return previousReachabilityStatus != .none
    }
    /// Reachability instance for Network status monitoring
    let reachability = Reachability()!
    /// Previous NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var previousReachabilityStatus: Reachability.Connection = .wifi
    
    /**
     Called whenever there is a change in NetworkReachibility Status
     — parameter notification: Notification with the Reachability instance
     */
    @objc func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        guard previousReachabilityStatus == .none else {
            previousReachabilityStatus = reachability.connection
            return
        }
        previousReachabilityStatus = reachability.connection
        switch reachability.connection {
        case .wifi, .cellular:
            ()
//            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController,
//                let menuViewController = rootViewController as? SWRevealViewController,
//                let navigationController = menuViewController.frontViewController as? UINavigationController else { return }
//            for viewController in navigationController.viewControllers {
//                switch viewController {
//                case let diaryViewController as DiaryViewController:
//                    for case let viewController as DiaryContentViewController in diaryViewController.childViewControllers {
//                        viewController.internetConnectionAppeared()
//                    }
//                case let scheduleViewController as Schedule:
//                    scheduleViewController.internetConnectionAppeared()
//                case let detailsViewController as Details:
//                    detailsViewController.internetConnectionAppeared()
//                case let postsViewController as Posts:
//                    postsViewController.internetConnectionAppeared()
//                case let forumViewController as Forum:
//                    forumViewController.internetConnectionAppeared()
//                case let forumDetailsViewController as ForumDetail:
//                    forumDetailsViewController.internetConnectionAppeared()
//                case let mailViewController as Mail:
//                    mailViewController.internetConnectionAppeared()
//                case let adressBookViewController as AdressBook:
//                    adressBookViewController.internetConnectionAppeared()
//                case let filesViewController as Files:
//                    filesViewController.internetConnectionAppeared()
//                default:
//                    ()
//                }
//            }
        default: ()
        }
    }
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: reachability)
    }
}
