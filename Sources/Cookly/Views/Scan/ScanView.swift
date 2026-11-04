import SwiftUI

/// Escáner de código de barras. La cámara solo corre en esta pestaña y en estado idle.
struct ScanView: View {
    @StateObject private var viewModel: ScanViewModel
    @State private var isVisible = false
    @State private var availability: ScannerAvailability = .checking
    @State private var manualCode = ""
    @State private var manualError: String?
    @State private var manualOpen = false
    @State private var productToEdit: Product?
    @State private var detail: OFFProduct?
    @State private var showManualProduct = false
    @State private var pendingBarcode = ""
    @FocusState private var manualFocused: Bool

    init(ownerId: UUID) {
        _viewModel = StateObject(wrappedValue: ScanViewModel(ownerId: ownerId))
    }

    var body: some View {
        NavigationStack {
            screen
        }
    }

    private var screen: some View {
        VStack(spacing: 0) {
            ZStack {
                scanner
                centerMessage
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomPanel
        }
        .cooklyScreen()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Escanear")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Listo") { manualFocused = false }
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .onChange(of: availability) { _, _ in
            if cameraBlocked { manualOpen = true }
        }
        .simultaneousGesture(TapGesture().onEnded { manualFocused = false })
        .sheet(isPresented: needsDetails) {
            if case .needsDetails(let product) = viewModel.state {
                AddProductView(viewModel: AddProductViewModel(from: product, ownerId: viewModel.ownerId))
            }
        }
        .sheet(item: $productToEdit) { product in
            AddProductView(viewModel: AddProductViewModel(product: product, ownerId: viewModel.ownerId))
        }
        .sheet(item: $detail) { product in
            NavigationStack {
                ProductDetailView(product: product, ownerId: viewModel.ownerId, showsAddButton: false)
            }
        }
        .sheet(isPresented: $showManualProduct, onDismiss: {
            if case .notFound = viewModel.state { viewModel.rescan() }
        }) {
            AddProductView(viewModel: AddProductViewModel(ownerId: viewModel.ownerId, barcode: pendingBarcode))
        }
    }

    private var shouldRun: Bool {
        isVisible && availability == .ready && viewModel.state == .idle
    }

    private var scanner: some View {
        BarcodeScannerView(
            isRunning: shouldRun,
            generation: viewModel.generation,
            onCodeDetected: { viewModel.handle(code: $0) },
            onAvailability: { availability = $0 }
        )
        .ignoresSafeArea(edges: .top)
        .background(Color.black)
    }

    @ViewBuilder
    private var centerMessage: some View {
        switch availability {
        case .checking:
            ProgressView("Preparando la cámara…")
                .padding(CooklyTheme.space16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CooklyTheme.radius16, style: .continuous))
        case .missingUsageDescription:
            Text("Falta NSCameraUsageDescription en Info del target")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CooklyTheme.ink)
                .multilineTextAlignment(.center)
                .padding(CooklyTheme.space16)
                .cardStyle()
                .padding(CooklyTheme.space16)
        case .denied:
            IllustratedEmpty(
                symbol: "video.slash",
                title: "Cámara desactivada",
                message: "Cookly necesita la cámara para leer códigos de barras. Actívala en Ajustes.",
                primaryTitle: "Abrir Ajustes",
                primaryAction: CameraAccess.openSettings
            )
            .padding(CooklyTheme.space16)
            .background(CooklyTheme.canvas.opacity(0.94))
        case .unavailable:
            IllustratedEmpty(
                symbol: "camera.viewfinder",
                title: "La cámara no está disponible en este dispositivo",
                message: "Ingresa el código con el teclado."
            )
            .padding(CooklyTheme.space16)
            .background(CooklyTheme.canvas.opacity(0.94))
        case .ready:
            if viewModel.state == .idle || viewModel.state == .loading {
                VStack(spacing: CooklyTheme.space16) {
                    ScanFrame()
                    Text("Apunta al código de barras")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
                .allowsHitTesting(false)
            }
        }
    }

    private var bottomPanel: some View {
        ViewThatFits(in: .vertical) {
            panelContent
            ScrollView { panelContent }
        }
        .frame(maxHeight: 460)
        .background(CooklyTheme.canvas)
        .animation(.snappy, value: viewModel.state)
    }

    private var panelContent: some View {
        VStack(spacing: CooklyTheme.space12) {
            resultCard
            if shouldShowManual { manualCard }
        }
        .padding(CooklyTheme.space16)
    }

    private var cameraBlocked: Bool {
        switch availability {
        case .unavailable, .denied, .missingUsageDescription: return true
        default: return false
        }
    }

    private var shouldShowManual: Bool {
        if cameraBlocked { return true }
        switch viewModel.state {
        case .idle, .failed, .notFound: return true
        default: return false
        }
    }

    @ViewBuilder
    private var resultCard: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            VStack(alignment: .leading, spacing: CooklyTheme.space12) {
                HStack(spacing: CooklyTheme.space12) {
                    RoundedRectangle(cornerRadius: CooklyTheme.radius12).frame(width: 64, height: 64)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre del producto")
                        Text("Categoría")
                    }
                }
                .redacted(reason: .placeholder)
                ProgressView("Buscando producto…")
            }
            .cardStyle()
        case .added(let product):
            addedCard(product)
        case .needsDetails:
            EmptyView()
        case .notFound:
            VStack(alignment: .leading, spacing: CooklyTheme.space12) {
                Text("No encontramos este código")
                    .font(CooklyTheme.rounded(.headline, weight: .bold))
                    .foregroundStyle(CooklyTheme.ink)
                Button("Agregar manualmente") {
                    if case .notFound(let code) = viewModel.state {
                        pendingBarcode = code
                        showManualProduct = true
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                Button("Escanear otro") { viewModel.rescan() }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .cardStyle()
        case .failed(let message):
            VStack(alignment: .leading, spacing: CooklyTheme.space12) {
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CooklyTheme.danger)
                Button("Reintentar") { viewModel.retry() }
                    .buttonStyle(PrimaryButtonStyle())
                Button("Escanear otro") { viewModel.rescan() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            .cardStyle()
        }
    }

    private func addedCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            HStack(alignment: .top, spacing: CooklyTheme.space12) {
                productImage(product.imageURL)
                VStack(alignment: .leading, spacing: CooklyTheme.space8) {
                    Text(product.name)
                        .font(CooklyTheme.rounded(.headline, weight: .bold))
                        .foregroundStyle(CooklyTheme.ink)
                    Text(product.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Pill(
                        text: product.daysLeft == 1
                            ? "Vence mañana (sugerido)"
                            : "Vence en \(product.daysLeft) días (sugerido)",
                        foreground: CooklyTheme.success,
                        background: CooklyTheme.successSoft
                    )
                }
            }
            Button("Deshacer") {
                viewModel.undo()
                viewModel.rescan()
            }
            .buttonStyle(SecondaryButtonStyle())
            Button("Editar") { productToEdit = product }
                .buttonStyle(SecondaryButtonStyle())
            Button("Ver detalle") { detail = viewModel.scannedProduct }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(viewModel.scannedProduct == nil)
            Button("Escanear otro") { viewModel.rescan() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .cardStyle()
    }

    private func productImage(_ url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Image(systemName: "photo")
                    .foregroundStyle(CooklyTheme.brandForeground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CooklyTheme.canvas)
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))
    }

    private var manualCard: some View {
        Group {
            if cameraBlocked {
                VStack(alignment: .leading, spacing: CooklyTheme.space12) {
                    SectionHeader(title: "¿No escanea? Ingresa el código")
                    manualFields
                }
                .cardStyle()
            } else {
                DisclosureGroup(isExpanded: $manualOpen) {
                    manualFields
                        .padding(.top, CooklyTheme.space8)
                } label: {
                    Text("¿No escanea? Ingresa el código")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CooklyTheme.ink)
                }
                .cardStyle()
            }
        }
    }

    private var manualFields: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space8) {
            TextField("Código de barras", text: $manualCode)
                .keyboardType(.numberPad)
                .focused($manualFocused)
                .cooklyField()
            Text("Prueba con 3017624010701")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let manualError {
                Text(manualError)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(CooklyTheme.danger)
            }
            Button("Buscar y agregar", action: submitManual)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!manualValid)
                .opacity(manualValid ? 1 : 0.45)
        }
    }

    private var manualValid: Bool {
        let code = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
        return code.allSatisfy(\.isNumber) && (8...14).contains(code.count)
    }

    private func submitManual() {
        let code = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.allSatisfy(\.isNumber), (8...14).contains(code.count) else {
            manualError = "El código debe tener entre 8 y 14 dígitos."
            return
        }
        manualError = nil
        manualFocused = false
        viewModel.handle(code: code)
    }

    private var needsDetails: Binding<Bool> {
        Binding(
            get: { if case .needsDetails = viewModel.state { true } else { false } },
            set: { if !$0 { viewModel.rescan() } }
        )
    }
}

private struct ScanFrame: View {
    @State private var lowered = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(CooklyTheme.brandGradient, lineWidth: 4)
            Capsule()
                .fill(CooklyTheme.brandGradient)
                .frame(height: 3)
                .padding(.horizontal, 16)
                .offset(y: lowered ? 70 : -70)
        }
        .frame(width: 250, height: 168)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                lowered = true
            }
        }
        .accessibilityHidden(true)
    }
}
