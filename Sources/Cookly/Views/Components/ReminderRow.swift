import SwiftUI

struct ReminderRow: View {
    let reminder: Reminder
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: CooklyTheme.space12) {
            IconTile(systemName: symbol, tint: reminder.isDone ? .secondary : CooklyTheme.brandForeground)
            VStack(alignment: .leading, spacing: CooklyTheme.space4) {
                Text(reminder.title)
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(reminder.isDone)
                    .foregroundStyle(reminder.isDone ? .secondary : CooklyTheme.ink)
                    .lineLimit(2)
                Text(Self.timeText(reminder.date))
                    .font(CooklyTheme.rounded(.title3, weight: .bold))
                    .foregroundStyle(reminder.isDone ? .secondary : CooklyTheme.brandForeground)
            }
            Spacer(minLength: 8)
            Button {
                withAnimation(.snappy) { onToggle() }
            } label: {
                Image(systemName: reminder.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(reminder.isDone ? CooklyTheme.success : .secondary)
                    .frame(width: 44, height: 44)
                    .scaleEffect(reminder.isDone ? 1.05 : 1)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(reminder.isDone ? "Marcar como pendiente" : "Marcar como hecho")
        }
        .cardStyle()
        .animation(.snappy, value: reminder.isDone)
    }

    /// Desayuno, almuerzo y cena tienen ícono propio; el resto usa la campana.
    private var symbol: String {
        let text = reminder.title.folding(options: .diacriticInsensitive, locale: Locale(identifier: "es")).lowercased()
        if text.contains("desayuno") { return "cup.and.saucer.fill" }
        if text.contains("almuerzo") { return "fork.knife" }
        if text.contains("cena") { return "moon.stars.fill" }
        return "bell.fill"
    }

    private static func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
