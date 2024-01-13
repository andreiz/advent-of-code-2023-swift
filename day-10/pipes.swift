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

public enum Direction: CaseIterable {
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
}

public struct Pipe {
    let character: Character
    let ends: (Direction, Direction)

    init(_ character: Character, _ ends: (Direction, Direction)) {
        self.character = character
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

struct Grid {
    let rows: Int
    let cols: Int
    let grid: [[Character]]

    init(_ grid: [[Character]]) {
        rows = grid.count
        cols = grid[0].count
        self.grid = grid
    }

    subscript(point: Point) -> Character? {
        if point.y < 0 || point.y >= cols || point.x < 0 || point.x >= rows {
            return nil
        }
        return grid[point.x][point.y]
    }

    func findCharacter(searchFor character: Character) -> Point? {
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                if grid[row][col] == character {
                    return Point(row, col)
                }
            }
        }
        return nil
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

func step(_ grid: Grid, _ loc: Point, _ dir: Direction) -> (Point, Direction)? {
    let nextLoc = loc + Point(dir.offset)
    if let nextTile = grid[nextLoc], nextTile != "." {
        if let nextDir = pipes[nextTile]?.otherEnd(from: dir.opposite) {
            return (nextLoc, nextDir)
        }
    }
    return nil
}

guard let contents = try? String(contentsOfFile: CommandLine.arguments[1]) else {
    print("Error reading from \(CommandLine.arguments[1])")
    exit(1)
}

let grid = Grid(contents.split(separator: "\n").map { Array($0) })
guard let start = grid.findCharacter(searchFor: "S") else {
    print("No start found")
    exit(1)
}

print("Start: \(start), \(grid[start]!)")

var initialDirections = [Direction]()
for dir in Direction.allCases {
    let offset = Point(dir.offset)
    if let tile = grid[start + offset], tile != "." {
        print("\(dir) -> \(tile)")
        if let other = pipes[tile]?.otherEnd(from: dir.opposite) {
            print("Other: \(other)")
            initialDirections.append(dir)
        }
    }
}

print("Initial directions: \(initialDirections)")
guard initialDirections.count == 2 else {
    print("Invalid number of initial directions: \(initialDirections)")
    exit(1)
}

var state1 = (start, initialDirections[0])
var state2 = (start, initialDirections[1])
var steps = 0
while true {
    if let next1 = step(grid, state1.0, state1.1) {
        state1 = next1
    } else {
        break
    }
    if let next2 = step(grid, state2.0, state2.1) {
        state2 = next2
    } else {
        break
    }
    // print("\(state1) \(state2)")
    steps += 1
    if state1.0 == state2.0 {
        print("Collision at \(state1.0)")
        break
    }
}

print("Steps: \(steps)")
