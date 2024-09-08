import SwiftUI

struct Home: View {
    @StateObject var vm: HomeViewModel

    init() {
        let serverAPI = ServerAPIBuilder()
            .setBaseURL("https://ruz.fa.ru/api")
            .build()
        
        _vm = StateObject(wrappedValue: HomeViewModel(serverAPI: serverAPI!))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.news, id: \.id) { news in
                    Text(news.title)
                }
            }
            .task {
                vm.fetchData()
            }
        }
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
