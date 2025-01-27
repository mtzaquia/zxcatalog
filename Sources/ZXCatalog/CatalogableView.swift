//
//  ZXCatalog
//  Created by Mauricio Zaquia on 02/01/2025.
//  

import SFSafeSymbols
import SwiftUI

struct CatalogableView<C: Catalogable>: View {
    let catalogable: C

    @State var isShowingControls: Bool = true

    var body: some View {
        VStack(spacing: .zero) {
            CanvasView(catalogable: catalogable, isShowingControls: $isShowingControls)
            if isShowingControls {
                List {
                    Section("Controls") {
                        ForEach(catalogable.controls, id: \.title) { control in
                            AnyView(control)
                        }
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}
