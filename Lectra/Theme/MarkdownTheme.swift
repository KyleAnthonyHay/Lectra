import SwiftUI
import MarkdownUI

extension Theme {
    static let lectraClearBackground = Theme()
        // Base text styling
        .text {
            BackgroundColor(nil)
            ForegroundColor(.primary)
            FontFamily(.system())
            FontSize(.em(1.0))
//            LineSpacing(.em(0.25))
        }
        // Heading styles
        .heading1 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.bold)
                    FontSize(.em(2))
                }
                .markdownMargin(top: .em(1.5), bottom: .em(1))
                .padding(.bottom, 8)
                .overlay(alignment: .bottom) {
                    Divider().background(Color.secondary.opacity(0.2))
                }
        }
        .heading2 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1.5))
                }
                .markdownMargin(top: .em(1.5), bottom: .em(1))
                .padding(.bottom, 8)
                .overlay(alignment: .bottom) {
                    Divider().background(Color.secondary.opacity(0.2))
                }
        }
        .heading3 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1.25))
                }
                .markdownMargin(top: .em(1.5), bottom: .em(1))
        }
        .heading4 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1))
                }
                .markdownMargin(top: .em(1.5), bottom: .em(1))
        }
        // Link styling
        .link {
            ForegroundColor(LectraColors.brand)
            UnderlineStyle(.single)
        }
        // Code blocks
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            BackgroundColor(.secondary.opacity(0.1))
//            PaddingLeft(4)
//            PaddingRight(4)
        }
        .codeBlock { configuration in
            configuration.label
                .markdownTextStyle {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.85))
                }
                .padding(16)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .markdownMargin(top: .em(1), bottom: .em(1))
        }
        // Blockquotes
        .blockquote { configuration in
            configuration.label
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color.secondary.opacity(0.05))
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 4)
                }
                .markdownMargin(top: .em(1), bottom: .em(1))
        }
        // Lists
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: .em(0.25))
        }
        // Tables
        .table { configuration in
            configuration.label
                .markdownMargin(top: .em(1), bottom: .em(1))
        }
        .tableCell { configuration in
            configuration.label
                .padding(8)
                .overlay {
                    Rectangle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
        }
        // Task lists
        .taskListMarker { configuration in
            Image(systemName: configuration.isCompleted ? "checkmark.square.fill" : "square")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.secondary)
                .imageScale(.small)
        }
        // Thematic breaks (horizontal rules)
        .thematicBreak {
            Divider()
                .frame(height: 1)
                .background(Color.secondary.opacity(0.2))
                .markdownMargin(top: .em(1.5), bottom: .em(1.5))
        }
        // Images
        .image { configuration in
            configuration.label
                .cornerRadius(8)
                .markdownMargin(top: .em(1), bottom: .em(1))
        }
}

// Minimal helper, if needed, from your previous attempt was fine.
// Keeping it simple for now by not re-adding the border/if helpers unless specifically requested.
// If table borders become a must-have, we can add those helpers back.

// Helper for conditional border
extension View {
    @ViewBuilder
    func border<S: ShapeStyle>(_ content: S, width: CGFloat = 1, edges: [Edge]) -> some View {
        self.overlay(EdgeBorder(width: width, edges: edges).foregroundColor(.clear))
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
} 
