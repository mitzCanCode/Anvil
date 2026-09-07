//
//  Checkpoint.swift
//  DevPoint
//
//  Created by mitz on 24/8/26.
//

import Foundation
import SwiftUI
import SwiftData

enum CheckpointStatus: String, Codable {
    case healthy
    case unreachable
    case unknown
    case warning
    case serverError
    case notFound
case responseMismatch
    /// HTTP OK, but the body differs only on lines the user chose to ignore.
    case expectedMismatch
    /// HTTP OK and content matches, but latency exceeds the configured threshold.
    case slow
    
    var title: String {
        switch self {
        case .healthy, .expectedMismatch:
            return "Healthy"
        case .unreachable:
            return "Unreachable"
        case .unknown:
            return "Unknown"
        case .warning:
            return "Warning"
        case .serverError:
            return "Server Error"
        case .notFound:
            return "Not Found"
        case .responseMismatch:
            return "Response Mismatch"
        case .slow:
            return "Slow Response"
        }
    }
    
    var color: Color {
        switch self {
        case .healthy, .expectedMismatch:
            return .mint
        case .unreachable:
            return .red
        case .unknown:
            return .gray
        case .warning:
            return .yellow
        case .serverError:
            return .red
        case .notFound:
            return .orange
        case .responseMismatch:
            return .orange
        case .slow:
            return .yellow
        }
    }
}


enum CheckpointType: String, Codable, CaseIterable {
    case api
    case website
    
    var title: String {
        switch self {
        case .api:
            return "API"
        case .website:
            return "Website"
        }
    }
    
    var icon: String {
        switch self {
        case .api:
            return "server.rack"
        case .website:
            return "network"
        }
    }
}

struct RequestHeader: Identifiable, Codable, Equatable {
    let id: UUID
    var key: String
    var value: String

    init(id: UUID = UUID(), key: String = "", value: String = "") {
        self.id = id
        self.key = key
        self.value = value
    }
}


@Model
final class Checkpoint {
    var name: String
    var creationDate: Date
    var lastRunDate: Date
    var status: CheckpointStatus
    var checkpointType: CheckpointType
    
    var url: URL
    var expectedResponse: String
    var lastResponseTitle: String
    var lastResponseStatusCode: String
    /// Token sent as a Bearer value in the Authorization request header for API checks.
    var authorizationToken: String = ""
    /// JSON-encoded `[RequestHeader]` of additional request headers for API checks.
    var requestHeadersJSON: String = "[]"
    
var lastResponseDescription: String
    var lastResponse: String
    /// Baseline latency captured when the expected response was set, in milliseconds.
    var expectedResponseTimeMs: Int = 0
    /// Most recent request latency, in milliseconds.
    var lastResponseTimeMs: Int = 0
    /// JSON-encoded `[String: String]` of the latest response headers.
    var lastResponseHeadersJSON: String = "{}"
    /// JSON-encoded `[String: String]` of the baseline/expected response headers.
    var expectedResponseHeadersJSON: String = "{}"
    /// 1-based line numbers in the response body to exclude from mismatch checks.
    var ignoredLineNumbers: [Int] = []
    /// Header names to exclude from mismatch checks (case-insensitive match).
    var ignoredHeaderNames: [String] = []
    var lastResponseHeaders: [String: String] {
        get { Self.decodeHeaders(lastResponseHeadersJSON) }
        set { lastResponseHeadersJSON = Self.encodeHeaders(newValue) }
    }
    
    var expectedResponseHeaders: [String: String] {
        get { Self.decodeHeaders(expectedResponseHeadersJSON) }
        set { expectedResponseHeadersJSON = Self.encodeHeaders(newValue) }
    }

    var requestHeaderEntries: [RequestHeader] {
        get { Self.decodeRequestHeaderEntries(requestHeadersJSON) }
        set { requestHeadersJSON = Self.encodeRequestHeaderEntries(newValue) }
    }

    var effectiveRequestHeaders: [String: String] {
        var headers: [String: String] = [:]
        for entry in requestHeaderEntries {
            let key = entry.key.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { continue }
            headers[key] = entry.value
        }
        let token = authorizationToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    private static func encodeRequestHeaderEntries(_ entries: [RequestHeader]) -> String {
        guard let data = try? JSONEncoder().encode(entries),
              let string = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return string
    }

    private static func decodeRequestHeaderEntries(_ json: String) -> [RequestHeader] {
        guard let data = json.data(using: .utf8) else { return [] }

        if let entries = try? JSONDecoder().decode([RequestHeader].self, from: data) {
            return entries
        }

        // Preserve configurations written by the earlier dictionary-backed editor.
        return decodeHeaders(json)
            .map { RequestHeader(key: $0.key, value: $0.value) }
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }
    
    init(
        name: String,
        url: URL,
        expectedResponse: String,
        checkpointType: CheckpointType = .website
    ) {
        self.name = name
        self.creationDate = Date()
        self.lastRunDate = Date()
        self.status = .unknown
        self.checkpointType = checkpointType
        
        self.url = url
        self.expectedResponse = expectedResponse
        
self.lastResponseTitle = ""
        self.lastResponseStatusCode = ""
        self.authorizationToken = ""
        self.requestHeadersJSON = "[]"
        self.lastResponseDescription = ""
        self.lastResponse = ""
        self.expectedResponseTimeMs = 0
        self.lastResponseTimeMs = 0
        self.lastResponseHeadersJSON = "{}"
        self.expectedResponseHeadersJSON = "{}"
        self.ignoredLineNumbers = []
        self.ignoredHeaderNames = []
    }
    
    /// How much slower the latest response is than the expected baseline, in ms (clamped at 0).
    var responseTimeDeltaMs: Int {
        max(0, lastResponseTimeMs - expectedResponseTimeMs)
    }
    
    /// Whether latency alone should flag this checkpoint, based on Settings.
    var isResponseTooSlow: Bool {
        guard let thresholdMs = MonitoringSettings.responseTimeThreshold.milliseconds else {
            return false
        }
        guard expectedResponseTimeMs > 0, lastResponseTimeMs > 0 else {
            return false
        }
        return responseTimeDeltaMs >= thresholdMs
    }
    
    /// Writes status/body/header fields from a live request result.
    func applyResponseResult(
        _ result: URLResponseResult,
        match: ResponseMatchKind? = nil,
        updateExpectedHeaders: Bool = false,
        expectedResponseTimeMs: Int? = nil
    ) {
        lastResponse = result.body
        lastResponseTitle = result.statusCode == -1
        ? (result.errorMessage ?? "Request failed")
        : "HTTP \(result.statusCode)"
        lastResponseStatusCode = result.statusCode == -1
        ? "—"
        : "\(result.statusCode)"
        lastResponseDescription = result.headers["Content-Type"]
        ?? result.headers["content-type"]
        ?? result.errorMessage
        ?? ""
        lastResponseHeaders = result.headers
        lastResponseTimeMs = result.responseTimeMs
        if updateExpectedHeaders {
            expectedResponseHeaders = result.headers
        }
        if let expectedResponseTimeMs {
            self.expectedResponseTimeMs = expectedResponseTimeMs
        }
        lastRunDate = Date()
        
        if let match {
            status = determineCheckpointStatus(
                statusCode: result.statusCode,
                match: match,
                isSlow: isResponseTooSlow
            )
        } else {
            recomputeStatus(statusCode: result.statusCode)
        }
    }
    
    private static func encodeHeaders(_ headers: [String: String]) -> String {
        guard JSONSerialization.isValidJSONObject(headers),
              let data = try? JSONSerialization.data(withJSONObject: headers, options: [.sortedKeys]),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
    
    private static func decodeHeaders(_ json: String) -> [String: String] {
        guard let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let headers = object as? [String: String]
        else {
            return [:]
        }
        return headers
    }
    
    func recomputeStatus(statusCode: Int? = nil) {
        let code: Int
        if let statusCode {
            code = statusCode
        } else if lastResponseTitle.hasPrefix("HTTP "),
                  let parsed = Int(lastResponseTitle.dropFirst(5).trimmingCharacters(in: .whitespaces)) {
            code = parsed
        } else if status == .unreachable || lastResponseTitle == "Request failed" {
            code = -1
        } else {
            code = 200
        }
        
status = determineCheckpointStatus(
            statusCode: code,
            match: compareCheckpoint(
                expectedBody: expectedResponse,
                actualBody: lastResponse,
                ignoredLineNumbers: ignoredLineNumbers,
                expectedHeaders: expectedResponseHeaders,
                actualHeaders: lastResponseHeaders,
                ignoredHeaderNames: ignoredHeaderNames
            ),
            isSlow: isResponseTooSlow
        )
    }
    
    func toggleIgnoredLineNumber(_ lineNumber: Int) {
        if let index = ignoredLineNumbers.firstIndex(of: lineNumber) {
            ignoredLineNumbers.remove(at: index)
        } else {
            ignoredLineNumbers.append(lineNumber)
            ignoredLineNumbers.sort()
        }
        recomputeStatus()
    }
    
    func toggleIgnoredHeaderName(_ headerName: String) {
        let target = headerName.lowercased()
        if let index = ignoredHeaderNames.firstIndex(where: { $0.lowercased() == target }) {
            ignoredHeaderNames.remove(at: index)
        } else {
            ignoredHeaderNames.append(headerName)
            ignoredHeaderNames.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }
        recomputeStatus()
    }
}
