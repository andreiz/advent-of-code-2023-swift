import Foundation 

// Define a function named `findNumericalValues` that takes a string and
// returns a tuple of two optional integers.
func findFirstAndLastDigit(in s: String) -> Int? {
    // Dictionary mapping spelled-out numbers to their integer values.
    let digitMap: [String: Int] = [
        "one": 1, "two": 2, "three": 3, "four": 4,
        "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9
    ]

    // Array to store pairs of numbers and their positions in the string.
    var allNumbers = [(Int, Int)]()

    // Enumerate through each character in the string along with its index.
    for (index, ch) in s.enumerated() {
        // Check if the character is a digit and convert it to an integer.
        if let digit = ch.wholeNumberValue {
            // Append the digit and its index to the `allNumbers` array.
            allNumbers.append((digit, index))
        }
    }

    // Iterate through each key-value pair in the `digitMap` dictionary.
    for (word, num) in digitMap {
        var start = s.startIndex // Initialize a start index for the search.

        // Search for the word in the substring starting from 'start' and
        // continue while it's found.
        while let range = s[start...].range(of: word) {
            // Calculate the position of the found word in the string.
            let position = s.distance(from: s.startIndex, to: range.lowerBound)
            // Add the number and its position to the `allNumbers` array.
            allNumbers.append((num, position))
            // Update the start index to search for next occurrence of the word.
            let nextIndex = s.index(range.lowerBound, offsetBy: word.count)
            start = nextIndex < s.endIndex ? nextIndex : s.endIndex
        }
    }

    // Sort the `allNumbers` array by the position of the numbers.
    // '$0' and '$1' are shorthand for the first and second arguments in the closure.
    // '.1' accesses the second element of the tuple, which is the position.
    allNumbers.sort(by: { $0.1 < $1.1 })

    // Map the `allNumbers` array to extract only the numerical values.
    let numericalValues = allNumbers.map { $0.0 }

    // Retrieve the first and last numbers, if available.
    guard let first = numericalValues.first,
          let last = numericalValues.last else { return nil }
    // Combine the first and last digits into a single integer
    return Int(String(first) + String(last))
}

// Define a function named 'processFile' that takes a file path as a string and
// doesn't return anything.
func processFile(atPath path: String) {
    do {
        // Try to read the content of the file at the specified path as a
        // string. If this operation fails, the catch block will be executed.
        let content = try String(contentsOfFile: path, encoding: .utf8)

        // Split the content into an array of strings, each representing a line.
        // The splitting is based on newline characters.
        let lines = content.components(separatedBy: .newlines)

        var sum = 0
        
        // Iterate through each line in the 'lines' array.
        for line in lines {
            if line.isEmpty {
                continue
            }

            // Call 'findFirstAndLastDigit' for the current line.
            // If it finds digits, it will return an integer, otherwise nil.
            if let number = findFirstAndLastDigit(in: line) {
                // Print the line and the extracted number if digits are found.
                print("Line: \(line) -> Number: \(number)")
                sum += number
            } else {
                // Print a message indicating no digits were found in the line.
                print("Line: \(line) -> No digits found")
            }
        }
        print("Sum: \(sum)")
    } catch {
        // If there was an error in reading the file, print the error message.
        print("Error reading file: \(error)")
    }
}

// Define the file path as a string. Replace this with the actual path to your
// text file.
let filePath = "input.txt"

// Call the 'processFile' function with the specified file path to process the file.
processFile(atPath: filePath)

