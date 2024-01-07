import Foundation

typealias NodeConnections = (left: String, right: String)
typealias Graph = [String: NodeConnections]

func parseInput(input: String) -> (Graph, String) {
    var graph: [String: NodeConnections] = [:]
    let lines = input.split(separator: "\n")
    let traversalInstructions = String(lines[0])

    for line in lines.dropFirst() {
        let parts = line.split(separator: "=").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let nodeName = parts[0]
        let connectedNodes = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "()")).split(separator: ",")
        let leftNode = String(connectedNodes[0].trimmingCharacters(in: .whitespaces))
        let rightNode = String(connectedNodes[1].trimmingCharacters(in: .whitespaces))
        graph[nodeName] = (left: leftNode, right: rightNode)
    }

    return (graph, traversalInstructions)
}

func traverseGraph(graph: Graph, fromNode: String, instructions: String) -> Int {
    var currentNode = fromNode
    var count = 0

    while true {
        for turn in instructions {
            count += 1
            switch turn {
            case "L":
                currentNode = graph[currentNode]!.left
            case "R":
                currentNode = graph[currentNode]!.right
            default:
                fatalError("Unknown turn: \(turn)")
            }
            if currentNode.hasSuffix("Z") {
                return count
            }
        }
    }
}

func gcd(_ a: Int, _ b: Int) -> Int {
    let remainder = a % b
    return remainder == 0 ? b : gcd(b, remainder)
}

func lcm(_ a: Int, _ b: Int) -> Int {
    return a * b / gcd(a, b)
}

let input = try! String(contentsOfFile: CommandLine.arguments[1])
let (graph, instructions) = parseInput(input: input)
let startNodes = graph.keys.filter { $0.hasSuffix("A") }
let pathLengths = startNodes.map { traverseGraph(graph: graph, fromNode: $0, instructions: instructions) }
print("Path lengths: \(pathLengths)")
let totalLength = pathLengths.reduce(1) { lcm($0, $1) }
print("Total length: \(totalLength)")
