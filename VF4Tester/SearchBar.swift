import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 12)
            
            TextField("Search by job, meter type, or size...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .foregroundColor(.white)
                .accentColor(.white)
                .padding(8)
                .background(Color.black)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                        .shadow(color: Color.blue.opacity(0.5), radius: 2, x: 0, y: 0)
                )
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 12)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
