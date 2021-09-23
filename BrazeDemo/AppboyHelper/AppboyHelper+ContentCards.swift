//
//  AppboyHelper+ContentCards.swift
//  Mindvalley
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 15/09/21.
//  Copyright © 2021 Mindvalley. All rights reserved.
//

import AppboyKit

// MARK: - Content Cards

extension AppboyHelper {
    var contentCards: [ABKContentCard]? {
        return Appboy.sharedInstance()?.contentCardsController.contentCards as? [ABKContentCard]
    }
    
    /// Registers an observer to the Content Card Processed Appboy dependent Notification.
    /// - parameter observer: The listener of the `ABKContentCardsProcessed Notification`.
    /// - parameter selector: The method specified by selector must have one and only one argument (an instance of Notification).
    func addObserverForContentCards(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector,
                                               name:NSNotification.Name.ABKContentCardsProcessed, object: nil)
    }
    
    func requestContentCardsRefresh() {
        Appboy.sharedInstance()?.requestContentCardsRefresh()
    }
    
    /// Parses the Appboy dependent information from `Notification.userInfo` dictionary and converts the `ABKContentCard` objects into `ContentCardable` objects.
    /// - parameter notification: A container for information broadcast through a notification center to all registered observers.
    /// - parameter classTypes: The filter to determine what custom objects to be returned
    func handleContentCardsUpdated(_ notification: Notification, for classTypes: [ContentCardClassType]) -> [ContentCardable] {
        guard let updateIsSuccessful = notification.userInfo?[ABKContentCardsProcessedIsSuccessfulKey] as? Bool, updateIsSuccessful, let cards = contentCards else { return [] }
        
        return convertContentCards(cards, for: classTypes)
    }
    
    /// Logs an` ABKContentCard` clicked.
    /// - parameter idString: Identifier used to retrieve an ABKContentCard.
    func logContentCardClicked(idString: String?) {
        guard let contentCard = getContentCard(forString: idString) else { return }
        
        contentCard.logContentCardClicked()
    }
    
    /// Logs an` ABKContentCard` impression.
    /// - parameter idString: Identifier used to retrieve an ABKContentCard.
    func logContentCardImpression(idString: String?) {
        guard let contentCard = getContentCard(forString: idString) else { return }
        
        contentCard.logContentCardImpression()
    }
    
    /// Logs an `ABKContentCard` dismissed.
    /// - parameter idString: Identifier used to retrieve an ABKContentCard.
    func logContentCardDismissed(idString: String?) {
        guard let contentCard = getContentCard(forString: idString) else { return }
        
        contentCard.logContentCardDismissed()
    }
    
    /// Retrieves an `ABKContentCard` from the `Appboy.sharedInstance()?.contentCardsController.contentCards` array.
    /// - parameter idString: Identifier used to retrieve an ABKContentCard.
    private func getContentCard(forString idString: String?) -> ABKContentCard? {
        return contentCards?.first(where: { $0.idString == idString })
    }
}

// MARK: - Private Methods

private extension AppboyHelper {
    /// Helper method to convert `ABKContentCard` objects to `ContentCardable` objects.
    ///
    /// The variables of `ABKContentCard` are parsed into a dictionary to be used as the `metaData` parameter for the `ContentCardable` initializer. All key-value pairs from the Braze dashboard are represented in the `extras` variable.
    ///
    /// The `ContentCardKey` is used to identify the values from each `ABKContentCard` variable.
    /// - parameter cards: Array of Content Cards.
    /// - parameter classTypes: Used to determine what Content Cards to convert. If a Content Card's classType does not match any of the classTypes, it will skip converting that `ABKContentCard`.
    func convertContentCards(_ cards: [ABKContentCard], for classTypes: [ContentCardClassType]) -> [ContentCardable] {
        var contentCardables: [ContentCardable] = []
        for card in cards {
            let classTypeString = card.extras?[ContentCardKey.classType.rawValue] as? String
            let classType = ContentCardClassType(rawType: classTypeString)
            guard classTypes.contains(classType) else { continue }
            
            var metaData: [ContentCardKey: Any] = [:]
            switch card {
            case is ABKBannerContentCard:
                let banner = card as! ABKBannerContentCard
                metaData[.image] = banner.image
            case is ABKCaptionedImageContentCard:
                let captioned = card as! ABKCaptionedImageContentCard
                metaData[.title] = captioned.title
                metaData[.cardDescription] = captioned.cardDescription
                metaData[.image] = captioned.image
            case is ABKClassicContentCard:
                let classic = card as! ABKClassicContentCard
                metaData[.title] = classic.title
                metaData[.cardDescription] = classic.cardDescription
                metaData[.image] = classic.image
            default:
                break
            }
            metaData[.idString] = card.idString
            metaData[.created] = card.created
            metaData[.dismissable] = card.dismissible
            metaData[.urlString] = card.urlString
            metaData[.extras] = card.extras
            metaData[.urlString] = card.urlString
            
            if let contentCardable = contentCardable(with: metaData, for: classType) {
                contentCardables.append(contentCardable)
            }
        }
        return contentCardables
    }
    
    /// Instantiates a custom object that confroms to the `ContentCardable` protocol.
    ///
    /// - parameter metaData: `Dictionary` used to instantiate the custom object.
    /// - parameter classType: Determines the custom object to instantiate.
    func contentCardable(with metaData: [ContentCardKey: Any], for classType: ContentCardClassType) -> ContentCardable? {
        switch classType {
        case .ad:
            return nil
        case .coupon:
            return nil
        case .item(.group):
            return nil
        case .item(.tile):
            return nil
        case .message(.fullPage):
            return FullPageMessage(metaData: metaData, classType: classType)
        case .message(.webView):
            return WebViewMessage(metaData: metaData, classType: classType)
        default:
            return FullPageMessage(metaData: metaData, classType: classType)
        }
    }
}
