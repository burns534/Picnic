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

    public var center: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: height.mean, longitude: width.mean)
    }
    
    public var size: (width: Double, height: Double) {
        return (width.distance, height.distance)
    }
    
    public init(location: CLLocationCoordinate2D, precision: Int) {
        self.init(latitude: location.latitude, longitude: location.longitude, precision: precision)
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

public let kDefaultPrecision = 9

public enum Precision: Int {

    /// ±2500 km
    case twentyFiveHundredKilometers = 1

    /// ±630 km
    case sixHundredThirtyKilometers = 2

    /// ±78 km
    case seventyEightKilometers = 3

    /// ±20 km
    case twentyKilometers = 4

    /// ±2.4 km, ±2400 m
    case twentyFourHundredMeters = 5

    /// ±0.61 km, ±610 m
    case sixHundredTenMeters = 6

    /// ±0.076 km, ±76 m
    case seventySixMeters = 7

    /// ±0.019 km, ±19 m
    case nineteenMeters = 8

    /// ±0.0024 km, ±2.4 m, ±240 cm
    case twoHundredFortyCentimeters = 9

    /// ±0.00060 km, ±0.6 m, ±60 cm
    case sixtyCentimeters = 10

    /// ±0.000074 km, ±0.07 m, ±7.4 cm, ±74 mm
    case seventyFourMillimeters = 11

    var margin: Double {
        switch self {
        case .twentyFiveHundredKilometers: return 2_500_000.0
        case .sixHundredThirtyKilometers: return 610_000.0
        case .seventyEightKilometers: return 78_000.0
        case .twentyKilometers: return 20_000.0
        case .twentyFourHundredMeters: return 2_400.0
        case .sixHundredTenMeters: return 610.0
        case .seventySixMeters: return 76.0
        case .nineteenMeters: return 19.0
        case .twoHundredFortyCentimeters: return 2.4
        case .sixtyCentimeters: return 0.6
        case .seventyFourMillimeters: return 0.07
        }
    }
}

#if os(OSX) || os(iOS)

    import CoreLocation

    extension Region {

        init(coordinate: CLLocationCoordinate2D, precision: Int = kDefaultPrecision) {
            self = Region(latitude: coordinate.latitude, longitude: coordinate.longitude, precision: precision)
        }

        init(location: CLLocation, precision: Int = kDefaultPrecision) {
            self = Region(coordinate: location.coordinate, precision: precision)
        }

    }

    extension CLLocationCoordinate2D {

        public init(geohash: String) {
            guard let region = Region(hash: geohash) else {
                self = kCLLocationCoordinate2DInvalid
                return
            }
            self = region.center
        }

        public func geohash(precision: Int = kDefaultPrecision) -> String {
            Region(coordinate: self, precision: precision).hash
        }

        public func geohash(precision: Precision) -> String {
            Region(coordinate: self, precision: precision.rawValue).hash
        }
        
        /// Geohash neighbors
        public func neighbors(precision: Int = kDefaultPrecision) -> [String] {
            Region(coordinate: self, precision: precision).neighbors().map { $0.hash }
        }
        
        public func neighbors(precision: Precision) -> [String] {
            neighbors(precision: precision.rawValue)
        }

    }

    extension CLLocation {

        public convenience init?(geohash: String) {
            guard let region = Region.init(hash: geohash) else { return nil }
            self.init(latitude: region.center.latitude, longitude: region.center.longitude)
        }

        public func geohash(precision: Int = kDefaultPrecision) -> String {
            return Region(coordinate: self.coordinate, precision: precision).hash
        }

        public func geohash(precision: Precision) -> String {
            return geohash(precision: precision.rawValue)
        }

        /// Geohash neighbors
        public func neighbors(precision: Int = kDefaultPrecision) -> [String] {
            return Region.init(location: self, precision: precision).neighbors().map { $0.hash }
        }

        public func neighbors(precision: Precision) -> [String] {
            return neighbors(precision: precision.rawValue)
        }

    }

#endif
