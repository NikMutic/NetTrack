//
//  Vlan.swift
//  NetTrack
//
//  Created by Nikola Mutic on 8/5/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Vlan: NSObject, Decodable {
    @DocumentID var id: String?
    var vlanId: Int?
    var name: String?
    var status: Status?
}
