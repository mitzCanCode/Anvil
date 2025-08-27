//
//  SimpleCalculator.swift
//  Anvil
//
//  Clean, simple calculator implementation
//

import SwiftUI
import UIKit
import AlertToast


struct ConversionCategory: Identifiable {
    let id = UUID()
    let name: String
    let units: [String]
    let unitMap: [String: Double]
}

struct CalculatorView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Simple state
    @State private var display: String = "0"
    @State private var fromUnit: String = "MB"
    @State private var toUnit: String = "GB"
    @State private var convertedResult: String = "0"
    @State private var selectedCategoryIndex: Int = 0
    
    @State private var showToast: Bool = false
    @State private var showSuccessToast: Bool = false
    @State private var alertMessage: String = ""
    
    // Error handling constants
    private let maxDisplayLength = 20
    private let maxNumberValue = 1e15
    
    
    let categories: [ConversionCategory] = [
        ConversionCategory(
            name: "Data & Storage",
            units: ["B", "KB", "MB", "GB", "TB", "PB", "KiB", "MiB", "GiB"],
            unitMap: [
                "B": 1,
                "KB": 1024,
                "MB": pow(1024, 2),
                "GB": pow(1024, 3),
                "TB": pow(1024, 4),
                "PB": pow(1024, 5),
                "KiB": 1024,
                "MiB": pow(1024, 2),
                "GiB": pow(1024, 3)
            ]
        ),
        ConversionCategory(
            name: "Networking",
            units: ["bps", "Kbps", "Mbps", "Gbps", "B/s", "KB/s", "MB/s"],
            unitMap: [
                "bps": 1,
                "Kbps": 1_000,
                "Mbps": 1_000_000,
                "Gbps": 1_000_000_000,
                "B/s": 8,
                "KB/s": 8 * 1024,
                "MB/s": 8 * pow(1024, 2)
            ]
        ),
        ConversionCategory(
            name: "Time",
            units: ["ms", "s", "min", "h"],
            unitMap: [
                "ms": 0.001,
                "s": 1,
                "min": 60,
                "h": 3600
            ]
        )
    ]
    
    var selectedCategory: ConversionCategory {
        categories[selectedCategoryIndex]
    }
    
    var shouldShowEvaluateButton: Bool {
        return display.contains("+") || display.contains("−") || display.contains("×") ||
               display.contains("÷") || display.contains("^") || display.contains("%")
    }
    
    let buttons: [[String]] = [
        ["7", "8", "9", "C", "⌫"],
        ["4", "5", "6", "÷", "%"],
        ["1", "2", "3", "×", "^"],
        ["CalcType", "0", ".", "−", "+"]
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    // Switch button
                    Button(action: swapUnits) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(alignment: .trailing, spacing: 10) {
                        // Input display
                        HStack(alignment: .bottom) {
                            Spacer()
                            Button(action: copyInput) {
                                ScrollViewReader { scrollProxy in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        Text(display)
                                            .font(.system(size: 50, weight: .bold, design: .monospaced))
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 4)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .id("display")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: display) { _ in
                                        withAnimation(.easeOut(duration: 0.1)) {
                                            scrollProxy.scrollTo("display", anchor: .trailing)
                                        }
                                    }
                                }
                            }
                            
                            Picker("From", selection: $fromUnit) {
                                ForEach(selectedCategory.units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
            .onChange(of: fromUnit) { _ in 
                if display == "Err0r" || convertedResult == "Err0r" {
                    display = "0"
                    convertedResult = "0"
                }
                safeUpdateConversion()
            }
                        }
                        
                        Divider().padding(.leading)
                        
                        // Result display
                        HStack(alignment: .bottom) {
                            Spacer()
                            Button(action: copyResult) {
                                ScrollViewReader { scrollProxy in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        Text(convertedResult)
                                            .font(.system(size: 50, weight: .bold, design: .monospaced))
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 4)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .id("result")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: convertedResult) { _ in
                                        withAnimation(.easeOut(duration: 0.1)) {
                                            scrollProxy.scrollTo("result", anchor: .trailing)
                                        }
                                    }
                                }
                            }
                            
                            Picker("To", selection: $toUnit) {
                                ForEach(selectedCategory.units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: toUnit) { _ in 
                                if display == "Err0r" || convertedResult == "Err0r" {
                                    display = "0"
                                    convertedResult = "0"
                                }
                                safeUpdateConversion()
                            }
                        }
                    }
                }
                .padding()
                .background(.thinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 20))
                .background(
                    Color.purple.opacity(colorScheme == .dark ? 0.3 : 0.2),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            Color.purple.opacity(colorScheme == .dark ? 0.3 : 0.2),
                            lineWidth: 4
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                
                Spacer()
                
                // Evaluate button
                if shouldShowEvaluateButton {
                    Button(action: evaluateExpression) {
                        HStack {
                            Image(systemName: "equal.circle.fill")
                                .font(.title2)
                            Text("Evaluate")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(.thinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 16))
                        .background(Color.green.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 5)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                                          removal: .move(edge: .top).combined(with: .opacity)))
                    .animation(.easeInOut(duration: 0.3), value: shouldShowEvaluateButton)
                }
                
                // Calculator buttons
                VStack(spacing: 8) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { button in
                                if button == "CalcType" {
                                    categoryMenu
                                } else {
                                    calculatorButton(button)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .toast(isPresenting: $showToast) {
                AlertToast(
                    displayMode: .banner(.pop),
                    type: showSuccessToast ? .complete(.green) : .error(.red),
                    title: alertMessage
                )
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        Color.purple.opacity(colorScheme == .dark ? 0.1 : 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Calculator")
        }
    }
    
    // MARK: - UI Components
    
    var categoryMenu: some View {
        Menu {
            ForEach(categories.indices, id: \.self) { index in
                Button(action: { selectCategory(index) }) {
                    HStack {
                        if index == selectedCategoryIndex {
                            Image(systemName: "checkmark")
                        }
                        Text(categories[index].name)
                    }
                }
            }
        } label: {
            Button(action: {
                Haptics.shared.light()
            }) {
                Image(systemName: "slider.vertical.3")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.thinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 16))
                    .background(Color.purple.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.3), lineWidth: 5))
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            }

        }
    }
    
    func calculatorButton(_ button: String) -> some View {
        Button(action: { buttonTapped(button) }) {
            Text(button)
                .font(.title2)
                .fontWeight(.semibold)
                .monospaced()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(.thinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 16))
                .background(buttonColor(button), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(buttonColor(button).opacity(0.3), lineWidth: 5)
                )
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
        }
    }
    
    // MARK: - Logic Functions
    
    func buttonColor(_ button: String) -> Color {
        if ["+", "−", "×", "÷", "^", "%", "C", "⌫"].contains(button) {
            return Color.purple.opacity(0.8)
        } else {
            return Color.blue.opacity(0.8)
        }
    }
    
    func buttonTapped(_ button: String) {
        Haptics.shared.light()
        
        switch button {
        case "C":
            display = "0"
            convertedResult = "0"
            
        case "⌫":
            if display == "Err0r" {
                display = "0"
                convertedResult = "0"
            } else if display.count > 1 {
                display.removeLast()
                safeUpdateConversion()
            } else {
                display = "0"
                convertedResult = "0"
            }
            
        case "+", "−", "×", "÷", "^", "%":
            if display != "0" && display != "Err0r" {
                let newDisplay: String
                // Remove last character if it's an operator
                if ["+", "−", "×", "÷", "^", "%"].contains(String(display.last ?? " ")) {
                    newDisplay = String(display.dropLast()) + button
                } else {
                    newDisplay = display + button
                }
                
                if newDisplay.count <= maxDisplayLength {
                    display = newDisplay
                } else {
                    showErrorMessage("Input too long")
                }
            }
            
        case ".":
            // If in error state, start fresh with "0."
            if display == "Err0r" {
                display = "0."
                if convertedResult == "Err0r" {
                    convertedResult = "0"
                }
                safeUpdateConversion()
            } else {
                // Add decimal if not already present in current number
                let lastNumberComponents = display.components(separatedBy: CharacterSet(charactersIn: "+−×÷^%"))
                if let lastNumber = lastNumberComponents.last, !lastNumber.contains(".") {
                    let newDisplay = display + button
                    if newDisplay.count <= maxDisplayLength {
                        display = newDisplay
                        safeUpdateConversion()
                    } else {
                        showErrorMessage("Input too long")
                    }
                }
            }
            
        default: // Numbers
            let newDisplay = (display == "0" || display == "Err0r") ? button : display + button
            if newDisplay.count <= maxDisplayLength {
                // Check if the number would be too large
                let components = newDisplay.components(separatedBy: CharacterSet(charactersIn: "+−×÷^%"))
                var isValid = true
                
                for component in components {
                    if let value = Double(component), abs(value) > maxNumberValue {
                        isValid = false
                        break
                    }
                }
                
                if isValid {
                    display = newDisplay
                    // Clear any previous error state in result when starting fresh input
                    if convertedResult == "Err0r" {
                        convertedResult = "0"
                    }
                    safeUpdateConversion()
                } else {
                    showErrorMessage("Number too large")
                }
            } else {
                showErrorMessage("Input too long")
            }
        }
    }
    
    func evaluateExpression() {
        Haptics.shared.light()
        
        do {
            // Clean the expression: remove commas and format for evaluation
            let cleanExpr = display
                .replacingOccurrences(of: ",", with: "") // Remove commas from formatted numbers
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
                .replacingOccurrences(of: "−", with: "-")
            
            // Validate expression ends properly
            guard !cleanExpr.isEmpty,
                  !["*", "/", "+", "-", "^", "%"].contains(String(cleanExpr.last ?? " ")) else {
                display = "Err0r"
                convertedResult = "Err0r"
                showErrorMessage("Invalid expression")
                return
            }
            
            // Handle modulus operations first (NSExpression doesn't support %)
            let modulusProcessed = try replaceModulusOperations(cleanExpr)
            
            // Handle simple power operations by replacing ^ with pow function calls
            let processedExpr = replacePowerOperations(modulusProcessed)
            
            // Check for power operation errors
            if processedExpr == "ERROR_IN_POWER" {
                display = "Err0r"
                convertedResult = "Err0r"
                showErrorMessage("Power operation failed")
                return
            }
            
            // Try to evaluate
            let expression = NSExpression(format: processedExpr)
            if let result = expression.expressionValue(with: nil, context: nil) as? NSNumber {
                let value = result.doubleValue
                
                // Check for invalid results
                guard value.isFinite, !value.isNaN, abs(value) <= maxNumberValue else {
                    display = "Err0r"
                    convertedResult = "Err0r"
                    showErrorMessage("Result too large or invalid")
                    return
                }
                
                display = formatNumberForDisplay(value)
                safeUpdateConversion()
                showSuccessMessage("Expression evaluated!")
            } else {
                display = "Err0r"
                convertedResult = "Err0r"
                showErrorMessage("Cannot evaluate expression")
            }
        } catch {
            display = "Err0r"
            convertedResult = "Err0r"
            showErrorMessage("Calculation error: \(error.localizedDescription)")
        }
    }
    
    func replaceModulusOperations(_ expr: String) throws -> String {
        var result = expr
        
        // Simple regex to find number%number patterns and replace with modulus result
        let pattern = #"([0-9.]+)%([0-9.]+)"#
        let regex = try NSRegularExpression(pattern: pattern)
        
        while let match = regex.firstMatch(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count)) {
            guard let range = Range(match.range, in: result) else { break }
            
            let matchedString = String(result[range])
            let components = matchedString.components(separatedBy: "%")
            
            if components.count == 2,
               let dividend = Double(components[0]),
               let divisor = Double(components[1]) {
                
                // Check for division by zero
                guard divisor != 0 else {
                    throw NSError(domain: "CalculatorError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Division by zero in modulus"])
                }
                
                // Check for valid numbers
                guard dividend.isFinite, !dividend.isNaN, divisor.isFinite, !divisor.isNaN else {
                    throw NSError(domain: "CalculatorError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid numbers in modulus"])
                }
                
                // Calculate modulus using fmod for floating point numbers
                let modulusResult = fmod(dividend, divisor)
                
                // Check result validity
                guard modulusResult.isFinite, !modulusResult.isNaN else {
                    throw NSError(domain: "CalculatorError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Invalid modulus result"])
                }
                
                result.replaceSubrange(range, with: String(modulusResult))
            } else {
                break // Avoid infinite loop
            }
        }
        
        return result
    }
    
    func replacePowerOperations(_ expr: String) -> String {
        var result = expr
        
        do {
            // Simple regex to find number^number patterns and replace with pow(number, number)
            let pattern = #"([0-9.]+)\^([0-9.]+)"#
            let regex = try NSRegularExpression(pattern: pattern)
            
            while let match = regex.firstMatch(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count)) {
                guard let range = Range(match.range, in: result) else { break }
                
                let matchedString = String(result[range])
                let components = matchedString.components(separatedBy: "^")
                
                if components.count == 2,
                   let base = Double(components[0]),
                   let exponent = Double(components[1]) {
                    
                    // Check for potentially problematic power operations
                    guard abs(base) <= 1000 && abs(exponent) <= 100 else {
                        throw NSError(domain: "CalculatorError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Power operation too large"])
                    }
                    
                    let powResult = pow(base, exponent)
                    
                    // Check result validity
                    guard powResult.isFinite, !powResult.isNaN, abs(powResult) <= maxNumberValue else {
                        throw NSError(domain: "CalculatorError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Power result too large"])
                    }
                    
                    result.replaceSubrange(range, with: String(powResult))
                } else {
                    break // Avoid infinite loop
                }
            }
        } catch {
            // If there's an error in power operations, throw it up
            return "ERROR_IN_POWER"
        }
        
        return result
    }
    
    func safeUpdateConversion() {
        do {
            // Get numeric value from display (ignore operators for now, just use first number)
            let components = display.components(separatedBy: CharacterSet(charactersIn: "+−×÷^%"))
            guard let firstComponent = components.first,
                  let value = Double(firstComponent),
                  let fromFactor = selectedCategory.unitMap[fromUnit],
                  let toFactor = selectedCategory.unitMap[toUnit] else {
                convertedResult = "0"
                return
            }
            
            // Check for valid input values
            guard value.isFinite, !value.isNaN, abs(value) <= maxNumberValue else {
                convertedResult = "Err0r"
                showErrorMessage("Invalid input value")
                return
            }
            
            let baseValue = value * fromFactor
            
            // Check for overflow in base value calculation
            guard baseValue.isFinite, !baseValue.isNaN, abs(baseValue) <= maxNumberValue * 1000 else {
                convertedResult = "Err0r"
                showErrorMessage("Conversion overflow")
                return
            }
            
            let converted = baseValue / toFactor
            
            // Check for valid result
            guard converted.isFinite, !converted.isNaN else {
                convertedResult = "Err0r"
                showErrorMessage("Conversion error")
                return
            }
            
            convertedResult = formatNumber(converted)
        } catch {
            convertedResult = "Err0r"
            showErrorMessage("Conversion failed: \(error.localizedDescription)")
        }
    }
    
    func formatNumber(_ value: Double) -> String {
        do {
            guard value.isFinite, !value.isNaN else {
                return "Err0r"
            }
            
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: value)) ?? "Err0r"
        } catch {
            return "Err0r"
        }
    }
    
    func formatNumberForDisplay(_ value: Double) -> String {
        do {
            guard value.isFinite, !value.isNaN else {
                return "Err0r"
            }
            
            // For display, we want simple formatting without commas to avoid parsing issues
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            formatter.numberStyle = .none // No comma separators
            formatter.usesGroupingSeparator = false
            return formatter.string(from: NSNumber(value: value)) ?? "Error"
        } catch {
            return "Err0r"
        }
    }
    
    func swapUnits() {
        Haptics.shared.light()
        
        // Clear any error states before swapping
        if display == "Err0r" || convertedResult == "Err0r" {
            display = "0"
            convertedResult = "0"
        }
        
        let temp = fromUnit
        fromUnit = toUnit
        toUnit = temp
        safeUpdateConversion()
    }
    
    func selectCategory(_ index: Int) {
        Haptics.shared.light()
        selectedCategoryIndex = index
        fromUnit = categories[index].units.first ?? ""
        toUnit = categories[index].units.last ?? ""
        
        // Always reset to clean state when switching categories
        display = "0"
        convertedResult = "0"
    }
    
    func copyInput() {
        UIPasteboard.general.string = display
        showSuccessMessage("Input copied to clipboard!")
    }
    
    func copyResult() {
        UIPasteboard.general.string = convertedResult
        showSuccessMessage("Result copied to clipboard!")
    }
    
    func showSuccessMessage(_ message: String) {
        alertMessage = message
        showSuccessToast = true
        showToast = true
    }
    
    func showErrorMessage(_ message: String) {
        alertMessage = message
        showSuccessToast = false
        showToast = true
    }
}

#Preview {
    CalculatorView()
}
