import Swinject

class ServerAPIBuilder {
    private var baseURL: String?

    func setBaseURL(_ url: String) -> ServerAPIBuilder {
        self.baseURL = url
        return self
    }

    func build() -> ServerAPI? {
        guard let baseURL = self.baseURL else {
            return nil
        }
        return ServerAPI(baseURL: baseURL)
    }
    
    // Метод для регистрации IServerAPI в контейнере
    func registerServerAPI(in container: Container) {
        container.register(IServerAPI.self) { _ in
            return self.build()!
        }
    }
}
