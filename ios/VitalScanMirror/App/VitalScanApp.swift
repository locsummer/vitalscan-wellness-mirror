import SwiftUI

@main
struct VitalScanApp: App {
    var body: some Scene {
        WindowGroup {
            MirrorScanView()
                .preferredColorScheme(.dark)
        }
    }
}
