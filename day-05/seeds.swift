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
    // Initialize an empty array to hold Mapper objects.
    var mappers: [Mapper] = []

    // Split the input string into parts, each part separated by two newlines.
    let parts = input.split(separator: "\n\n")

    // Process the first part to extract seed values. Skip the first word ("seeds:")
    // and convert the remaining strings to integers.
    let seeds = parts[0].split(separator: " ").dropFirst().compactMap { Int($0) }

    // Process the remaining parts to create Mapper objects.
    mappers = parts.dropFirst().map { chunk -> Mapper in
        // Extract the name of the mapper from the first line of each chunk.
        let name = chunk.split(separator: "\n").first!.split(separator: " ").first!

        // Process each subsequent line in the chunk to create Mapping objects.
        // Each line represents a set of numbers defining a Mapping.
        let mappings = chunk.split(separator: "\n").dropFirst().compactMap { line -> Mapping? in
            let numbers = line.split(separator: " ").compactMap { Int($0) }
            return Mapping(outputStart: numbers[0], inputStart: numbers[1], length: numbers[2])
        }

        // Create a Mapper object with the extracted name and the array of Mappings.
        return Mapper(name: String(name), mappings: mappings)
    }

    // Return a tuple containing the array of seeds and the array of Mappers.
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
