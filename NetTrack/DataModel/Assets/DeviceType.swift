//
//  DeviceType.swift
//  NetTrack
//
//  Created by Nikola Mutic on 18/4/2023.
//

import Foundation
import FirebaseFirestoreSwift

class DeviceType: NSObject, Decodable {
    @DocumentID var id: String?
    var manufacturerId: String?
    var model: String?
}
