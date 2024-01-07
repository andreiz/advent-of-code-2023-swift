import Foundation

func allElementsAreEqual<T: Equatable>(_ array: [T]) -> Bool {
    guard let firstElement = array.first else { return true } // Empty array is considered to have all equal elements
    return array.allSatisfy { $0 == firstElement }
}

func calculateDifferences(_ input: [Int]) -> [[Int]] {
    var result = [input]
    var currentSequence = input

    while true {
        let newSequence = zip(currentSequence, currentSequence.dropFirst()).map { $1 - $0 }
        result.append(newSequence)
        if allElementsAreEqual(newSequence) {
            break
        }
        currentSequence = newSequence
    }
    return result
}

let input = try! String(contentsOfFile: CommandLine.arguments[1])
    .split(separator: "\n")
    .map { $0.split(separator: " ").map { Int($0)! } }

var sumLast = 0
var sumFirst = 0
for line in input {
    let differences = calculateDifferences(line)
    let lastValue = differences.reduce(0) { current, sequence in
        current + (sequence.last ?? 0)
    }
    let firstValue = differences.reversed().reduce(0) { current, sequence in
        -current + (sequence.first ?? 0)
    }
    print("lastValue: \(lastValue)")
    print("firstValue: \(firstValue)")
    sumLast += lastValue
    sumFirst += firstValue
}

print("Part 1: \(sumLast)")
print("Part 2: \(sumFirst)")
