import Foundation

extension Int {
    init(_ range: Range<Int>) {
        let delta = range.startIndex < 0 ? abs(range.startIndex) : 0
        let min = UInt32(range.startIndex + delta)
        let max = UInt32(range.endIndex + delta)
        self.init(Int(min + arc4random_uniform(max - min)) - delta)
    }

    static func randomize(digits: Int) -> Int {
        let min = Int(pow(Double(10), Double(digits - 1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range<Int>(min...max))
    }
}

func measureExecutionTime<T>(_ block: () -> T) -> (T, Double) {
    let startTime = DispatchTime.now()
    let result = block()
    let endTime = DispatchTime.now()
    let executionTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) /
        1_000_000 // Convert nanoseconds to milliseconds
    return (result, executionTime)
}
