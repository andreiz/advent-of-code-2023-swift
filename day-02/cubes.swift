import Foundation

// Define a dictionary to hold the limits for each color of cubes.
let CUBE_LIMITS: [String: Int] = ["red": 12, "green": 13, "blue": 14]

// Define a function to check if each try in a game is possible.
func isGamePossible(gameData: String) -> (isPossible: Bool, violatingCube: String?, count: Int?) {
    // Split the game data into individual tries separated by semicolons.
    let tries = gameData.split(separator: ";")
    for tryData in tries {
        // Split each try into color data separated by commas.
        let colorDataArray = tryData.split(separator: ",")
        for colorData in colorDataArray {
            // Split each color data into count and color separated by space.
            let parts = colorData.split(separator: " ")
            let count = Int(parts[0].trimmingCharacters(in: .whitespaces)) ?? 0
            let color = String(parts[1].trimmingCharacters(in: .whitespaces))

            // Check if the count for each color exceeds its respective limit.
            if let limit = CUBE_LIMITS[color], count > limit {
                return (false, color, count) // Return false with violating cube color and count.
            }
        }
    }

    return (true, nil, nil) // Return true if no violations are found.
}

// Define a function to process the file containing game records.
func processFile(filename: String) {
    // Variable to keep track of the sum of game IDs for possible games.
    var possibleGameSum = 0

    // Try to read the contents of the file.
    if let contents = try? String(contentsOfFile: filename) {
        // Split the file contents into individual lines.
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            if line.isEmpty { continue }
            // Split each line into game number and game data separated by colon.
            let parts = line.split(separator: ":")
            let gameNumber = Int(parts[0].split(separator: " ")[1].trimmingCharacters(in: .whitespaces)) ?? 0
            let gameData = String(parts[1].trimmingCharacters(in: .whitespaces))

            // Check if the game is possible and get details about any violations.
            let (isPossible, violatingCube, count) = isGamePossible(gameData: gameData)
            if isPossible {
                print("Game \(gameNumber) [\(gameData)]: possible")
                possibleGameSum += gameNumber
            } else {
                print("Game \(gameNumber) [\(gameData)]: impossible due to \(violatingCube!) cube count \(count!) exceeding limit")
            }
        }
        print("Sum of possible game numbers: \(possibleGameSum)")
    } else {
        print("Error reading file")
    }
}

processFile(filename: "input.txt")

