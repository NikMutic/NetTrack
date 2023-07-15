//
//  Location.swift
//  NetTrack
//
//  Created by Nikola Mutic on 18/4/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Location: NSObject, Decodable {
    @DocumentID var id: String?
    var siteId: String?
    var name: String?
    var notes: String?
}
