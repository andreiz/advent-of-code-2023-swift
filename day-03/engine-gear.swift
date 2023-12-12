import Foundation

// Define a struct to hold coordinates of a cell
struct Coords: Hashable {
    let row: Int
    let col: Int

    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
}

func readInputFile(_ inputFile: String) -> [[Character]]? {
    do {
        let fileContents = try String(contentsOfFile: inputFile)
        // return file contents as a 2D array of characters, skipping empty lines
        return fileContents.split(separator: "\n").map { Array($0) }
    } catch {
        print("Error reading from \(inputFile): \(error)")
        return nil
    }
}

// Define a function to access the character at a given position in
// the input array, with bounds checking
func getChar(_ data: [[Character]], _ row: Int, _ col: Int) -> Character? {
    if row < 0 || row >= data.count || col < 0 || col >= data[row].count {
        return nil
    }
    return data[row][col]
}

// Define a function called findNeighborStars that checks the cell's neighbors
// and returns a set of cells where stars are found
func findNeighborStars(_ data: [[Character]], _ row: Int, _ col: Int) -> Set<Coords> {
    // Define a data structure to access 8 neighbors of a cell.
    let neighbors = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1),
    ]
    var starCoords: Set<Coords> = []

    for (rowOffset, colOffset) in neighbors {
        if let char = getChar(data, row + rowOffset, col + colOffset), char == "*" {
            starCoords.insert(Coords(row + rowOffset, col + colOffset))
        }
    }
    return starCoords
}

// Ensure that exactly one command line argument (the input file) is provided.
guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}

if let data = readInputFile(CommandLine.arguments[1]) {
    // Define a dictionary to hold the star coordinates andthe numbersit is adjacent to
    var starNumbers: [Coords: [Int]] = [:]

    for row in 0 ..< data.count {
        var currentNumber = ""
        var starCoords: Set<Coords> = []

        for col in 0 ..< data[row].count {
            if let char = getChar(data, row, col), char.isNumber {
                currentNumber.append(char)
                // Add coordinates of any stars found to the set
                starCoords.formUnion(findNeighborStars(data, row, col))
            } else {
                if let number = Int(currentNumber), !starCoords.isEmpty {
                    for coord in starCoords {
                        starNumbers[coord, default: []].append(number)
                    }
                }
                currentNumber = ""
                starCoords = []
            }
        }
        // Check if line ends with a number
        if let number = Int(currentNumber), !starCoords.isEmpty {
            for coord in starCoords {
                starNumbers[coord, default: []].append(number)
            }
        }
    }

    // print out starNumbers info with coordinates sorted by row then column
    for (coords, numbers) in starNumbers.sorted(by: { $0.key.row == $1.key.row ? $0.key.col < $1.key.col : $0.key.row < $1.key.row }) {
        print("Star at (\(coords.row), \(coords.col)) is adjacent to \(numbers)")
    }

    let gearRatiosProduct = starNumbers
        .filter { $1.count == 2 } // only consider stars adjacent to exactly 2 numbers
        .map { $1.reduce(1, *) } // multiply the 2 numbers together
        .reduce(0, +) // sum the products

    print(gearRatiosProduct)
}
