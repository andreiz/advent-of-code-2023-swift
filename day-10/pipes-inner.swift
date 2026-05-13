import Foundation

struct Point: Equatable {
    let x, y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    init(_ tuple: (Int, Int)) {
        self.init(tuple.0, tuple.1)
    }

    public static func + (_ lhs: Point, _ rhs: Point) -> Point {
        return Point(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    public static func - (_ lhs: Point, _ rhs: Point) -> Point {
        return Point(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    public static func == (_ lhs: Point, _ rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

public enum ANSIColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

public enum Direction: Int, CaseIterable, Comparable {
    case north, east, south, west

    public var offset: (_: Int, _: Int) {
        switch self {
        case .north: return (-1, 0)
        case .east: return (0, 1)
        case .south: return (1, 0)
        case .west: return (0, -1)
        }
    }

    public var opposite: Direction {
        switch self {
        case .north: return .south
        case .east: return .west
        case .south: return .north
        case .west: return .east
        }
    }

    public static func < (lhs: Direction, rhs: Direction) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public extension Character {
    var drawable: Character {
        switch self {
        case "7": return "┓"
        case "L": return "┗"
        case "F": return "┏"
        case "J": return "┛"
        case "|": return "┃"
        case "-": return "━"
        default: return self
        }
    }

    func format(_ color: ANSIColors) -> String {
        return "\(color.rawValue)\(drawable)\(ANSIColors.default.rawValue)"
    }
}

public struct Pipe {
    let tile: Character
    let ends: (Direction, Direction)

    init(_ tile: Character, _ ends: (Direction, Direction)) {
        self.tile = tile
        self.ends = ends
    }

    public func otherEnd(from: Direction) -> Direction? {
        if ends.0 == from {
            return ends.1
        } else if ends.1 == from {
            return ends.0
        }
        return nil
    }
}

class Grid {
    let rows: Int
    let cols: Int
    var tiles: [[Character]]
    var types: [[Character]]

    init(_ tiles: [[Character]]) {
        rows = tiles.count
        cols = tiles[0].count
        self.tiles = tiles
        types = Array(repeating: Array(repeating: "O", count: cols), count: rows)
    }

    subscript(point: Point) -> Character? {
        get {
            if point.y < 0 || point.y >= cols || point.x < 0 || point.x >= rows {
                return nil
            }
            return tiles[point.x][point.y]
        }
        set {
            if point.y < 0 || point.y >= cols || point.x < 0 || point.x >= rows {
                return
            }
            tiles[point.x][point.y] = newValue!
        }
    }

    func setType(_ type: Character, at: Point) {
        types[at.x][at.y] = type
    }

    func getType(at: Point) -> Character {
        return types[at.x][at.y]
    }

    func findCharacter(searchFor character: Character) -> Point? {
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                if tiles[row][col] == character {
                    return Point(row, col)
                }
            }
        }
        return nil
    }

    func draw() {
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                switch types[row][col] {
                case "O": print(tiles[row][col].format(ANSIColors.default), terminator: "")
                case "I": print(tiles[row][col].format(ANSIColors.red), terminator: "")
                case "P": print(tiles[row][col].format(ANSIColors.blue), terminator: "")
                default: print(tiles[row][col].format(ANSIColors.black), terminator: "")
                }
            }
            print()
        }
    }
}

let pipes: [Character: Pipe] = [
    "|": Pipe("|", (.north, .south)),
    "-": Pipe("-", (.east, .west)),
    "7": Pipe("7", (.south, .west)),
    "L": Pipe("L", (.north, .east)),
    "F": Pipe("F", (.south, .east)),
    "J": Pipe("J", (.north, .west)),
]

guard let contents = try? String(contentsOfFile: CommandLine.arguments[1]) else {
    print("Error reading from \(CommandLine.arguments[1])")
    exit(1)
}

let grid = Grid(contents.split(separator: "\n").map { Array($0) })
guard let start = grid.findCharacter(searchFor: "S") else {
    print("No start found")
    exit(1)
}

grid.setType("P", at: start)
print("Start: \(start), \(grid[start]!)")

var initialDirections = [Direction]()
var initialTiles = [Character]()
for dir in Direction.allCases {
    let offset = Point(dir.offset)
    if let tile = grid[start + offset], tile != "." {
        print("\(dir) -> \(tile)")
        if let other = pipes[tile]?.otherEnd(from: dir.opposite) {
            print("Other: \(other)")
            initialDirections.append(dir)
            initialTiles.append(tile)
        }
    }
}

print("Initial tiles: \(initialTiles)")
print(pipes.keys.sorted())

print("Initial directions: \(initialDirections)")
guard initialDirections.count == 2 else {
    print("Invalid number of initial directions: \(initialDirections)")
    exit(1)
}

var currentLoc = start
var currentDir = initialDirections[0]
var steps = 0
while true {
    let nextLoc = currentLoc + Point(currentDir.offset)
    guard let nextTile = grid[nextLoc] else {
        fatalError("No tile at \(nextLoc)")
    }
    steps += 1
    grid.setType("P", at: currentLoc)
    if nextTile == "S" {
        break
    }

    currentLoc = nextLoc
    if let nextDir = pipes[nextTile]?.otherEnd(from: currentDir.opposite) {
        currentDir = nextDir
    } else {
        fatalError("Invalid tile at \(nextLoc): \(nextTile)")
    }
}

grid[start] = getPipeFiller(for: (initialDirections[0], initialDirections[1]))
grid.setType("P", at: start)

func getPipeFiller(for directions: (Direction, Direction)) -> Character {
    let sortedDirections = [directions.0, directions.1].sorted()

    print("Sorted directions: \(sortedDirections)")
    switch (sortedDirections[0], sortedDirections[1]) {
    case (.north, .south):
        return "|"
    case (.east, .west):
        return "-"
    case (.south, .west):
        return "7"
    case (.north, .east):
        return "L"
    case (.east, .south):
        return "F"
    case (.north, .west):
        return "J"
    default:
        fatalError("Invalid direction combination")
    }
}

func countIntersections(_ grid: Grid, from startPoint: Point) -> Int {
    let pipeCorners: Set<Character> = ["F", "7", "J", "L"]
    var lastCorner: Character?
    var currentLoc = startPoint
    var count = 0

    while let tile = grid[currentLoc] {
        let tileType = grid.getType(at: currentLoc)
        if tileType == "P" {
            switch tile {
            case "|":
                count += 1
            case "L", "F":
                lastCorner = tile
                count += 1
            case let tile where pipeCorners.contains(tile):
                if let last = lastCorner, (last == "L" && tile == "J") || (last == "F" && tile == "7") {
                    count += 1
                }
                lastCorner = nil
            default:
                break
            }
        }

        currentLoc = currentLoc + Point(Direction.east.offset)
    }

    return count
}

for row in 0 ..< grid.rows {
    for col in 0 ..< grid.cols {
        if grid.getType(at: Point(row, col)) == "P" {
            continue
        }

        let count = countIntersections(grid, from: Point(row, col))
        if count % 2 == 1 {
            grid.setType("I", at: Point(row, col))
        } else {
            grid.setType("O", at: Point(row, col))
        }
    }
}

// Scan the grid to count all the tiles with "I" type
var count = 0
for row in 0 ..< grid.rows {
    for col in 0 ..< grid.cols {
        if grid.getType(at: Point(row, col)) == "I" {
            count += 1
        }
    }
}

grid.draw()

print("Inside tiles: \(count)")
