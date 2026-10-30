import SwiftUI

/// Créditos del taller. Los nombres y el curso se muestran tal cual.
struct AboutView: View {
    private let members = ["María Alejandra Solarte", "Ronal Santiago Valdez Jurado"]
    private let technologies = ["SwiftUI", "MVVM", "SwiftData", "JSON", "URLSession", "Codable"]

    var body: some View {
        ScrollView {
            VStack(spacing: CooklyTheme.space16) {
                header
                Text("Nevera digital: vencimientos, búsqueda en Open Food Facts y recordatorios de comidas.")
                    .font(.subheadline)
                    .foregroundStyle(CooklyTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(members, id: \.self) { name in
                    member(name)
                }
                techRow
                course
                Text("Datos de alimentos: Open Food Facts (licencia ODbL).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(CooklyTheme.space16)
        }
        .cooklyScreen()
        .navigationTitle("Acerca de")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: CooklyTheme.space8) {
            Image(systemName: "refrigerator.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(CooklyTheme.primary, in: RoundedRectangle(cornerRadius: CooklyTheme.radius16, style: .continuous))
                .padding(4)
                .background(CooklyTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .accessibilityHidden(true)
            Text("COOKLY")
                .font(CooklyTheme.rounded(.title, weight: .bold))
                .foregroundStyle(CooklyTheme.onGradient)
            Text("Versión 1.0")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CooklyTheme.onGradient.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CooklyTheme.space24)
        .background {
            RoundedRectangle(cornerRadius: CooklyTheme.radius24, style: .continuous)
                .fill(CooklyTheme.brandGradient)
        }
    }

    private func member(_ name: String) -> some View {
        HStack(spacing: CooklyTheme.space12) {
            InitialsAvatar(name: name, size: 48)
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CooklyTheme.ink)
            Spacer()
        }
        .cardStyle()
    }

    private var techRow: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            SectionHeader(title: "Tecnologías")
            Text("Almacenamiento: \(PersistenceFactory.activeName)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CooklyTheme.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CooklyTheme.space8) {
                    ForEach(technologies, id: \.self) { item in
                        Pill(text: item, foreground: CooklyTheme.ink, background: CooklyTheme.surface)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var course: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space8) {
            SectionHeader(title: "Curso")
            fact("Asignatura", "Desarrollo de Aplicaciones Móviles")
            fact("Profesor", "Ph.D. Cristhian Figueroa")
            fact("Universidad", "Universidad del Cauca")
        }
        .cardStyle()
    }

    private func fact(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(CooklyTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
