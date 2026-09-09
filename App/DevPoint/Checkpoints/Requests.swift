//
//  Requests.swift
//  DevPoint
//
//  Created by mitz on 24/8/26.
//

import Foundation

struct URLResponseResult {
    let statusCode: Int
    let body: String
    let headers: [String: String]
    let errorMessage: String?
    /// Wall-clock request duration in milliseconds.
    let responseTimeMs: Int

    init(
        statusCode: Int,
        body: String,
        headers: [String: String],
        errorMessage: String? = nil,
        responseTimeMs: Int = 0
    ) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
        self.errorMessage = errorMessage
        self.responseTimeMs = responseTimeMs
    }
}

func requestUrl(_ url: URL, headers: [String: String] = [:]) async -> URLResponseResult {
    let started = ContinuousClock.now
    do {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        let (data, response) = try await URLSession.shared.data(for: request)
        let responseTimeMs = elapsedMilliseconds(since: started)

        guard let httpResponse = response as? HTTPURLResponse else {
            return URLResponseResult(
                statusCode: -1,
                body: String(data: data, encoding: .utf8) ?? "",
                headers: [:],
                errorMessage: "The server did not return an HTTP response.",
                responseTimeMs: responseTimeMs
            )
        }

        let body = String(data: data, encoding: .utf8) ?? ""

        let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) {
            $0[String(describing: $1.key)] = String(describing: $1.value)
        }

        return URLResponseResult(
            statusCode: httpResponse.statusCode,
            body: body,
            headers: headers,
            responseTimeMs: responseTimeMs
        )

    } catch {
        return URLResponseResult(
            statusCode: -1,
            body: "",
            headers: [:],
            errorMessage: error.localizedDescription,
            responseTimeMs: elapsedMilliseconds(since: started)
        )
    }
}

private func elapsedMilliseconds(since start: ContinuousClock.Instant) -> Int {
    let duration = ContinuousClock.now - start
    let seconds = Double(duration.components.seconds)
        + Double(duration.components.attoseconds) / 1_000_000_000_000_000_000
    return max(0, Int((seconds * 1000).rounded()))
}

enum ResponseMatchKind: Equatable {
    case exact
    /// Bodies differ, but only on lines the user marked as ignorable.
    case expectedMismatch
    case mismatch
}

func responseLines(from text: String) -> [String] {
    if text.isEmpty { return [] }
    var result = text.components(separatedBy: "\n")
    if text.hasSuffix("\n") {
        result.removeLast()
    }
    return result
}

/// Drops 1-based line numbers from a response body before comparison.
func normalizeResponse(_ text: String, ignoringLineNumbers ignored: [Int]) -> String {
    let ignoredSet = Set(ignored)
    return responseLines(from: text)
        .enumerated()
        .filter { !ignoredSet.contains($0.offset + 1) }
        .map(\.element)
        .joined(separator: "\n")
}

func compareResponses(
    expected: String,
    actual: String,
    ignoredLineNumbers: [Int]
) -> ResponseMatchKind {
    if expected == actual {
        return .exact
    }

    let normalizedExpected = normalizeResponse(expected, ignoringLineNumbers: ignoredLineNumbers)
    let normalizedActual = normalizeResponse(actual, ignoringLineNumbers: ignoredLineNumbers)

    if normalizedExpected == normalizedActual {
        return .expectedMismatch
    }

    return .mismatch
}

/// Case-insensitive header map used for equality and ignore filtering.
func normalizedHeaderMap(
    _ headers: [String: String],
    ignoring ignoredHeaderNames: [String] = []
) -> [String: String] {
    let ignored = Set(ignoredHeaderNames.map { $0.lowercased() })
    var result: [String: String] = [:]
    result.reserveCapacity(headers.count)

    for (key, value) in headers {
        let lowercasedKey = key.lowercased()
        guard !ignored.contains(lowercasedKey) else { continue }
        result[lowercasedKey] = value
    }

    return result
}

func compareHeaders(
    expected: [String: String],
    actual: [String: String],
    ignoredHeaderNames: [String]
) -> ResponseMatchKind {
    let fullExpected = normalizedHeaderMap(expected)
    let fullActual = normalizedHeaderMap(actual)

    if fullExpected == fullActual {
        return .exact
    }

    let normalizedExpected = normalizedHeaderMap(expected, ignoring: ignoredHeaderNames)
    let normalizedActual = normalizedHeaderMap(actual, ignoring: ignoredHeaderNames)

    if normalizedExpected == normalizedActual {
        return .expectedMismatch
    }

    return .mismatch
}

func combineMatchKinds(_ lhs: ResponseMatchKind, _ rhs: ResponseMatchKind) -> ResponseMatchKind {
    switch (lhs, rhs) {
    case (.mismatch, _), (_, .mismatch):
        return .mismatch
    case (.expectedMismatch, _), (_, .expectedMismatch):
        return .expectedMismatch
    case (.exact, .exact):
        return .exact
    }
}

/// Overall body + header match using the same ignore rules as the editors.
func compareCheckpoint(
    expectedBody: String,
    actualBody: String,
    ignoredLineNumbers: [Int],
    expectedHeaders: [String: String],
    actualHeaders: [String: String],
    ignoredHeaderNames: [String]
) -> ResponseMatchKind {
    combineMatchKinds(
        compareResponses(
            expected: expectedBody,
            actual: actualBody,
            ignoredLineNumbers: ignoredLineNumbers
        ),
        compareHeaders(
            expected: expectedHeaders,
            actual: actualHeaders,
            ignoredHeaderNames: ignoredHeaderNames
        )
    )
}

/// 1-based line numbers where expected and actual differ (for highlighting).
func differingLineNumbers(expected: String, actual: String) -> Set<Int> {
    let oldLines = responseLines(from: expected)
    let newLines = responseLines(from: actual)
    let maxCount = max(oldLines.count, newLines.count)
    var result = Set<Int>()

    for index in 0..<maxCount {
        let old = index < oldLines.count ? oldLines[index] : nil
        let new = index < newLines.count ? newLines[index] : nil
        if old != new {
            result.insert(index + 1)
        }
    }

    return result
}

/// Header names (preferring expected casing) whose values differ between maps.
func differingHeaderNames(
    expected: [String: String],
    actual: [String: String]
) -> Set<String> {
    let expectedByLower = Dictionary(
        uniqueKeysWithValues: expected.map { ($0.key.lowercased(), ($0.key, $0.value)) }
    )
    let actualByLower = Dictionary(
        uniqueKeysWithValues: actual.map { ($0.key.lowercased(), ($0.key, $0.value)) }
    )

    var result = Set<String>()
    let allKeys = Set(expectedByLower.keys).union(actualByLower.keys)

    for key in allKeys {
        let expectedEntry = expectedByLower[key]
        let actualEntry = actualByLower[key]
        if expectedEntry?.1 != actualEntry?.1 {
            result.insert(expectedEntry?.0 ?? actualEntry?.0 ?? key)
        }
    }

    return result
}

/// 1-based line numbers that are not identical across every sampled response body.
func unstableLineNumbers(across bodies: [String]) -> [Int] {
    guard let first = bodies.first else { return [] }

    var unstable = Set<Int>()
    for body in bodies.dropFirst() {
        unstable.formUnion(differingLineNumbers(expected: first, actual: body))
    }

    return unstable.sorted()
}

/// Header names that are not identical across every sampled response.
func unstableHeaderNames(across headerMaps: [[String: String]]) -> [String] {
    guard let first = headerMaps.first else { return [] }

    var unstable = Set<String>()
    for headers in headerMaps.dropFirst() {
        unstable.formUnion(differingHeaderNames(expected: first, actual: headers))
    }

    return unstable.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
}

enum ResponseSampleError: LocalizedError {
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .requestFailed(let message):
            return message
        }
    }
}

struct ResponseSampleResult {
    let baseline: URLResponseResult
    let ignoredLineNumbers: [Int]
    let ignoredHeaderNames: [String]
    /// Mean response time across sample requests, in milliseconds.
    let expectedResponseTimeMs: Int
}

let responseSampleRequestCount = 4
let responseSampleDelayNanoseconds: UInt64 = 1_000_000_000

/// Fetches the URL several times with a delay, using the first response as baseline
/// and auto-ignoring body lines and headers that change across samples.
func sampleResponseBaseline(
    from url: URL,
    headers: [String: String] = [:],
    sampleCount: Int = responseSampleRequestCount,
    delayNanoseconds: UInt64 = responseSampleDelayNanoseconds,
    onProgress: ((String) -> Void)? = nil
) async throws -> ResponseSampleResult {
    var samples: [URLResponseResult] = []
    samples.reserveCapacity(sampleCount)

    for index in 1...sampleCount {
        onProgress?("Request \(index) of \(sampleCount)…")
        let result = await requestUrl(url, headers: headers)

        if let errorMessage = result.errorMessage, result.statusCode == -1 {
            throw ResponseSampleError.requestFailed(errorMessage)
        }

        samples.append(result)

        if index < sampleCount {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
    }

    guard let baseline = samples.first else {
        throw ResponseSampleError.requestFailed("No responses were received.")
    }

    let totalMs = samples.reduce(0) { $0 + $1.responseTimeMs }
    let averageMs = Int((Double(totalMs) / Double(samples.count)).rounded())

    return ResponseSampleResult(
        baseline: baseline,
        ignoredLineNumbers: unstableLineNumbers(across: samples.map(\.body)),
        ignoredHeaderNames: unstableHeaderNames(across: samples.map(\.headers)),
        expectedResponseTimeMs: averageMs
    )
}

func determineCheckpointStatus(
    statusCode: Int,
    match: ResponseMatchKind,
    isSlow: Bool = false
) -> CheckpointStatus {
    switch statusCode {
    case 200...299:
        switch match {
        case .exact:
            return isSlow ? .slow : .healthy
        case .expectedMismatch:
            // Content is acceptable; still surface unacceptable latency.
            return isSlow ? .slow : .expectedMismatch
        case .mismatch:
            return .responseMismatch
        }

    case 400...499:
        if statusCode == 404 {
            return .notFound
        }
        return .warning

    case 500...599:
        return .serverError

    case -1:
        return .unreachable

    default:
        return .unknown
    }
}

/// Convenience for call sites that only know whether the raw bodies match.
func determineCheckpointStatus(
    statusCode: Int,
    responseMatches: Bool,
    isSlow: Bool = false
) -> CheckpointStatus {
    determineCheckpointStatus(
        statusCode: statusCode,
        match: responseMatches ? .exact : .mismatch,
        isSlow: isSlow
    )
}
