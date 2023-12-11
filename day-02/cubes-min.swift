import Foundation

// Define a dictionary to hold the limits for each color of cubes.
let CUBE_LIMITS: [String: Int] = ["red": 12, "green": 13, "blue": 14]

// Define a function to check if each game is possible and calculate fewest cubes needed.
func analyzeGame(gameData: String) -> (isPossible: Bool, fewestCubes: [String: Int]) {
    var maxCubeCounts = ["red": 0, "green": 0, "blue": 0]
    var isPossible = true

    let tries = gameData.split(separator: ";")
    for tryData in tries {
        var currentTryCounts = ["red": 0, "green": 0, "blue": 0]

        let colorDataArray = tryData.split(separator: ",")
        for colorData in colorDataArray {
            let parts = colorData.split(separator: " ")
            let count = Int(parts[0].trimmingCharacters(in: .whitespaces)) ?? 0
            let color = String(parts[1].trimmingCharacters(in: .whitespaces))

            // Assign the count for each color in the current try.
            currentTryCounts[color] = count

            // Check if the count for each color exceeds its respective limit.
            if let limit = CUBE_LIMITS[color], count > limit {
                isPossible = false
            }
        }

        // Update the maximum count for each color after each try.
        for (color, count) in currentTryCounts {
            maxCubeCounts[color] = max(maxCubeCounts[color, default: 0], count)
        }
    }

    return (isPossible, maxCubeCounts) // Return if the game is possible and the fewest cubes needed.
}

// Define a function to process the file containing game records.
func processFile(filename: String) {
    var possibleGameSum = 0
    var cubeProductSum = 0

    if let contents = try? String(contentsOfFile: filename) {
        let lines = contents.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: ":")
            let gameNumber = Int(parts[0].split(separator: " ")[1].trimmingCharacters(in: .whitespaces)) ?? 0
            let gameData = String(parts[1].trimmingCharacters(in: .whitespaces))

            let (isPossible, fewestCubes) = analyzeGame(gameData: gameData)
            let cubeProduct = fewestCubes.values.reduce(1, *)
            cubeProductSum += cubeProduct

            if isPossible {
                print("Game \(gameNumber) [\(gameData)]: possible")
                possibleGameSum += gameNumber
            } else {
                print("Game \(gameNumber) [\(gameData)]: impossible")
            }
            print(" * fewest cubes needed for success: \(fewestCubes), Product of cubes: \(cubeProduct)")
        }
    }

    print("Sum of possible game numbers: \(possibleGameSum)")
    print("Sum of products of minimum cube sets: \(cubeProductSum)")
}

// Specify the path to the file and call the processFile function.
processFile(filename: "input.txt")

