//
//  RegexGenerator.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 29/8/25.
//

import SwiftUI

struct RegexGeneratorView: View {
    @State private var regexParts: [String] = []
    
    @State private var showCustomCountAlert = false
    @State private var customCountInput = ""
    
    @State private var showCharRangeAlert = false
    @State private var charRangeStart = ""
    @State private var charRangeEnd = ""
    
    @State private var showSpecialCharAlert = false
    @State private var specialCharInput = ""
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button("Clear") {
                        regexParts = []
                    }
                    Button("Digit (0-9)") {
                        regexParts.append("\\d")
                    }
                    Button("Word Character (a-z, A-Z, 0-9, _)") {
                        regexParts.append("\\w")
                    }
                    Button("Whitespace (space, tab, etc.)") {
                        regexParts.append("\\s")
                    }
                    Button("Start of Line") {
                        regexParts.append("^")
                    }
                    Button("End of Line") {
                        regexParts.append("$")
                    }
                    Button("Optional (?)") {
                        regexParts.append("?")
                    }
                    Button("One or More (+)") {
                        regexParts.append("+")
                    }
                    Button("Zero or More (*)") {
                        regexParts.append("*")
                    }
                    Button("Custom Count") {
                        customCountInput = ""
                        showCustomCountAlert = true
                    }
                    Button("Character Range") {
                        charRangeStart = ""
                        charRangeEnd = ""
                        showCharRangeAlert = true
                    }
                    Button("Special Character") {
                        specialCharInput = ""
                        showSpecialCharAlert = true
                    }
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .lineLimit(1)
            }
            ScrollView {
                Text(regexParts.joined())
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .alert("Custom Count", isPresented: $showCustomCountAlert, actions: {
            TextField("Enter count (number)", text: $customCountInput)
                .keyboardType(.numberPad)
            Button("Add") {
                if let n = Int(customCountInput), n > 0 {
                    regexParts.append(".{\(n)}")
                }
                showCustomCountAlert = false
            }
            Button("Cancel", role: .cancel) {
                showCustomCountAlert = false
            }
        })
        .alert("Character Range", isPresented: $showCharRangeAlert, actions: {
            TextField("Start character", text: $charRangeStart)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            TextField("End character", text: $charRangeEnd)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            Button("Add") {
                if let start = charRangeStart.first, let end = charRangeEnd.first, start <= end {
                    regexParts.append("[\(start)-\(end)]")
                }
                showCharRangeAlert = false
            }
            Button("Cancel", role: .cancel) {
                showCharRangeAlert = false
            }
        })
        .alert("Special Character", isPresented: $showSpecialCharAlert, actions: {
            TextField("Enter character to escape", text: $specialCharInput)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            Button("Add") {
                if let char = specialCharInput.first {
                    regexParts.append("\\" + String(char))
                }
                showSpecialCharAlert = false
            }
            Button("Cancel", role: .cancel) {
                showSpecialCharAlert = false
            }
        })
    }
}

#Preview {
    RegexGeneratorView()
}
