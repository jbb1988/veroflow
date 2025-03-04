import Network

class Connectivity {
    static let shared = Connectivity()
    private let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            self.status = path.status
        }
        monitor.start(queue: DispatchQueue.global())
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
