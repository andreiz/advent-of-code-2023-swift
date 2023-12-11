import Foundation

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

// Define a function to check neighbors of a cell for anything
// not a digit or a period
func checkNeighborsForSymbols(_ data: [[Character]], _ row: Int, _ col: Int) -> Bool {
    // Define a data structure to access 8 neighbors of a cell.
    let neighbors = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1),
    ]

    for (rowOffset, colOffset) in neighbors {
        if let char = getChar(data, row + rowOffset, col + colOffset), !(char.isNumber || char == ".") {
            return true
        }
    }
    return false
}

// Ensure that exactly one command line argument (the input file) is provided.
guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}

if let data = readInputFile(CommandLine.arguments[1]) {
    var numbers: [Int] = []

    for row in 0 ..< data.count {
        var currentNumber = ""
        var haveSymbolNeighbor = false

        for col in 0 ..< data[row].count {
            if let char = getChar(data, row, col), char.isNumber {
                currentNumber.append(char)
                if checkNeighborsForSymbols(data, row, col) {
                    haveSymbolNeighbor = true
                }
            } else {
                if let number = Int(currentNumber), haveSymbolNeighbor {
                    numbers.append(number)
                }
                currentNumber = ""
                haveSymbolNeighbor = false
            }
        }
        // Check if line ends with a number
        if let number = Int(currentNumber), haveSymbolNeighbor {
            numbers.append(number)
        }
    }

    print(numbers)
    print(numbers.reduce(0, +))
}
