import Foundation

func parseInputFile(filename: String) -> [(Int, Int)]? {
    do {
        let content = try String(contentsOfFile: filename, encoding: .utf8)
        let lines = content.split(separator: "\n")
        guard lines.count == 2 else {
            print("Invalid input format")
            return []
        }

        let timeNumbers = lines[0].split(separator: " ").compactMap { Int($0) }
        let distanceNumbers = lines[1].split(separator: " ").compactMap { Int($0) }

        guard timeNumbers.count == distanceNumbers.count else {
            print("Mismatched number of times and distances")
            return []
        }

        return Array(zip(timeNumbers, distanceNumbers))
    } catch {
        print("Error reading file \(filename)")
        return nil
    }
}

func solveQuadratic(time: Int, distance: Int) -> (Double?, Double?) {
    let a: Double = -1
    let b = Double(time)
    let c = Double(-distance)

    let discriminant = b * b - 4 * a * c

    if discriminant < 0 {
        // No real solutions
        return (nil, nil)
    } else {
        let x1 = (-b + sqrt(discriminant)) / (2 * a)
        let x2 = (-b - sqrt(discriminant)) / (2 * a)
        return (x1, x2)
    }
}

// Main execution
guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}

let filename = CommandLine.arguments[1]
if let result = parseInputFile(filename: filename) {
    var ways = [Int]()

    for (time, distance) in result {
        let (solution1, solution2) = solveQuadratic(time: time, distance: distance)
        if let x1 = solution1, let x2 = solution2, x1 > 0, x2 > 0 {
            let x1Int = x1 == floor(x1) ? Int(x1) + 1 : Int(x1.rounded(.up))
            let x2Int = x2 == floor(x2) ? Int(x2) - 1 : Int(x2.rounded(.down))
            ways.append(x2Int - x1Int + 1)
        }
    }
    print(ways.reduce(1, *))
}
