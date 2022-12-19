//
//  CurrencyTextField.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-18.
//

import Foundation
import SwiftUI

struct CurrencyTextField: UIViewRepresentable {

    typealias UIViewType = CurrencyUITextField

    let numberFormatter: NumberFormatterProtocol
    let currencyField: CurrencyUITextField

    init(numberFormatter: NumberFormatterProtocol, value: Binding<Int>) {
        self.numberFormatter = numberFormatter
        currencyField = CurrencyUITextField(formatter: numberFormatter, value: value)
    }

    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }

    func updateUIView(_ uiView: CurrencyUITextField, context: Context) { }
}
