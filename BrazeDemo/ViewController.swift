//
//  ViewController.swift
//  BrazeDemo
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 23/09/21.
//

import UIKit

class ViewController: UIViewController {

    private let appboyHelper = AppboyHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appboyHelper.addObserverForContentCards(observer: self, selector: #selector(contentCardsUpdated))
        appboyHelper.requestContentCardsRefresh()
    }

    @objc private func contentCardsUpdated(_ notification: Notification) {
        if let cards = appboyHelper.handleContentCardsUpdated(notification, for: [.none]) as? [FullPageMessage] {
            let filteredCards = cards.filter({ $0.feedType == "featured_banners_today" })
            print(filteredCards)
        }
    }
    
}

