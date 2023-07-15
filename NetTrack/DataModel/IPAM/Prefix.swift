//
//  Prefix.swift
//  NetTrack
//
//  Created by Nikola Mutic on 8/5/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Prefix: NSObject, Decodable {
    var prefix: String?
    var status: String? // PrefixStatus
    var roleId: String?
    var siteId: String?
    var vlanId: String?
    var children: [Prefix] = []
}
