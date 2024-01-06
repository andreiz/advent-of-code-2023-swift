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

func traverseGraph(graph: Graph, instructions: String) -> [String] {
    var currentNode = "AAA"
    var path = [String]([currentNode])

    while currentNode != "ZZZ" {
        for turn in instructions {
            switch turn {
            case "L":
                currentNode = graph[currentNode]!.left
            case "R":
                currentNode = graph[currentNode]!.right
            default:
                fatalError("Unknown turn: \(turn)")
            }
            if currentNode == "ZZZ" {
                path.append(currentNode)
                break
            }
            path.append(currentNode)
        }
    }
    return path
}

let input = try! String(contentsOfFile: CommandLine.arguments[1])
let (graph, instructions) = parseInput(input: input)
let path = traverseGraph(graph: graph, instructions: instructions)
print("Path: \(path.joined(separator: " -> "))")
print("Path length: \(path.count - 1)")
