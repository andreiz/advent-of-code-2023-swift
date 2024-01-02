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

// Main execution
guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}

let filename = CommandLine.arguments[1]
if let result = parseInputFile(filename: filename) {
    var ways = [Int]()
    for (time, distance) in result {
        // ways.append((0 ... time).filter { $0 * (time - $0) > distance }.count)
        let mid = (time + 1) / 2
        let isRangeOdd = (time + 1) % 2 == 1
        var count = 0

        for x in mid ... time {
            if x * (time - x) > distance {
                count += isRangeOdd && x == mid ? 1 : 2
            } else {
                break
            }
        }
        ways.append(count)
        print("\(ways)")
    }

    print(ways.reduce(1, *))
}
