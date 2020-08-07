//
//  Geohash.swift
//  Picnic

import CoreLocation

private let charmap = Array("0123456789bcdefghjkmnpqrstuvwxyz")

public struct Span {
    public let min: Double
    public let max: Double
}

extension Span {
    public var mean: Double { (min + max) / 2 }
    public var distance: Double { max - min }
    
    static let latitude = Span(min: -90.0, max: 90.0)
    static let longitude = Span(min: -180.0, max: 180.0)
}

public struct Region {
    public let width: Span
    public let height: Span
    public let hash: String
}

extension Region {

    public var center: (latitude: Double, longitude: Double) {
        return (height.mean, width.mean)
    }

    public var size: (width: Double, height: Double) {
        return (width.distance, height.distance)
    }

    public init(latitude: Double, longitude: Double, precision: Int) {

        var lat = Span.latitude
        var lng = Span.longitude

        var hash: Array<Character> = []
        var parity = Parity.lng
        var char = 0
        var count = 0

        func inc() {
            let mask = 0b10000 >> count
            char |= mask
        }

        func compare(span: Span, source: Double) -> Span {
            let mean = span.mean
            let isLow = source < mean
            let (min, max) = isLow ? (span.min, mean) : (mean, span.max)
            if !isLow { inc() }
            return Span(min: min, max: max)
        }

        repeat {
            switch parity {
            case .lng: lng = compare(span: lng, source: longitude)
            case .lat: lat = compare(span: lat, source: latitude)
            }
            parity.flip()
            count += 1
            if count == 5 {
                hash.append(charmap[char])
                count = 0
                char = 0
            }

        } while hash.count < precision

        let height = Span(min: lat.min, max: lat.max)
        let width = Span(min: lng.min, max: lng.min)

        self = Region(width: width, height: height, hash: String(hash))

    }

    public init?(hash: String) {

        var lat = Span.latitude
        var lng = Span.longitude

        var parity = Parity.lng

        for char in hash {
            guard let bitmap = charmap.firstIndex(of: char) else { return nil }
            var mask = 0b10000

            func compare(span: Span) -> Span {
                let mean = span.mean
                let isLow = bitmap & mask == 0
                let (min, max) = isLow ? (span.min, mean) : (mean, span.max)
                return Span(min: min, max: max)
            }

            while mask != 0 {
                switch parity {
                case .lng: lng = compare(span: lng)
                case .lat: lat = compare(span: lat)
                }
                parity.flip()
                mask >>= 1
            }
        }
        self = Region(width: lng, height: lat, hash: hash)
    }

    func north(_ region: Region, _ precision: Int) -> Region {
        let lat = region.center.latitude
        let lng = region.center.longitude
        let v = region.height.distance
        let northCenter = lat + v
        if northCenter > 90.0 {
            let k = lng > 0 ? lng - 180.0 : lng + 180.0
            return Region(latitude: lat, longitude: k, precision: precision)
        }
        return Region(latitude: northCenter, longitude: lng, precision: precision)
    }

    func south(_ region: Region, _ precision: Int) -> Region {
        let lat = region.center.latitude
        let lng = region.center.longitude
        let v = region.height.distance
        let southCenter = lat - v
        if southCenter < -90.0 {
            let k = lng < 0 ? lng + 180.0 : lng - 180.0
            return Region(latitude: lat, longitude: k, precision: precision)
        }
        return Region(latitude: southCenter, longitude: lng, precision: precision)
    }
    
    func east(_ region: Region, _ precision: Int) -> Region {
        let lat = region.center.latitude
        let lng = region.center.longitude
        let h = region.width.distance
        var eastCenter = lng + h
        if eastCenter > 180.0 { eastCenter -= 360.0 }
        return Region(latitude: lat, longitude: eastCenter, precision: precision)
    }

    func west(_ region: Region, _ precision: Int) -> Region {
        let lat = region.center.latitude
        let lng = region.center.longitude
        let h = region.width.distance
        var westCenter = lng - h
        if westCenter < -180.0 { westCenter += 360.0 }
        return Region(latitude: lat, longitude: westCenter, precision: precision)
    }

    func northeast(_ region: Region, _ precision: Int) -> Region {
        return north(east(region, precision), precision)
    }

    func southeast(_ region: Region, _ precision: Int) -> Region {
        return south(east(self, precision), precision)
    }

    func southwest(_ region: Region, _ precision: Int) -> Region {
        return south(west(self, precision), precision)
    }

    func northwest(_ region: Region, _ precision: Int) -> Region {
        return north(west(self, precision), precision)
    }
// I don't think I like this
    public func neighbors() -> [Region] {
        let precision = hash.count
        return [
            north(self, precision),
            northeast(self, precision),
            east(self, precision),
            southeast(self, precision),
            south(self, precision),
            southwest(self, precision),
            west(self, precision),
            northwest(self, precision)
        ]
    }

    private enum Parity {
        case lng
        case lat
        mutating func flip() {
            switch self {
            case .lng: self = .lat
            case .lat: self = .lng
            }
        }
    }
}
