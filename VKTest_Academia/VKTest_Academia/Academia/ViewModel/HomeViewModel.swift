import Foundation
class HomeViewModel: ObservableObject {
    @Published var news: [HomeModel] = []
    
    private let serverAPI: ServerAPI
    
    init(serverAPI: ServerAPI) {
        self.serverAPI = serverAPI
    }
    
    func fetchData() {
        serverAPI.fetchNews { [weak self] news in
            if let news = news {
                DispatchQueue.main.async {
                    self?.news = news
                }
            }
        }
    }
}


