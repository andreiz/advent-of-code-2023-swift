import Foundation

struct Mapping {
    var range: NSRange
    var offset: Int

    init(outputStart: Int, inputStart: Int, length: Int) {
        range = NSRange(inputStart ..< inputStart + length)
        offset = outputStart - inputStart
    }
}

struct Mapper {
    var name: String
    var mappings: [Mapping]

    init(name: String, mappings: [Mapping]) {
        self.name = name
        self.mappings = mappings
    }

    func processRanges(_ input: [NSRange]) -> [NSRange] {
        var output = [NSRange]()

        for range in input {
            var currentPieces = [range] // Start with the current range as the initial piece

            // Iterate through each range mapping
            for rangeMapping in mappings {
                for (index, currentPiece) in currentPieces.enumerated() {
                    // Check for an intersection between the current piece and the mapping's range
                    if let (intersection, remainingPieces) = splitRanges(input: currentPiece, with: rangeMapping.range) {
                        // Calculate and add the shifted intersection range to the output based on the mapping offset
                        let shiftedIntersection = NSMakeRange(intersection.location + rangeMapping.offset, intersection.length)
                        output.append(shiftedIntersection)

                        // Remove the current piece (intersection) and add the remaining pieces
                        // to be processed by the next mapping
                        currentPieces.remove(at: index)
                        currentPieces.append(contentsOf: remainingPieces)

                        // Exit the loop since a single mapping can only intersect with one range
                        break
                    }
                }
            }

            // Any remaining pieces are disjoint from all mappings, so add them to the output
            output += currentPieces
        }

        // Return after merging overlapping or adjacent ranges in the output
        return mergeRanges(output)
    }

    func splitRanges(input: NSRange, with other: NSRange) -> (NSRange, [NSRange])? {
        var remainders = [NSRange]()

        // Calculate the intersection
        guard let intersection = input.intersection(other), intersection.length > 0 else {
            return nil
        }

        // Add the range before the intersection, if it exists
        if input.location < intersection.location {
            remainders.append(NSRange(location: input.location, length: intersection.location - input.location))
        }

        // Add the range after the intersection, if it exists
        let endOfIntersection = intersection.location + intersection.length
        let endOfInput = input.location + input.length
        if endOfIntersection < endOfInput {
            remainders.append(NSRange(location: endOfIntersection, length: endOfInput - endOfIntersection))
        }

        return (intersection, remainders)
    }

    func mergeRanges(_ ranges: [NSRange]) -> [NSRange] {
        // Sort ranges by their start location
        let sortedRanges = ranges.sorted { $0.location < $1.location }

        var mergedRanges = [NSRange]()
        var currentRange = sortedRanges.first

        // If there are no ranges, return an empty array
        if currentRange == nil {
            return []
        }

        for range in sortedRanges.dropFirst() {
            // Check if the current range overlaps or is adjacent to the next range
            if currentRange!.location + currentRange!.length >= range.location {
                // Union the current range with the next range
                currentRange = NSUnionRange(currentRange!, range)
            } else {
                // Append the current range and move to the next
                mergedRanges.append(currentRange!)
                currentRange = range
            }
        }

        // Add the last range
        mergedRanges.append(currentRange!)

        return mergedRanges
    }
}

func processInput(input: String) -> ([Int], [Mapper]) {
    var seeds: [Int] = []
    var mappers: [Mapper] = []
    var currentMappings: [Mapping] = []
    var currentMapName = ""

    let lines = input.split(separator: "\n", omittingEmptySubsequences: false)

    for line in lines {
        if line.hasPrefix("seeds:") {
            seeds = line.split(separator: " ")
                .dropFirst()
                .compactMap { Int($0) }
        } else if line.hasSuffix("map:") {
            currentMapName = String(line.split(separator: ":")[0])
        } else if line.isEmpty {
            if !currentMappings.isEmpty {
                mappers.append(Mapper(name: currentMapName, mappings: currentMappings))
                currentMappings = []
            }
            currentMapName = ""
        } else if !currentMapName.isEmpty {
            let numbers = line.split(separator: " ").compactMap { Int($0) }
            if numbers.count == 3 {
                let mapping = Mapping(outputStart: numbers[0], inputStart: numbers[1], length: numbers[2])
                currentMappings.append(mapping)
            }
        }
    }

    // Add the last mapper if there are any remaining mappings
    if !currentMappings.isEmpty {
        mappers.append(Mapper(name: currentMapName, mappings: currentMappings))
    }

    return (seeds, mappers)
}

guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}

guard let contents = try? String(contentsOfFile: CommandLine.arguments[1]) else {
    print("Error reading from \(CommandLine.arguments[1])")
    exit(1)
}

let (seeds, mappers) = processInput(input: contents)
// Convert seeds to ranges, treating each pair of numbers as a range
var ranges = [NSRange]()
for i in stride(from: 0, to: seeds.count, by: 2) {
    ranges.append(NSRange(location: seeds[i], length: seeds[i + 1]))
}

for mapper in mappers {
    print("Processing \(mapper.name)")
    ranges = mapper.processRanges(ranges)
}

// find the lowest location
let lowestLocation = ranges.reduce(Int.max) { min($0, $1.location) }
print("Lowest location: \(lowestLocation)")
