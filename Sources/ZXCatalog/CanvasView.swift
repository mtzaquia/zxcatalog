//
//  ZXCatalog
//  Created by Mauricio Zaquia on 16/01/2025.
//  

import SwiftUI

struct CanvasOptions {
    var usesFixedWidth: Bool = false
    var shouldFlipColorScheme: Bool = false
}

struct CanvasView<C: Catalogable>: View {
    let catalogable: C

    @Binding var isShowingControls: Bool

    @State private var options: CanvasOptions = CanvasOptions()
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            Image("canvas", bundle: .module)
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                ScrollView {
                    catalogable.sample
                        .padding()
                        .frame(minHeight: proxy.size.height)
                        .fixedSize(horizontal: options.usesFixedWidth, vertical: false)
                        .frame(maxWidth: proxy.size.width)
                }
                .frame(maxWidth: proxy.size.width)
            }
        }
        .overlay(alignment: .bottomLeading) {
            HStack {
                SwiftUI.Button {
                    options.usesFixedWidth.toggle()
                } label: {
                    Image(systemSymbol: .arrowtriangleRightAndLineVerticalAndArrowtriangleLeft)
                        .foregroundStyle(options.usesFixedWidth ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                }
                
                SwiftUI.Button {
                    withAnimation {
                        options.shouldFlipColorScheme.toggle()
                    }
                } label: {
                    Image(
                        systemSymbol: {
                            switch (colorScheme, options.shouldFlipColorScheme) {
                            case (.dark, false), (.light, true): .moonZzz
                            case (.light, false), (.dark, true): .sunMax
                            default: .questionmarkApp
                            }
                        }()
                    )
                }

                Spacer()

                SwiftUI.Button {
                    withAnimation {
                        isShowingControls.toggle()
                    }
                } label: {
                    Image(systemSymbol: isShowingControls ? .arrowDown : .arrowUp)
                }
            }
            .padding([.bottom, .horizontal])
        }
        .colorScheme(options.shouldFlipColorScheme ? colorScheme.flipped : colorScheme)
    }
    
    init(catalogable: C, isShowingControls: Binding<Bool>) {
        self.catalogable = catalogable
        self._isShowingControls = isShowingControls
    }
}
