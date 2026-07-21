import SwiftUI

struct ContentView: View {

  @StateObject private var viewModel = DashboardViewModel()
  @State private var selectedTab: Tab = .dashboard

  enum Tab {
    case dashboard
    case arView
  }

  var body: some View {
    TabView(selection: $selectedTab) {

      DashboardView(viewModel: viewModel)
        .tabItem {
          Label("Dashboard", systemImage: "chart.bar")
        }
        .tag(Tab.dashboard)

      ARTabContent(viewModel: viewModel, isActive: selectedTab == .arView)
        .tabItem {
          Label("AR Field View", systemImage: "arkit")
        }
        .tag(Tab.arView)
    }
  }
}

/// Wraps ARFarmView so the AR session only exists while this tab is
/// actually selected — TabView keeps all tab content alive in memory,
/// so without this guard the camera would start on launch and keep
/// running in the background even while viewing the Dashboard tab.
struct ARTabContent: View {
  let viewModel: DashboardViewModel
  let isActive: Bool

  var body: some View {
    if isActive {
      ARFarmView(viewModel: viewModel)
    } else {
      Color.black
        .ignoresSafeArea()
    }
  }
}
