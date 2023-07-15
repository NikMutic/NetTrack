//
//  Status.swift
//  NetTrack
//
//  Created by Nikola Mutic on 8/5/2023.
//

import Foundation

enum Status: String, Decodable {
    case Active
    case Reserved
    case Depreciated
}

enum PrefixStatus: String, Decodable {
    case Container
    case Active
    case Reserved
    case Depreciated
}
