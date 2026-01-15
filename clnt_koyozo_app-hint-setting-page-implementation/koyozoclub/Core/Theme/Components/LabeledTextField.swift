//
//  LabeledTextField.swift
import SwiftUI

struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var showEditButton: Bool = false
    var isEditable: Bool = true
    var isFocused: Bool = false
    var isEmailField: Bool = false
    var onEditTapped: (() -> Void)? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.body)
                .foregroundColor(AppTheme.Colors.white)
            
            HStack {
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
                            TextField("", text: $text)
                                .foregroundColor(AppTheme.Colors.darkBlue)
                                .font(.body)
                                .focused($isTextFieldFocused)
                                .keyboardType(isEmailField ? .emailAddress : .default)
                                .textInputAutocapitalization(isEmailField ? .never : .sentences)
                                .autocorrectionDisabled(isEmailField)
                        }
                    }
                }
                .disabled(!isEditable)
                
                if showEditButton && !text.isEmpty {
                    Button(action: {
                        onEditTapped?()
                    }) {
                        Text("Edit")
                            .font(.body)
                            .foregroundColor(AppTheme.Colors.darkBlue)
                    }
                }
            }
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.sm + Spacing.xs)
            .background(AppTheme.Colors.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.white : AppTheme.Colors.darkBlue, lineWidth: isFocused ? 3 : 1)
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
        }
    }
}

#Preview {
    @Previewable @State var email = "Fakeveryverylongemail@gm"
    @Previewable @State var password = ""
    
    return VStack {
        LabeledTextField(
            label: "Email",
            placeholder: "Enter email",
            text: $email,
            showEditButton: true
        )
        LabeledTextField(
            label: "Password",
            placeholder: "Enter password",
            text: $password,
            isSecure: true
        )
    }
    .padding()
    .background(AppTheme.Colors.darkBlue)
}

