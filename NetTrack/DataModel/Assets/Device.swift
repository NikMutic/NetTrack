//
//  Device.swift
//  NetTrack
//
//  Created by Nikola Mutic on 18/4/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Device: NSObject, Decodable {
    @DocumentID var id: String?
    var name: String?
    var serialNumber: String?
    var mac: String?
    var notes: String?
    var deviceTypeId: String?
    var siteId: String?
    var locationId: String?
    var rackId: String?
    var inStorage: Bool?
    // var userID: String?
}
