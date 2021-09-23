//
//  AppboyContentCardData.swift
//  Mindvalley
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 15/09/21.
//  Copyright © 2021 Mindvalley. All rights reserved.
//

import Foundation

///Extends custom object functionality to contain Content Card object data without any depencies of the Appboy-iOS-SDK. The logging methods can be called directly from conforming objects. For example, to log a click for a message in the Message Center, `message.logContentCardImpression()` all is that is needed.
///
/// Includes:
///- A `ContentCardData` object that represents the `ABKContentCard` data along with a `ContentCardClassType` enum.
/// - An initializer used to instantiate custom objects with `ABKContentCard` meta data.
protocol ContentCardable {
    var contentCardData: ContentCardData? { get }
    init?(metaData: [ContentCardKey: Any], classType contentCardClassType: ContentCardClassType)
}

extension ContentCardable {
    var isContentCard: Bool {
        return contentCardData != nil
    }
    
    func logContentCardClicked() {
        AppboyHelper().logContentCardClicked(idString: contentCardData?.contentCardId)
    }
    
    func logContentCardDismissed() {
        AppboyHelper().logContentCardDismissed(idString: contentCardData?.contentCardId)
    }
    
    func logContentCardImpression() {
        AppboyHelper().logContentCardImpression(idString: contentCardData?.contentCardId)
    }
}

// MARK: - ContentCardData
struct ContentCardData: Hashable {
    let contentCardId: String
    let contentCardClassType: ContentCardClassType
    let createdAt: Double
    let isDismissable: Bool
}

// MARK: - Equatable
extension ContentCardData: Equatable {
    static func ==(lhs: ContentCardData, rhs: ContentCardData) -> Bool {
        return lhs.contentCardId == rhs.contentCardId
    }
}

// MARK: - ContentCardKey
/// A safer alternative to typing "string" types. Declared as `String` type to query the key name via `rawValue`.
///
///Represents the keys in your Content Card key-value pairs.
enum ContentCardKey: String {
    case idString
    case created
    case classType = "class_type"
    case dismissable
    case extras
    case image
    case title
    case cardDescription
    case messageHeader = "message_header"
    case messageTitle = "message_title"
    case html
    case discountPercentage = "discount_percentage"
    case tags = "tile_tags"
    case contentBlock = "content_block_id"
    case detail = "tile_detail"
    case groupStyle = "group_style"
    case urlString
}

// MARK: - ContentCardClassType
///Represents the `class_type` in your Content Card key-value pairs.
enum ContentCardClassType: Hashable {
    case ad
    case coupon
    case item(ItemType)
    case message(MessageCenterViewType)
    case none
    
    enum ItemType {
        case tile
        case group
    }
    
    enum MessageCenterViewType {
        case fullPage
        case webView
    }
    
    /// - parameter rawType: This value must be synced with the `class_type` value that has been set up in your Braze dashboard or its type will be set to `ContentCardClassType.none.`
    init(rawType: String?) {
        switch rawType?.lowercased() {
        case "coupon_code":
            self = .coupon
        case "home_tile":
            self = .item(.tile)
        case "group":
            self = .item(.group)
        case "message_full_page":
            self = .message(.fullPage)
        case "message_webview":
            self = .message(.webView)
        case "ad_banner":
            self = .ad
        default:
            self = .none
        }
    }
}

///Used to represent the objects in the Message Center. The MessageCenterDataSource is populated with an array of Message protocols. In the future, if other objects conform to the Message protocol (FullPageMessage, WebViewMessage), the dataSource will not need to be refactored.
///
/// Includes:
///- The ContentCardable protocol so all objects that conform to Message are inhereintly ContentCardable.
protocol Message: ContentCardable {
    var messageHeader: String? { get }
    var messageTitle: String? { get }
    var imageUrl: String? { get }
    var cardDescription: String? { get }
}

// MARK: - WebView Message
///The object that is responsible for working with the `message_webview` class_type from the Braze dashboard. When this message is clicked on in the Message Center, it will open to a WKWebView that loads either an html string or a url string.
struct WebViewMessage: Message {
    enum WebViewType {
        case html(String)
        case url(String)
        case contentBlock(String)
        case none
    }
    
    let contentCardData: ContentCardData?
    let webViewType: WebViewType
    let messageHeader: String?
    let messageTitle: String?
    let imageUrl: String?
    let cardDescription: String?
}

// MARK: - Computed Variables
extension WebViewMessage {
    var webViewString: String {
        switch webViewType {
        case .html(let htmlString):
            return htmlString
        case .url(let urlString):
            return urlString
        case .contentBlock(let contentBlockId):
            return contentBlockId
        default: return ""
        }
    }
}

// MARK: - Content Card Initializer
extension WebViewMessage {
    init?(metaData: [ContentCardKey: Any], classType contentCardClassType: ContentCardClassType) {
        guard let contentCardId = metaData[.idString] as? String,
              let createdAt = metaData[.created] as? Double,
              let isDismissable = metaData[.dismissable] as? Bool,
              let extras = metaData[.extras] as? [AnyHashable: Any]
        else { return nil }
        
        let imageUrl = metaData[.image] as? String
        let cardDescription = metaData[.cardDescription] as? String
        
        let messageHeader = extras[ContentCardKey.messageHeader.rawValue] as? String
        let messageTitle = extras[ContentCardKey.messageTitle.rawValue] as? String
        
        var webViewType: WebViewType = .none
        if let urlString = metaData[.urlString] as? String {
            webViewType = .url(urlString)
        } else if let htmlString = extras[ContentCardKey.html.rawValue] as? String {
            webViewType = .html(htmlString)
        } else if let contentBlockId = extras[ContentCardKey.contentBlock.rawValue] as? String {
            webViewType = .contentBlock(contentBlockId)
        }
        
        let contentCardData = ContentCardData(contentCardId: contentCardId, contentCardClassType: contentCardClassType, createdAt: createdAt, isDismissable: isDismissable)
        
        
        self.init(contentCardData: contentCardData, webViewType: webViewType, messageHeader: messageHeader, messageTitle: messageTitle, imageUrl: imageUrl, cardDescription: cardDescription)
    }
}

// MARK: - Full Page Message
///The object that is responsible for working with the `message_full_page` class_type from the Braze dashboard. When this message is clicked on in the Message Center, it will open to a scrollable view of content in a classic view.
struct FullPageMessage: Message {
    let contentCardData: ContentCardData?
    let messageHeader: String?
    let messageTitle: String?
    let imageUrl: String?
    let cardTitle: String?
    let cardDescription: String?
    let feedType: String?
    let urlString: String?
}

// MARK: - Content Card Initializer
extension FullPageMessage {
    init?(metaData: [ContentCardKey: Any], classType contentCardClassType: ContentCardClassType) {
        guard let contentCardId = metaData[.idString] as? String,
              let createdAt = metaData[.created] as? Double,
              let isDismissable = metaData[.dismissable] as? Bool,
              let extras = metaData[.extras] as? [AnyHashable: Any] else { return nil }
        
        let imageUrl = metaData[.image] as? String
        let cardTitle = metaData[.title] as? String
        let cardDescription = metaData[.cardDescription] as? String
        
        let messageHeader = extras[ContentCardKey.messageHeader.rawValue] as? String
        let messageTitle = extras[ContentCardKey.messageTitle.rawValue] as? String ?? cardTitle
        let urlString = metaData[.urlString] as? String
        
        var feedType: String?
        if extras.keys.contains("feed_type") {
            feedType = extras["feed_type"] as? String
        }
        
        let contentCardData = ContentCardData(contentCardId: contentCardId, contentCardClassType: contentCardClassType, createdAt: createdAt, isDismissable: isDismissable)
        
        self.init(contentCardData: contentCardData, messageHeader: messageHeader, messageTitle: messageTitle, imageUrl: imageUrl, cardTitle: cardTitle, cardDescription: cardDescription, feedType: feedType, urlString: urlString)
    }
}
