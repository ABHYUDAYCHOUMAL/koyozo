//
//  TextField.swift
import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isFocused: Bool = false
    var isEmailField: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Placeholder text - only show when text is empty AND not focused
            if text.isEmpty && !isTextFieldFocused {
                Text(placeholder)
                    .foregroundColor(Color.white.opacity(0.55))
                    .font(.body)
                    .allowsHitTesting(false)
            }
            
            // Text field
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .foregroundColor(AppTheme.Colors.text)
                        .font(.body)
                        .focused($isTextFieldFocused)
                } else {
                    SwiftUI.TextField("", text: $text)
                        .foregroundColor(AppTheme.Colors.text)
                        .font(.body)
                        .focused($isTextFieldFocused)
                        .keyboardType(isEmailField ? .emailAddress : .default)
                        .textInputAutocapitalization(isEmailField ? .never : .sentences)
                        .autocorrectionDisabled(isEmailField)
                }
            }
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.sm + Spacing.xs)
        .background(AppTheme.Colors.inputBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isFocused ? AppTheme.Colors.inputBorderFocused : AppTheme.Colors.inputBorder,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
    }
}

#Preview {
    @Previewable @State var text = ""
    return AppTextField(placeholder: "Enter text", text: $text)
}

