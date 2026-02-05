import SwiftUI

struct SHMapSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Spacer(minLength: 0)

            Button { } label: {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.black.opacity(0.25), lineWidth: 1)
        )
    }
}
