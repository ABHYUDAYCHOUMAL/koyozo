//
//  AuthTextField.swift
import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        AppTextField(
            placeholder: placeholder,
            text: $text,
            isSecure: isSecure
        )
    }
}

#Preview {
    @Previewable @State var text = ""
    return AuthTextField(placeholder: "Enter text", text: $text)
}

