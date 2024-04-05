import Foundation

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Float {
    func toDegrees() -> Float {
        self * 180 / .pi
    }
}
