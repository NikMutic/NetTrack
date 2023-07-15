//
//  Rack.swift
//  NetTrack
//
//  Created by Nikola Mutic on 18/4/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Rack: NSObject, Decodable {
    @DocumentID var id: String?
    var name: String?
    var locationId: String?
    var siteId: String?
}
