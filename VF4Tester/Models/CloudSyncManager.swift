import Foundation

// CloudSyncManager uses the TestResult type defined in Types.swift.
class CloudSyncManager {
    static let shared = CloudSyncManager()
    
    func saveToCloud(testResults: [TestResult]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(testResults) {
            UserDefaults(suiteName: "group.com.yourapp.icloud")?.set(data, forKey: "testResults")
        }
    }
    
    func loadFromCloud() -> [TestResult] {
        if let data = UserDefaults(suiteName: "group.com.yourapp.icloud")?.data(forKey: "testResults") {
            let decoder = JSONDecoder()
            return (try? decoder.decode([TestResult].self, from: data)) ?? []
        }
        return []
    }
}

