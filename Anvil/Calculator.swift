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
    private var palette: (base: Color, text: Color, red: Color, peach: Color, green: Color, blue: Color, overlay1: Color, accent: Color) {
        if colorScheme == .dark {
            return (
                CatppuccinFrappe.base,
                CatppuccinFrappe.text,
                CatppuccinFrappe.red,
                CatppuccinFrappe.peach,
                CatppuccinFrappe.green,
                CatppuccinFrappe.blue,
                CatppuccinFrappe.overlay1,
                CatppuccinFrappe.mauve // accent
            )
        } else {
            return (
                CatppuccinLatte.base,
                CatppuccinLatte.text,
                CatppuccinLatte.red,
                CatppuccinLatte.peach,
                CatppuccinLatte.green,
                CatppuccinLatte.blue,
                CatppuccinLatte.overlay1,
                CatppuccinLatte.blue // accent
            )
        }
    }
    @State private var inputValue: String = ""
    @State private var fromUnit: String = "MB"
    @State private var toUnit: String = "GB"
    @State private var result: String = "0"
    @State private var selectedCategoryIndex: Int = 0
    
    @State private var showToast: Bool = false
    @State private var showSuccessToast: Bool = false
    @State private var alertMessage: String = ""
    

    let categories: [ConversionCategory] = [
        ConversionCategory(
            name: "Data & Storage",
            units: ["B", "KB", "MB", "GB", "TB", "PB", "KiB", "MiB", "GiB"],
            unitMap: [
                "B": 1,
                "KB": 1_000,
                "MB": 1_000_000,
                "GB": 1_000_000_000,
                "TB": 1_000_000_000_000,
                "PB": 1_000_000_000_000_000,
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
                "KB/s": 8_000,
                "MB/s": 8_000_000
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
    
    let buttons: [[String]] = [
        ["7", "8", "9", "C", "⌫"],
        ["4", "5", "6", "÷", "%"],
        ["1", "2", "3", "×", "^"],
        ["CalcType", "0", ".", "−", "+"]
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack{
                    // Switch button between From and To
                    Button(action: {
                        Haptics.shared.light()
                        let temp = fromUnit
                        fromUnit = toUnit
                        toUnit = temp
                        // Only evaluate if inputValue is a valid number/expression
                        if !inputValue.isEmpty && !"+−×÷^%".contains(inputValue.last!) {
                            evaluateExpression()
                        } else {
                            result = "0"
                        }
//                        Keeping this in case i change my mind although i think its a bit much
//                        alertMessage = "Value switched!"
//                        showSuccessToast = true
//                        showToast = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title2)
                            .foregroundColor(palette.accent)
                    }
                    
                VStack(alignment: .trailing, spacing: 10) {
                    HStack(alignment: .bottom) {
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = inputValue.isEmpty ? "0" : inputValue
                            alertMessage = "Copied to clipboard!"
                            showSuccessToast = true
                            showToast = true
                        }) {
                            Text(inputValue.isEmpty ? "0" : inputValue)
                                .font(.system(size: 50, weight: .bold, design: .monospaced))
                                .lineLimit(1)
                                .bold()
                                .monospaced()
                                .foregroundColor(palette.text)
                        }
                        Picker("From", selection: $fromUnit) {
                            ForEach(selectedCategory.units, id: \.self) { unit in
                                Text(unit)
                                    .tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    
                    Divider()
                        .padding(.leading)

                    HStack(alignment: .bottom) {
                        Button(action: {
                            UIPasteboard.general.string = result
                            alertMessage = "Copied to clipboard!"
                            showSuccessToast = true
                            showToast = true
                        }) {
                            Text(result)
                                .font(.system(size: 50, weight: .bold, design: .monospaced))
                                .lineLimit(1)
                                .bold()
                                .monospaced()
                                .foregroundColor(palette.text)
                        }
                        Picker("To", selection: $toUnit) {
                            ForEach(selectedCategory.units, id: \.self) { unit in
                                Text(unit)
                                    .monospaced()
                                    .tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                    
            }
            .padding(.horizontal)
            .padding(.bottom)

                Spacer()
                
                VStack(spacing: 10) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { button in
                                if button == "CalcType" {
                                    Menu {
                                        ForEach(categories.indices, id: \.self) { index in
                                            Button(action: {
                                                Haptics.shared.light()
                                                selectedCategoryIndex = index
                                                fromUnit = categories[index].units.first ?? ""
                                                toUnit = categories[index].units.last ?? ""
                                                result = "0"
                                                inputValue = ""
                                            }) {
                                                HStack {
                                                    if index == selectedCategoryIndex {
                                                        Image(systemName: "checkmark")
                                                    }
                                                    Text(categories[index].name)
                                                        .monospaced()
                                                }
                                            }
                                        }
                                    } label: {
                                        VStack{
                                            Spacer()
                                            Image(systemName: "slider.vertical.3")
                                            Spacer()
                                        }
                                            .font(.largeTitle)
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                            .foregroundColor(palette.text)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(15)
                                            .modifier(NeonGlow(color: self.buttonColor(button)))
                                    }
                                } else {
                                    Button(action: {
                                        Haptics.shared.light()
                                        self.buttonTapped(button)
                                    }) {
                                        VStack{
                                            Spacer()
                                            Text(button)
                                                .font(.largeTitle)
                                                .monospaced()
                                                .foregroundColor(palette.text)
                                            Spacer()

                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(15)
                                            .modifier(NeonGlow(color: self.buttonColor(button)))
                                    }
                                }
                            }
                        }
                    }
                }
//                .padding(.horizontal)
                .padding()
            }
            .toast(isPresenting: $showToast) {
                AlertToast(
                    displayMode: .banner(.pop),
                    type: showSuccessToast ? .complete(palette.green) : .error(palette.red ),
                    title: alertMessage
                )
            }
            .background(palette.base)
            .accentColor(palette.accent)
            .navigationTitle("Calculator")
        }
    }
    
    private func buttonColor(_ button: String) -> Color {
        if button == "C" {
            return palette.red
        } else if ["+", "−", "×", "÷", "^", "%"].contains(button) {
            return palette.peach
        } else if button == "⌫" {
            return palette.red
        } else if button == "CalcType" {
            return palette.overlay1
        } else if button == "switch" {
            return palette.accent
        } else {
            return palette.blue
        }
    }
    
    private func buttonTapped(_ button: String) {
        switch button {
        case "C":
            inputValue = "0"
            result = "0"
        case "⌫":
            if !inputValue.isEmpty {
                inputValue.removeLast()
                if inputValue.isEmpty {
                    inputValue = "0"
                    result = "0"
                } else if !inputValue.isEmpty && "+−×÷^%".contains(inputValue.last!) {
                    // Do not evaluate if expression ends with operator
                    result = "null Xp"
                    alertMessage = "Invalid expression"
                    showSuccessToast = false
                    showToast = true
                } else {
                    evaluateExpression()
                }
            } else {
                inputValue = "0"
                result = "0"
            }
        case "+", "−", "×", "÷", "^", "%":
            if let last = inputValue.last, "+−×÷^%".contains(last) {
                inputValue.removeLast()
            }
            if !inputValue.isEmpty && inputValue != "0" {
                inputValue.append(button)
            }
        case ".":
            if canAddDecimal() {
                inputValue.append(button)
            }
        default:
            if inputValue == "0" {
                inputValue = ""
            }
            inputValue.append(button)
            evaluateExpression()
        }
    }
    
    private func canAddDecimal() -> Bool {
        // Prevent multiple decimals in a number segment
        var lastNumber = ""
        for char in inputValue.reversed() {
            if "+−×÷^%".contains(char) {
                break
            }
            lastNumber = String(char) + lastNumber
        }
        return !lastNumber.contains(".")
    }
    
    private func evaluateExpression() {
        // Preprocess inputValue:
        var expr = inputValue
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")

        // Do not evaluate if expression ends with operator
        let operatorSet = CharacterSet(charactersIn: "+-*/^%")
        if let last = expr.last, String(last).rangeOfCharacter(from: operatorSet) != nil {
            result = "Error"
            alertMessage = "Expression cannot end with operator"
            showSuccessToast = false
            showToast = true
            return
        }

        // Helper to evaluate power: a^b => pow(a, b)
        func replacePower(_ s: String) -> String {
            var exp = s
            // Regex for numbers or parens: ([0-9.]+|\([^()]*\))\^([0-9.]+|\([^()]*\))
            let pattern = #"((?:[0-9.]+|\([^()]*\)))\^((?:[0-9.]+|\([^()]*\)))"#
            let regex = try? NSRegularExpression(pattern: pattern)
            while let match = regex?.firstMatch(in: exp, options: [], range: NSRange(location: 0, length: exp.utf16.count)) {
                guard let range1 = Range(match.range(at: 1), in: exp),
                      let range2 = Range(match.range(at: 2), in: exp),
                      let rangeAll = Range(match.range(at: 0), in: exp) else { break }
                let a = String(exp[range1])
                let b = String(exp[range2])
                let powStr = "pow(\(a),\(b))"
                exp.replaceSubrange(rangeAll, with: powStr)
            }
            return exp
        }

        // Helper to evaluate mod: a%b => a.truncatingRemainder(dividingBy:b)
        func replaceMod(_ s: String) -> String {
            var exp = s
            // Regex for numbers or parens: ([0-9.]+|\([^()]*\))%([0-9.]+|\([^()]*\))
            let pattern = #"((?:[0-9.]+|\([^()]*\)))%((?:[0-9.]+|\([^()]*\)))"#
            let regex = try? NSRegularExpression(pattern: pattern)
            while let match = regex?.firstMatch(in: exp, options: [], range: NSRange(location: 0, length: exp.utf16.count)) {
                guard let range1 = Range(match.range(at: 1), in: exp),
                      let range2 = Range(match.range(at: 2), in: exp),
                      let rangeAll = Range(match.range(at: 0), in: exp) else { break }
                let a = String(exp[range1])
                let b = String(exp[range2])
                let modStr = "(\(a)).truncatingRemainder(dividingBy:\(b))"
                exp.replaceSubrange(rangeAll, with: modStr)
            }
            return exp
        }

        // Replace ^ and % operators
        expr = replacePower(expr)
        expr = replaceMod(expr)

        // Now try to evaluate via NSExpression
        let nsExp = NSExpression(format: expr)
        if let value = nsExp.expressionValue(with: nil, context: nil) as? NSNumber {
            convert(value: value.doubleValue)
        } else {
            result = "Error"
            alertMessage = "Invalid calculation"
            showSuccessToast = false
            showToast = true
        }
    }
    
    private func convert(value: Double) {
        guard let f = selectedCategory.unitMap[fromUnit], let t = selectedCategory.unitMap[toUnit] else {
            result = "null Xp"
            alertMessage = "Conversion failed"
            showSuccessToast = false
            showToast = true
            return
        }
        let baseValue = value * f
        let converted = baseValue / t
        result = String(baseValue: converted)
    }
    
    private func evaluateMathExpression(_ expression: String) -> Double? {
        // Custom parser to handle +, -, *, /, ^ (power), and % (mod)
        // We'll replace '**' with pow and 'mod' with custom function
        
        var exp = expression
        
        // Evaluate power operator '**' first by replacing with pow function calls
        while let range = exp.range(of: #"([0-9.]+)\*\*([0-9.]+)"#, options: .regularExpression) {
            let match = String(exp[range])
            let parts = match.components(separatedBy: "**")
            if parts.count == 2,
               let base = Double(parts[0]),
               let exponent = Double(parts[1]) {
                let powValue = pow(base, exponent)
                exp.replaceSubrange(range, with: String(powValue))
            } else {
                break
            }
        }
        
        // Evaluate mod operator by replacing 'a mod b' with (a - b * floor(a / b))
        while let range = exp.range(of: #"([0-9.]+) mod ([0-9.]+)"#, options: .regularExpression) {
            let match = String(exp[range])
            let parts = match.components(separatedBy: " mod ")
            if parts.count == 2,
               let a = Double(parts[0]),
               let b = Double(parts[1]),
               b != 0 {
                let modValue = a - b * floor(a / b)
                exp.replaceSubrange(range, with: String(modValue))
            } else {
                break
            }
        }
        
        // Now evaluate the remaining expression with NSExpression
        // Replace any remaining 'mod' just in case (shouldn't be any)
        exp = exp.replacingOccurrences(of: "mod", with: "-")
        
        let nsExp = NSExpression(format: exp)
        if let value = nsExp.expressionValue(with: nil, context: nil) as? NSNumber {
            return value.doubleValue
        }
        return nil
    }
}

extension String {
    init(baseValue value: Double) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.numberStyle = .decimal
        self = formatter.string(from: NSNumber(value: value)) ?? "null Xp"
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}

// NeonGlow modifier for soft colored glow effect
struct NeonGlow: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.7), radius: 1, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: 2, x: 0, y: 0)
            .shadow(color: color.opacity(0.25), radius: 3, x: 0, y: 0)
    }
}
