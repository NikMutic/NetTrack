//
//  Interface.swift
//  NetTrack
//
//  Created by Nikola Mutic on 18/4/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Interface: NSObject {
    @DocumentID var id: String?
    var device: Device?
    var name: String?
}
