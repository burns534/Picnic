//
//  Geohash.swift
//  Picnic

import CoreLocation

//private let charmap = Array("0123456789bcdefghjkmnpqrstuvwxyz")

private extension String {
    init(integer n: Int, radix: Int, padding: Int) {
        let s = String(n, radix: radix)
        let pad = (padding - s.count % padding) % padding
        self = Array(repeating: "0", count: pad).joined(separator: "") + s
    }
}

private func + (left: [String], right: String) -> [String] {
    var arr = left
    arr.append(right)
    return arr
}

private func << (left: [String], right: String) -> [String] {
    var arr = left
    var s = arr.popLast()!
    s += right
    arr.append(s)
    return arr
}

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
    public let precision: Precision?
    
    public static func decode(hash: String) -> (latitude: (min: Double, max: Double), longitude: (min: Double, max: Double))? {
        
        let bits = hash.map { bitmap[$0] ?? "?" }.joined(separator: "")
        guard bits.count % 5 == 0 else { return nil }
        
        let (lat, lon) = bits.enumerated().reduce(into: ([Character](), [Character]())) {
            if $1.0 % 2 == 0 {
                $0.1.append($1.1)
            } else {
                $0.0.append($1.1)
            }
        }
        
        func combiner(array a: (min: Double, max: Double), value: Character) -> (Double, Double) {
            let mean = (a.min + a.max) / 2
            return value == "1" ? (mean, a.max) : (a.min, mean)
        }

        let latRange = lat.reduce((-90.0, 90.0), combiner)
        let lonRange = lon.reduce((-180.0, 180.0), combiner)
        return (latRange, lonRange)
    }
    
    public static func encode(latitude: Double, longitude: Double, length: Int) -> String {
        
        func combiner(array a: (min: Double, max: Double, array: [String]), value: Double) -> (Double, Double, [String]) {
            let mean = (a.min + a.max) / 2
            if value < mean {
                return (a.min, mean, a.array + "0")
            } else {
                return (mean, a.max, a.array + "1")
            }
        }

        let lat = Array(repeating: latitude, count: length*5).reduce((-90.0, 90.0, [String]()), combiner)
        let lon = Array(repeating: longitude, count: length*5).reduce((-180.0, 180.0, [String]()), combiner)
        let latlon = lon.2.enumerated().flatMap { [$1, lat.2[$0]] }

        let bits = latlon.enumerated().reduce([String]()) { $1.0 % 5 > 0 ? $0 << $1.1 : $0 + $1.1 }
        let arr = bits.compactMap { charmap[$0] }
        return String(arr.prefix(length))
    }
    
    // MARK: Private
    private static let bitmap = "0123456789bcdefghjkmnpqrstuvwxyz".enumerated()
        .map {
            ($1, String(integer: $0, radix: 2, padding: 5))
        }
        .reduce(into: [Character: String]()) {
            $0[$1.0] = $1.1
    }

    private static let charmap = bitmap
        .reduce(into: [String: Character]()) {
            $0[$1.1] = $1.0
    }
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
        let hash = Region.encode(latitude: latitude, longitude: longitude, length: precision)
        let data = Region.decode(hash: hash)!
        let width = Span(min: data.longitude.min, max: data.longitude.max)
        let height = Span(min: data.latitude.min, max: data.latitude.max)
        self = Region(width: width, height: height, hash: hash, precision: Precision(rawValue: precision))
    }
    
    public init?(hash: String) {
        guard let data = Region.decode(hash: hash) else { return nil }
        let width = Span(min: data.longitude.min, max: data.longitude.max)
        let height = Span(min: data.latitude.min, max: data.latitude.max)
        self = Region(width: width, height: height, hash: hash, precision: Precision(rawValue: hash.count))
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

extension Region {
    /**
     Converts supplied radius to associated precision value such that a point in a region of this precision would have a (threshold) chance of having greater than (radius) distance from any given edge of the region.
     - parameters:
     - radius: Measured in kilometers
     - threshold: Percentage chance the query won't go outside the region
     */
    static func radiusToPrecision(radius: Double, threshold: Double) -> Precision {
        let radiusInMeters = radius * 1000.0
        for precision in Precision.allCases.reversed() {
            if precision.margin > 8 * radiusInMeters {
                print("called radiusToPrecision: radius: \(radiusInMeters), returning \(precision.rawValue)")
                return precision
            }
        }
        return .sixHundredThirtyKilometers
    }
}

public let kDefaultPrecision = 9

public enum Precision: Int, CaseIterable {

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
        case .sixHundredThirtyKilometers: return 630_000.0
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

#if canImport(CoreLocation)

    import CoreLocation

    extension Region {

        init(coordinate: CLLocationCoordinate2D, precision: Int = kDefaultPrecision) {
            self = Region(latitude: coordinate.latitude, longitude: coordinate.longitude, precision: precision)
        }

        init(location: CLLocation, precision: Int = kDefaultPrecision) {
            self = Region(coordinate: location.coordinate, precision: precision)
        }
        /**
         Creates appropriate region with precision corresponding to radius (km)
        - parameters:
            - radius: measured in kilometers
            - location: query location center
         */
        init(location: CLLocation, radius: Double) {
            self = Region(coordinate: location.coordinate, precision: Region.radiusToPrecision(radius: radius, threshold: 0.8).rawValue)
        }
        /**
         Generates the smallest hash containing all points within the query radius
         - parameters:
         - radius: measured in kilometers
         - location: the center of the query circle
         */
        public static func hashForRadius(location: CLLocation, radius: Double) -> String {
            let radiusLatitude = radius / 111.0
            let radiusLongitude = radius / (cos(radiusLatitude * Double.pi / 180.0) * 111.0)
            let coordinate = location.coordinate
            let cornerHashes = [
                Region.encode(latitude: coordinate.latitude + radiusLatitude, longitude: coordinate.longitude - radiusLongitude, length: 10),
                Region.encode(latitude: coordinate.latitude + radiusLatitude, longitude: coordinate.longitude + radiusLongitude, length: 10),
                Region.encode(latitude: coordinate.latitude - radiusLatitude, longitude: coordinate.longitude - radiusLongitude, length: 10),
                Region.encode(latitude: coordinate.latitude - radiusLatitude, longitude: coordinate.longitude + radiusLongitude, length: 10)
            ]
            
            var minimumBoundingHash: String = location.geohash()[0]
            for i in 1...10 {
                let prefix = cornerHashes[0].prefix(i)
                for corner in cornerHashes {
                    if !corner.hasPrefix(prefix) {
                        return minimumBoundingHash
                    }
                }
                minimumBoundingHash = String(prefix)
            }
            return minimumBoundingHash
        }
        
// MARK: Might use this later to provide more specific hashes
        private static let even: [[String]] = [
            ["p", "r", "x", "z"],
            ["n", "q", "w", "y"],
            ["j", "m", "t", "v"],
            ["h", "k", "s", "u"],
            ["5", "7", "e", "g"],
            ["4", "6", "d", "f"],
            ["1", "3", "9", "c"],
            ["0", "2", "8", "b"]
        ]
        
        private static let odd: [[String]] = even.transposed()
        
        /**
         Returns regions containing possible locations within a radius(km) of the location
         */
        
        func queryRegions(location: CLLocation, radius: Double) -> [Region] {
            guard let precision = precision else { return [self] }
            var result = [self]
            let radiusLatitude = radius / 111.0
            let radiusLongitude = radius / (cos(radiusLatitude * Double.pi / 180.0) * 111.0)
            print("queryRegions called with coordinate: (\(location.coordinate.latitude), \(location.coordinate.longitude))\nwidth: (\(width.min), \(width.max))\nradius: \(radius)\noffset: (\(radiusLatitude), \(radiusLongitude))")
            if location.coordinate.longitude < width.min + radiusLongitude {
                result.append(west(self, precision.rawValue))
                
                if location.coordinate.latitude > height.max - radiusLatitude {
                    result.append(northwest(self, precision.rawValue))
                }
                if location.coordinate.latitude < height.min + radiusLatitude {
                    result.append(southwest(self, precision.rawValue))
                }
            }
            if location.coordinate.longitude > width.max - radiusLongitude {
                result.append(east(self, precision.rawValue))
                
                if location.coordinate.latitude > height.max - radiusLatitude {
                    result.append(northeast(self, precision.rawValue))
                }
                if location.coordinate.latitude < height.min + radiusLatitude {
                    result.append(southeast(self, precision.rawValue))
                }
            }
            if location.coordinate.latitude > height.max - radiusLatitude {
                result.append(north(self, precision.rawValue))
            }
            if location.coordinate.latitude < height.min + radiusLatitude {
                result.append(south(self, precision.rawValue))
            }
            return result
        }
    }

    extension CLLocationCoordinate2D {

        init(geohash: String) {
            if let (lat, lon) = Region.decode(hash: geohash) {
                self = CLLocationCoordinate2DMake((lat.min + lat.max) / 2, (lon.min + lon.max) / 2)
            } else {
                self = CLLocationCoordinate2D()
            }
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
