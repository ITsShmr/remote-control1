import Foundation

extension Data {
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }

    func subdata(safe range: Range<Int>) -> Data? {
        guard range.lowerBound >= 0,
              range.upperBound <= count else { return nil }
        return subdata(in: range)
    }
}
