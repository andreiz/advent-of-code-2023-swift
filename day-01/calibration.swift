import Foundation 

// Define a function named 'findFirstAndLastDigit' which takes a string as input
// and returns an optional integer.
func findFirstAndLastDigit(in string: String) -> Int? {
    // Use the 'filter' method to iterate over each character in the string,
    // keeping only those that are numbers.
    let digits = string.filter { $0.isNumber } 
    
    // Use 'guard' to check if the first and last characters in the 'digits'
    // string exist. If they don't, the function will exit and return 'nil'.
    guard let first = digits.first, let last = digits.last else { return nil }
    
    // Combine the first and last digits into a new string, and then try to
    // convert this string to an integer. The result is returned. If the
    // conversion fails, it will return 'nil'.
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

