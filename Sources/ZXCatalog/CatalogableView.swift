//
//  ZXCatalog
//  Created by Mauricio Zaquia on 02/01/2025.
//  

import SFSafeSymbols
import SwiftUI

struct CatalogableView<C: Catalogable>: View {
    let catalogable: C

    @State var useFixedWidth: Bool = true
    @State var flipColorScheme: Bool = false
    @State var hideControls: Bool = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(ImageResource.canvas)
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView(useFixedWidth ? [.vertical] : [.horizontal, .vertical]) {
                        HStack(spacing: .zero) {
                            catalogable.sample
                                .padding()
                                .frame(minHeight: geometry.size.height)
                                .frame(minWidth: useFixedWidth ? geometry.size.width : nil)
                        }
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                HStack {
                    SwiftUI.Button {
                        useFixedWidth.toggle()
                    } label: {
                        Image(systemSymbol: .arrowtriangleRightAndLineVerticalAndArrowtriangleLeft)
                            .foregroundStyle(useFixedWidth ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }

                    SwiftUI.Button {
                        withAnimation {
                            flipColorScheme.toggle()
                        }
                    } label: {
                        Image(
                            systemSymbol: {
                                switch (colorScheme, flipColorScheme) {
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
                            hideControls.toggle()
                        }
                    } label: {
                        Image(systemSymbol: .arrowDown)
                            .rotationEffect(hideControls ? .degrees(180) : .zero)
                    }
                }
                .padding([.bottom, .horizontal])
            }
            .frame(maxHeight: .infinity)
            .colorScheme(flipColorScheme ? colorScheme.flipped : colorScheme)

            List {
                Section("Controls") {
                    ForEach(catalogable.controls, id: \.title) { control in
                        AnyView(control)
                    }
                }
            }
            .allowsHitTesting(!hideControls)
            .frame(maxHeight: hideControls ? .zero : .infinity)
        }
    }
}
