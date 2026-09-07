//
//  UnifiedDiffBuilder.swift
//  DevPoint
//
//  Created by mitz on 25/8/26.
//


import Foundation

// MARK: - Unified diff (git-style)
enum UnifiedDiffBuilder {
    static func make(
        oldText: String,
        newText: String
    ) -> String {
        let oldLines = lines(from: oldText)
        let newLines = lines(from: newText)
        let edits = myersDiff(old: oldLines, new: newLines)

        var body = ""
        body += "diff --git a/ b/\n"

        let oldCount = oldLines.count
        let newCount = newLines.count

        if oldCount == 0 && newCount == 0 {
            body += "@@ -0,0 +0,0 @@\n"
            return body
        } else if oldCount == 0 {
            body += "@@ -0,0 +1,\(newCount) @@\n"
        } else if newCount == 0 {
            body += "@@ -1,\(oldCount) +0,0 @@\n"
        } else {
            body += "@@ -1,\(oldCount) +1,\(newCount) @@\n"
        }

        for edit in edits {
            switch edit {
            case .equal(let line):
                body += " \(line)\n"
            case .delete(let line):
                body += "-\(line)\n"
            case .insert(let line):
                body += "+\(line)\n"
            }
        }

        return body
    }

    private static func lines(from text: String) -> [String] {
        if text.isEmpty { return [] }
        var result = text.components(separatedBy: "\n")
        if text.hasSuffix("\n") {
            result.removeLast()
        }
        return result
    }

    private enum Edit {
        case equal(String)
        case delete(String)
        case insert(String)
    }

    /// Minimal Myers diff producing a linear edit script.
    private static func myersDiff(old: [String], new: [String]) -> [Edit] {
        let n = old.count
        let m = new.count
        let maxD = n + m

        if n == 0 {
            return new.map { .insert($0) }
        }
        if m == 0 {
            return old.map { .delete($0) }
        }

        var v = Array(repeating: 0, count: 2 * maxD + 1)
        var trace: [[Int]] = []

        outer: for d in 0...maxD {
            trace.append(v)
            for k in stride(from: -d, through: d, by: 2) {
                let index = k + maxD
                var x: Int
                if k == -d || (k != d && v[index - 1] < v[index + 1]) {
                    x = v[index + 1]
                } else {
                    x = v[index - 1] + 1
                }
                var y = x - k
                while x < n, y < m, old[x] == new[y] {
                    x += 1
                    y += 1
                }
                v[index] = x
                if x >= n, y >= m {
                    break outer
                }
            }
        }

        var edits: [Edit] = []
        var x = n
        var y = m

        for d in stride(from: trace.count - 1, through: 0, by: -1) {
            let vSnapshot = trace[d]
            let k = x - y
            let index = k + maxD

            let prevK: Int
            if k == -d || (k != d && vSnapshot[index - 1] < vSnapshot[index + 1]) {
                prevK = k + 1
            } else {
                prevK = k - 1
            }

            let prevX = vSnapshot[prevK + maxD]
            let prevY = prevX - prevK

            while x > prevX, y > prevY {
                x -= 1
                y -= 1
                edits.append(.equal(old[x]))
            }

            if d == 0 { break }

            if x == prevX {
                y -= 1
                edits.append(.insert(new[y]))
            } else {
                x -= 1
                edits.append(.delete(old[x]))
            }
        }

        return edits.reversed()
    }
}
