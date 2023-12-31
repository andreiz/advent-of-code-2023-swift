import Foundation

struct Mapping {
    var range: Range<Int>
    var offset: Int

    init(outputStart: Int, inputStart: Int, length: Int) {
        range = inputStart ..< inputStart + length
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

    func mapValue(_ input: Int) -> Int {
        for mapping in mappings {
            if mapping.range.contains(input) {
                return input + mapping.offset
            }
        }
        return input
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
// for mapper in mappers {
//     // transform mappings into a more readable format after sorting by the range
//     let mappings = mapper.mappings
//         .sorted { $0.range.lowerBound < $1.range.lowerBound }
//         .map { mapping in
//             "\(mapping.range.lowerBound) - \(mapping.range.upperBound - 1) (\(mapping.offset))"
//         }
//     print("\(mapper.name):\n\(mappings.joined(separator: "\n"))")
// }

let outputs = seeds.map { input in
    mappers.reduce(input) { currentOutput, mapper in
        mapper.mapValue(currentOutput)
    }
}

print("Minimum location: \(outputs.min()!)")
