import SwiftUI

struct ConversionCategory: Identifiable {
    let id = UUID()
    let name: String
    let units: [String]
    let unitMap: [String: Double]
}

struct CalculatorView: View {
    @State private var inputValue: String = ""
    @State private var fromUnit: String = "MB"
    @State private var toUnit: String = "GB"
    @State private var result: String = "0"
    @State private var selectedCategoryIndex: Int = 0

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

                VStack(alignment: .trailing, spacing: 10) {
                    HStack {
                        Text("From:")
                        Picker("From", selection: $fromUnit) {
                            ForEach(selectedCategory.units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        Text(inputValue.isEmpty ? "0" : inputValue)
                            .font(.largeTitle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider()
                    HStack {
                        Text("To:")
                        Picker("To", selection: $toUnit) {
                            ForEach(selectedCategory.units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)
                        Spacer()
                        Text(result)
                            .font(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 10) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { button in
                                if button == "CalcType" {
                                    Menu {
                                        ForEach(categories.indices, id: \.self) { index in
                                            Button(action: {
                                                selectedCategoryIndex = index
                                                fromUnit = categories[index].units.first ?? ""
                                                toUnit = categories[index].units.last ?? ""
                                                result = "null Xp"
                                                inputValue = ""
                                            }) {
                                                Text(categories[index].name)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "slider.vertical.3")
                                            .font(.title)
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                            .foregroundColor(.white)
                                            .background(self.buttonColor(button))
                                            .cornerRadius(10)
                                    }
                                } else {
                                    Button(action: {
                                        self.buttonTapped(button)
                                    }) {
                                        Text(button)
                                            .font(.title)
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                            .foregroundColor(.white)
                                            .background(self.buttonColor(button))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Dev Converter")
        }
    }
    
    private func buttonColor(_ button: String) -> Color {
        if button == "C" {
            return .red
        } else if ["+", "−", "×", "÷", "^", "%"].contains(button) {
            return .orange
        } else if button == "⌫" {
            return .gray
        } else if button == "CalcType" {
            return .green
        } else {
            return .blue
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
        let expressionString = inputValue
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: "^", with: "**")
            .replacingOccurrences(of: "%", with: " mod ")
        
        if let value = evaluateMathExpression(expressionString) {
            convert(value: value)
        } else {
            result = "null Xp"
        }
    }
    
    private func convert(value: Double) {
        guard let f = selectedCategory.unitMap[fromUnit], let t = selectedCategory.unitMap[toUnit] else {
            result = "null Xp"
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
