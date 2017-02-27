// Playground - noun: a place where people can play

import Foundation

let str = "(´°̥̥̥̥̥̥̥̥ω°̥̥̥̥̥̥̥̥｀)"
let line = "12345678"

let index = line.index(line.endIndex, offsetBy: (line.characters.count - 1) * -1)
var pathStr = line.substring(from: index)
let spaceSet = CharacterSet.whitespacesAndNewlines
pathStr = pathStr.trimmingCharacters(in: spaceSet)


