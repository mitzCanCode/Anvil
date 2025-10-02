//
//  RegexGenerator.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 29/8/25.
//

import SwiftUI

struct RegexGeneratorView: View {
    // Presets
    struct Preset: Identifiable {
        let id = UUID()
        let name: String
        let regex: String
        let description: String
    }
    let presets: [Preset] = [
        .init(name: "Email", regex: #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#, description: "An email address"),
        .init(name: "Phone", regex: #"^\d{3}-\d{3}-\d{4}$"#, description: "A US phone number (123-456-7890)"),
        .init(name: "Date", regex: #"^\d{4}-\d{2}-\d{2}$"#, description: "A date in YYYY-MM-DD format"),
        .init(name: "IPv4", regex: #"^(?:\d{1,3}\.){3}\d{1,3}$"#, description: "An IPv4 address"),
        .init(name: "Hex Color", regex: #"^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"#, description: "A hex color code"),
        .init(name: "URL", regex: #"^https?://[^\s/$.?#].[^\s]*$"#, description: "A URL (http or https)"),
        .init(name: "Postal Code", regex: #"^\d{5}(-\d{4})?$"#, description: "A US postal code (ZIP)"),
        .init(name: "Username", regex: #"^[A-Za-z0-9_]{3,16}$"#, description: "Username (3-16 alphanumeric or underscore)"),
    ]

    // Token Types
    enum TokenType: String, CaseIterable, Identifiable {
        case digit = "Digit"
        case word = "Word Character"
        case whitespace = "Whitespace"
        case any = "Any Character"
        case literal = "Literal"
        case charRange = "Character Range"
        case customSet = "Custom Set"
        var id: String { rawValue }
    }

    // Quantifiers
    enum Quantifier: String, CaseIterable, Identifiable {
        case exactly = "Exactly"
        case atLeast = "At Least"
        case atMost = "At Most"
        case between = "Between"
        case zeroOrMore = "Zero or More"
        case oneOrMore = "One or More"
        case optional = "Optional"
        var id: String { rawValue }
    }

    // Position
    enum Position: String, CaseIterable, Identifiable {
        case none = "Anywhere"
        case start = "Start of Line"
        case end = "End of Line"
        var id: String { rawValue }
    }

    // State
    @State private var selectedPreset: Preset? = nil
    @State private var tokenType: TokenType = .digit
    @State private var quantifier: Quantifier = .exactly
    @State private var position: Position = .none
    @State private var count1: String = "1"
    @State private var count2: String = "2"
    @State private var literalInput: String = ""
    @State private var charRangeStart: String = "a"
    @State private var charRangeEnd: String = "z"
    @State private var customSetInput: String = ""
    @State private var testInput: String = ""

    @State private var regexParts: [String] = []
    
    
    // Computed: regex and description
    var generatedRegex: String {
        if let preset = selectedPreset {
            return preset.regex
        }
        return regexParts.joined()
    }

    var humanReadableDescription: String {
        if let preset = selectedPreset {
            return preset.description
        }
        var desc = ""
        switch tokenType {
        case .digit:
            desc = "digit"
        case .word:
            desc = "word character"
        case .whitespace:
            desc = "whitespace"
        case .any:
            desc = "any character"
        case .literal:
            desc = "the character(s) \"\(literalInput)\""
        case .charRange:
            desc = "character from \(charRangeStart)-\(charRangeEnd)"
        case .customSet:
            desc = "character from set [\(customSetInput)]"
        }
        switch quantifier {
        case .exactly:
            if let n = Int(count1) { desc = "exactly \(n) \(desc)\(n == 1 ? "" : "s")" }
        case .atLeast:
            if let n = Int(count1) { desc = "at least \(n) \(desc)\(n == 1 ? "" : "s")" }
        case .atMost:
            if let n = Int(count1) { desc = "at most \(n) \(desc)\(n == 1 ? "" : "s")" }
        case .between:
            if let n1 = Int(count1), let n2 = Int(count2) {
                desc = "between \(n1) and \(n2) \(desc)s"
            }
        case .zeroOrMore:
            desc = "zero or more \(desc)s"
        case .oneOrMore:
            desc = "one or more \(desc)s"
        case .optional:
            desc = "optional \(desc)"
        }
        switch position {
        case .start:
            desc = desc + " at the start of the line"
        case .end:
            desc = desc + " at the end of the line"
        case .none:
            break
        }
        return desc
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Presets Section
                Text("Presets")
                    .font(.headline)
                PresetButton(presets: presets, selected: $selectedPreset)
                Divider()
                // Sentence Builder Section
                SentenceBuilderSection(
                    selectedPreset: $selectedPreset,
                    tokenType: $tokenType,
                    quantifier: $quantifier,
                    position: $position,
                    count1: $count1,
                    count2: $count2,
                    literalInput: $literalInput,
                    charRangeStart: $charRangeStart,
                    charRangeEnd: $charRangeEnd,
                    customSetInput: $customSetInput
                )
                Button("Append") {
                    regexParts.append(buildCurrentToken())
                }
                .buttonStyle(.borderedProminent)
                Divider()
                // Preview Section
                RegexPreviewSection(
                    regex: generatedRegex,
                    description: humanReadableDescription
                )
                Divider()
                // Test Section
                TestSection(regex: generatedRegex, testInput: $testInput)
            }
            .padding()
        }
    }
    
    
    
    func buildCurrentToken() -> String {
        var base: String = ""
        switch tokenType {
        case .digit: base = "\\d"
        case .word: base = "\\w"
        case .whitespace: base = "\\s"
        case .any: base = "."
        case .literal: base = NSRegularExpression.escapedPattern(for: literalInput)
        case .charRange:
            if let s = charRangeStart.first, let e = charRangeEnd.first {
                base = "[\(s)-\(e)]"
            }
        case .customSet:
            base = "[" + NSRegularExpression.escapedPattern(for: customSetInput) + "]"
        }
        var quant: String = ""
        switch quantifier {
        case .exactly:
            if let n = Int(count1), n > 0 { quant = "{\(n)}" }
        case .atLeast:
            if let n = Int(count1), n > 0 { quant = "{\(n),}" }
        case .atMost:
            if let n = Int(count1), n > 0 { quant = "{0,\(n)}" }
        case .between:
            if let n1 = Int(count1), let n2 = Int(count2), n1 <= n2, n1 >= 0 {
                quant = "{\(n1),\(n2)}"
            }
        case .zeroOrMore: quant = "*"
        case .oneOrMore: quant = "+"
        case .optional: quant = "?"
        }
        var expr = base + quant
        switch position {
        case .start: expr = "^\(expr)"
        case .end: expr = "\(expr)$"
        case .none: break
        }
        return expr
    }
    
}

// MARK: - Preset Button Grid
struct PresetButton: View {
    let presets: [RegexGeneratorView.Preset]
    @Binding var selected: RegexGeneratorView.Preset?
    let columns = [GridItem(.adaptive(minimum: 120), spacing: 12)]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(presets) { preset in
                Button(action: {
                    selected = preset
                }) {
                    Text(preset.name)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selected?.id == preset.id ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selected?.id == preset.id ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                }
            }
        }
    }
}

// MARK: - Sentence Builder Section
struct SentenceBuilderSection: View {
    @Binding var selectedPreset: RegexGeneratorView.Preset?
    @Binding var tokenType: RegexGeneratorView.TokenType
    @Binding var quantifier: RegexGeneratorView.Quantifier
    @Binding var position: RegexGeneratorView.Position
    @Binding var count1: String
    @Binding var count2: String
    @Binding var literalInput: String
    @Binding var charRangeStart: String
    @Binding var charRangeEnd: String
    @Binding var customSetInput: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Build Your Regex")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    selectedPreset = nil
                    tokenType = .digit
                    quantifier = .exactly
                    position = .none
                    count1 = "1"
                    count2 = "2"
                    literalInput = ""
                    charRangeStart = "a"
                    charRangeEnd = "z"
                    customSetInput = ""
                }
            }
            if selectedPreset != nil {
                Text("Preset selected. To build your own, tap Clear.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                Group {
                    HStack(spacing: 12) {
                        // Token Picker
                        Picker("Token", selection: $tokenType) {
                            ForEach(RegexGeneratorView.TokenType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        // Inline input for literal
                        if tokenType == .literal {
                            TextField("Text", text: $literalInput)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        if tokenType == .charRange {
                            TextField("Start", text: $charRangeStart)
                                .frame(width: 32)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("-")
                            TextField("End", text: $charRangeEnd)
                                .frame(width: 32)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        if tokenType == .customSet {
                            TextField("Set", text: $customSetInput)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    HStack(spacing: 12) {
                        // Quantifier Picker
                        Picker("Quantifier", selection: $quantifier) {
                            ForEach(RegexGeneratorView.Quantifier.allCases) { q in
                                Text(q.rawValue).tag(q)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        // Inline input for quantifiers needing counts
                        if quantifier == .exactly || quantifier == .atLeast || quantifier == .atMost {
                            TextField("N", text: $count1)
                                .frame(width: 40)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        if quantifier == .between {
                            TextField("Min", text: $count1)
                                .frame(width: 36)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("-")
                            TextField("Max", text: $count2)
                                .frame(width: 36)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    // Position Picker
                    Picker("Position", selection: $position) {
                        ForEach(RegexGeneratorView.Position.allCases) { pos in
                            Text(pos.rawValue).tag(pos)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Regex Preview Section
struct RegexPreviewSection: View {
    let regex: String
    let description: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Preview")
                .font(.headline)
            HStack(alignment: .center, spacing: 8) {
                Text(regex)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(6)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = regex
                        }) {
                            Label("Copy Regex", systemImage: "doc.on.doc")
                        }
                    }
                Spacer()
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Test Section
struct TestSection: View {
    let regex: String
    @Binding var testInput: String
    func matchRanges() -> [Range<String.Index>] {
        guard !regex.isEmpty, !testInput.isEmpty else { return [] }
        do {
            let pattern = regex
            let regexObj = try NSRegularExpression(pattern: pattern)
            let nsrange = NSRange(testInput.startIndex..<testInput.endIndex, in: testInput)
            let matches = regexObj.matches(in: testInput, options: [], range: nsrange)
            return matches.compactMap { match in
                Range(match.range, in: testInput)
            }
        } catch {
            return []
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Test")
                .font(.headline)
            TextField("Type test input...", text: $testInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(matchRanges(), id: \.self) { range in
                        Text(String(testInput[range]))
                            .font(.system(.body, design: .monospaced))
                            .padding(4)
                            .background(Color.yellow.opacity(0.5))
                            .cornerRadius(4)
                    }
                    if matchRanges().isEmpty && !testInput.isEmpty {
                        Text("No matches")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct RegexButtonGroup: View {
    let title: String
    let buttons: [(String, () -> Void)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                        Button(button.0, action: button.1)
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    RegexGeneratorView()
}
