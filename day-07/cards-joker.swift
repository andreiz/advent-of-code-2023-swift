import Foundation

enum Rank: Int, Comparable {
    case highCard
    case onePair
    case twoPair
    case threeOfAKind
    case fullHouse
    case fourOfAKind
    case fiveOfAKind

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

let cardValues: [Character: Int] = ["A": 14, "K": 13, "Q": 12, "J": 1, "T": 10, "9": 9, "8": 8, "7": 7, "6": 6, "5": 5, "4": 4, "3": 3, "2": 2]

class CardHand: Comparable {
    let cards: String
    let rank: Rank

    init(_ cards: String) {
        self.cards = cards
        rank = Self.classify(cards)
    }

    private static func classify(_ cards: String) -> Rank {
        var cardCount = [Character: Int]()

        for card in cards {
            cardCount[card, default: 0] += 1
        }

        let jokerCount = cardCount.removeValue(forKey: "J") ?? 0
        // If there are 5 jokers, it's a five of a kind, return here because array is empty
        if jokerCount == 5 {
            return .fiveOfAKind
        }
        // Add the jokers to the highest frequency card (doesn't matter if there are more than one)
        let maxCount = cardCount.values.max() ?? 0
        cardCount[cardCount.first(where: { $0.value == maxCount })!.key]! += jokerCount

        let pattern = cardCount.values.sorted(by: >)

        switch pattern {
        case [5]:
            return .fiveOfAKind
        case [4, 1]:
            return .fourOfAKind
        case [3, 2]:
            return .fullHouse
        case [3, 1, 1]:
            return .threeOfAKind
        case [2, 2, 1]:
            return .twoPair
        case [2, 1, 1, 1]:
            return .onePair
        default:
            return .highCard
        }
    }

    static func < (lhs: CardHand, rhs: CardHand) -> Bool {
        if lhs.rank != rhs.rank {
            return lhs.rank < rhs.rank
        }

        let lhsValues = lhs.cards.map { cardValues[$0]! }
        let rhsValues = rhs.cards.map { cardValues[$0]! }

        for (lhsValue, rhsValue) in zip(lhsValues, rhsValues) {
            if lhsValue != rhsValue {
                return lhsValue < rhsValue
            }
        }

        return false
    }

    static func == (lhs: CardHand, rhs: CardHand) -> Bool {
        return lhs.cards == rhs.cards
    }
}

let input = try! String(contentsOfFile: CommandLine.arguments[1])

let hands = input.split(separator: "\n").compactMap { line -> (CardHand, Int)? in
    let parts = line.split(separator: " ")
    return (CardHand(String(parts[0])), Int(parts[1]) ?? 0)
}

// sort hands and then sum the multiples of hand bid and hand position in the orray
let winnings = hands.sorted(by: { $0.0 < $1.0 }).enumerated().reduce(0) {
    print("Hand \($1.offset + 1): \($1.element.0.cards) \($1.element.1)")
    return $0 + ($1.offset + 1) * $1.element.1
}

print("Winnings: \(winnings)")
