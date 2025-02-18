import Foundation
import Network
import Combine

class ConnectivityMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue(label: "ConnectivityMonitor")

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

