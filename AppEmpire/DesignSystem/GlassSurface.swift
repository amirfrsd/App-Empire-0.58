import SwiftUI

struct GlassSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(AppColors.raisedSurface.opacity(0.58))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(AppColors.mainText.opacity(0.1), lineWidth: 1)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(AppColors.ink)
            .padding(.horizontal, 22)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(AppColors.lime, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
