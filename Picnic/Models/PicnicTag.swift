//
//  PicnicTag.swift
//  Picnic
//
//  Created by Kyle Burns on 10/10/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation

enum PicnicTag: String, Codable, CaseIterable {
    case trail
    case waterfall
    case lake
    case river
    case kidFriendly
    case wheelchairAccessible
    case walking
    case hiking
    case running
    case forest
    case view
    case bugs
    case overgrown
    case wildflowers
    case wildlife
    case mountainBiking
    case rocky
    case paved
    case roadBiking
    case petFriendly
    case secluded
    case localSecret
    case park
    
    var prettyString: String {
        switch self {
        case .trail: return "Trail"
        case .waterfall: return "Waterfall"
        case .lake: return "Lake"
        case .river: return "River"
        case .kidFriendly: return "Kid-Friendly"
        case .wheelchairAccessible: return "Wheelchair-Accessible"
        case .walking: return "Walking"
        case .hiking: return "Hiking"
        case .running: return "Running"
        case .forest: return "Forest"
        case .view: return "View"
        case .bugs: return "Bugs"
        case .overgrown: return "Overgrown"
        case .wildflowers: return "Wildflowers"
        case .wildlife: return "Wildlife"
        case .mountainBiking: return "Mountain biking"
        case .rocky: return "Rocky"
        case .paved: return "Paved"
        case .roadBiking: return "Road biking"
        case .petFriendly: return "Pet friendly"
        case .secluded: return "Secluded"
        case .localSecret: return "Local secret"
        case .park: return "Park"
        }
    }
    
    var keyPath: WritableKeyPath<TagContainer, Bool> {
        switch self {
        case .trail: return \.trail
        case .waterfall: return \.waterfall
        case .lake: return \.lake
        case .river: return \.river
        case .kidFriendly: return \.kidFriendly
        case .wheelchairAccessible: return \.wheelchairAccessible
        case .walking: return \.walking
        case .hiking: return \.hiking
        case .running: return \.running
        case .forest: return \.forest
        case .view: return \.view
        case .bugs: return \.bugs
        case .overgrown: return \.overgrown
        case .wildflowers: return \.wildflowers
        case .wildlife: return \.wildlife
        case .mountainBiking: return \.mountainBiking
        case .rocky: return \.rocky
        case .paved: return \.paved
        case .roadBiking: return \.roadBiking
        case .petFriendly: return \.petFriendly
        case .secluded: return \.secluded
        case .localSecret: return \.localSecret
        case .park: return \.park
        }
    }
}
