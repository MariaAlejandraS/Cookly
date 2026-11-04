import SwiftUI

struct ReminderRow: View {
    let reminder: Reminder
    let onEnabled: (Bool) -> Void

    var body: some View {
        HStack(spacing: CooklyTheme.space12) {
            IconTile(systemName: symbol, tint: reminder.isEnabled ? CooklyTheme.brandForeground : .secondary)
            VStack(alignment: .leading, spacing: CooklyTheme.space4) {
                Text(reminder.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(reminder.isEnabled ? CooklyTheme.ink : .secondary)
                    .lineLimit(2)
                Text(reminder.clockText)
                    .font(CooklyTheme.rounded(.title3, weight: .bold))
                    .foregroundStyle(reminder.isEnabled ? CooklyTheme.brandForeground : .secondary)
                Text(reminder.repetitionLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Toggle("Activar", isOn: Binding(
                get: { reminder.isEnabled },
                set: { onEnabled($0) }
            ))
            .labelsHidden()
            .tint(CooklyTheme.brandForeground)
        }
        .cardStyle()
        .opacity(reminder.isEnabled ? 1 : 0.72)
    }

    /// Desayuno, almuerzo y cena tienen ícono propio; el resto usa la campana.
    private var symbol: String {
        let text = reminder.title.folding(options: .diacriticInsensitive, locale: Locale(identifier: "es")).lowercased()
        if text.contains("desayuno") { return "cup.and.saucer.fill" }
        if text.contains("almuerzo") { return "fork.knife" }
        if text.contains("cena") { return "moon.stars.fill" }
        return "bell.fill"
    }
}
