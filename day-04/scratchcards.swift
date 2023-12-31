import Foundation

func getNumMatches(_ card: String) -> Int {
    let parts = card.split(separator: ":")
    let numbers = parts[1].split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    let winningNumbers = Set(numbers[0].split(separator: " ").compactMap { Int($0) })
    let playerNumbers = Set(numbers[1].split(separator: " ").compactMap { Int($0) })
    return winningNumbers.intersection(playerNumbers).count
}

func part1(_ cards: [String]) {
    var totalScore = 0
    for card in cards {
        let numMatches = getNumMatches(card)
        if numMatches > 0 {
            let score = 1 << (numMatches - 1) // 2^(numMatches - 1)
            print("\(card) = \(score)")
            totalScore += score
        }
    }

    print("This pile of scratchards is worth: \(totalScore)")
}

func part2(_ cards: [String]) {
    var copyCount: [Int: Int] = [:]
    var total = 0

    for (lineNumber, card) in cards.enumerated() {
        let numMatches = getNumMatches(card)
        if numMatches > 0 {
            let copies = copyCount[lineNumber, default: 0] + 1
            for n in 1 ... numMatches {
                copyCount[lineNumber + n, default: 0] += copies
            }
            total += copies * numMatches
        }
        total += 1 // Add one for the current card
    }

    print("Total # of scratchcards: \(total)")
}

func readInputFile(_ inputFile: String) -> [String]? {
    do {
        let contents = try String(contentsOfFile: inputFile)
        return contents
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    } catch {
        print("Error reading from \(inputFile): \(error)")
        return nil
    }
}

guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}

if let input = readInputFile(CommandLine.arguments[1]) {
    part1(input)
    part2(input)
}
