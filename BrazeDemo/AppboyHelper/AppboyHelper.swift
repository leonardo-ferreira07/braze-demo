//
//  AppboyHelper.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 01/12/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit
import UserNotifications
import AppboyKit

enum AppboyDictionaryKey: String {
    case root = "ab"
    case attachment = "att"
    case attachmentUrl = "url"
    case abLink = "ab_uri"
    case attachmentType = "type"
    case messageContent = "aps"
    case alert = "alert"
    case badge = "badge"
    case category = "category"
    case academyId = "academy_id"
    case courseId = "course_id"
    case chapterId = "chapterId"
    case imageUrl = "image_url"
}

// MARK: - App Methods

struct AppboyHelper {

    static func setup(inApplication application: UIApplication, withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        Appboy.start(withApiKey: "",
                     in: application,
                     withLaunchOptions: launchOptions,
                     withAppboyOptions: [ ABKSessionTimeoutKey: 1800 ]) // session time
        
        AppboyHelper.setUser(withEmail: "leonardo@mindvalley.com", firstName: "Leonardo", lastName: "Kaminski", externalId: "1894dsadasd4784", language: "en", callback: nil)
    }

    static func setUser(withEmail email: String?, firstName: String?, lastName: String?, externalId: String?, language: String?, callback: ((_ granted: Bool, _ errorMessage: String?) -> Void)?) {

        guard let email = email, let externalId = externalId else {
            callback?(false, nil)
            return
        }
        
        Appboy.sharedInstance()?.user.firstName = firstName
        Appboy.sharedInstance()?.user.lastName = lastName
        Appboy.sharedInstance()?.user.email = email
        Appboy.sharedInstance()?.user.language = language
        Appboy.sharedInstance()?.changeUser(externalId)
    }

}
