import Foundation

// Протокол для работы с ServerAPI
protocol IServerAPI {
    func fetchNews(completion: @escaping ([HomeModel]?) -> Void)
}

// Реализация работы с ServerAPI
class ServerAPI: IServerAPI {
    let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func fetchNews(completion: @escaping ([HomeModel]?) -> Void) {
        guard let url = URL(string: baseURL + "/v3/articles") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let news = try JSONDecoder().decode([HomeModel].self, from: data)
                completion(news)
            } catch {
                print(error)
                completion(nil)
            }
        }
        
        task.resume()
    }
}
