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
                    .foregroundColor(Color.gray.opacity(0.6))
                    .font(.body)
                    .allowsHitTesting(false)
            }
            
            // Text field
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .foregroundColor(AppTheme.Colors.darkBlue)
                        .font(.body)
                        .focused($isTextFieldFocused)
                } else {
                    SwiftUI.TextField("", text: $text)
                        .foregroundColor(AppTheme.Colors.darkBlue)
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
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color.white : AppTheme.Colors.darkBlue, lineWidth: isFocused ? 3 : 1)
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
    }
}

#Preview {
    @Previewable @State var text = ""
    return AppTextField(placeholder: "Enter text", text: $text)
}

