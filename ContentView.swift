//
//  ContentView.swift
//  MyFirstMap
//
//  Created by HaKaN OGUZ on 4.12.2023.
//

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct ContentView: View {
    /// A map of reported incidents in San Francisco.
      @State private var map = Map(
          item: PortalItem(
              portal: .arcGISOnline(connection: .anonymous),
              id: .incidentsInSanFrancisco
          )
      )

      /// The screen point to perform an identify operation.
      @State private var identifyScreenPoint: CGPoint?

      /// The popup to be shown as the result of the layer identify operation.
      @State private var popup: Popup?

      /// A Boolean value specifying whether the popup view should be shown or not.
      @State private var showPopup = false

      var body: some View {
          MapViewReader { proxy in
              MapView(map: map)
                  .onSingleTapGesture { screenPoint, _ in
                      identifyScreenPoint = screenPoint
                  }
                  .task(id: identifyScreenPoint) {
                      guard let identifyScreenPoint = identifyScreenPoint,
                            let identifyResult = try? await proxy.identifyLayers(
                              screenPoint: identifyScreenPoint,
                              tolerance: 12,
                              returnPopupsOnly: false
                            )
                      else { return }
                      self.popup = identifyResult.first?.popups.first
                      self.showPopup = self.popup != nil
                  }
                  .floatingPanel(
                      selectedDetent: .constant(.full),
                      horizontalAlignment: .leading,
                      isPresented: $showPopup
                  ) { [popup] in
                      PopupView(popup: popup!, isPresented: $showPopup)
                          .showCloseButton(true)
                          .padding()
                  }
          }
      }
}
    
private extension PortalItem.ID {
    /// The ID used in the "Incidents in San Francisco" portal item.
    static var incidentsInSanFrancisco: Self { Self("fb788308ea2e4d8682b9c05ef641f273")! }
}

#Preview {
    ContentView()
}
