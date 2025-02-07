import SwiftUI

#if os(iOS)
    import UIKit

    // MARK: - Share Sheet
    struct ShareSheet: UIViewControllerRepresentable {
        var activityItems: [Any]
        var applicationActivities: [UIActivity]? = nil

        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: applicationActivities)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context)
        {}
    }
#endif

// MARK: - Field Enum
public enum Field: Hashable {
    case smallStart
    case smallEnd
    case largeStart
    case largeEnd
    case totalVolume
    case flowRate
    case jobNumber
    case additionalRemarks
}

// MARK: - Mars Reading Field
public struct MarsReadingField: View {
    let title: String
    @Binding var text: String
    let field: Field
    var focusField: FocusState<Field?>.Binding

    public init(
        title: String,
        text: Binding<String>,
        focusField: FocusState<Field?>.Binding,
        field: Field
    ) {
        self.title = title
        self._text = text
        self.focusField = focusField
        self.field = field
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("0.0", text: $text)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
                .focused(focusField, equals: field)
        }
    }
}

// MARK: - Card Components
public struct DetailCard<Content: View>: View {
    let title: String
    let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        GroupBox(
            label:
                Text(title)
                .font(.headline)
                .textCase(.uppercase)
                .foregroundColor(.secondary)
        ) {
            content
                .padding(.top, 8)
        }
        .groupBoxStyle(CardGroupBoxStyle())
    }
}

struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: GroupBoxStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
            configuration.content
        }
        .padding()
        .frame(maxWidth: .infinity)
        #if os(iOS)
            .background(Color(uiColor: .systemBackground))
        #else
            .background(.background)
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - View Modifiers
struct MarsSectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if os(iOS)
                .listRowBackground(Color(uiColor: .systemBackground))
            #else
                .listRowBackground(.background)
            #endif
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

struct MarsSectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .textCase(.uppercase)
            .foregroundColor(.secondary)
            .padding(.top, 8)
    }
}

struct PlaceholderStyle: ViewModifier {
    let shouldShow: Bool
    let alignment: Alignment
    let placeholder: Text

    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder
            }
            content
        }
    }
}

// MARK: - View Extensions
extension View {
    public func marsSectionStyle() -> some View {
        modifier(MarsSectionStyle())
    }

    public func marsSectionHeaderStyle() -> some View {
        modifier(MarsSectionHeaderStyle())
    }

    public func placeholder(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Text
    ) -> some View {
        self.modifier(
            PlaceholderStyle(
                shouldShow: shouldShow,
                alignment: alignment,
                placeholder: placeholder()
            ))
    }
}
