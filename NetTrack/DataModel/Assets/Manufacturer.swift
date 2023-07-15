//
//  Manufacturer.swift
//  NetTrack
//
//  Created by Nikola Mutic on 18/4/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Manufacturer: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
}
