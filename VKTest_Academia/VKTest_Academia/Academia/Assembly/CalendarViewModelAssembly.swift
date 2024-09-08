import Foundation

class CalendarViewModelAssembly {
    let userDefaultsManager: IUserDefaultsManager
    let dateUtilityFunctions: IDateUtilityFunctions

    init() {
       
        self.userDefaultsManager = UserDefaultsManager()
        self.dateUtilityFunctions = DateUtilityFunctions()
    }

    
    func assembleCalendarManager() -> ICalendarManager {
        return CalendarManager(userDefaultsManager: userDefaultsManager, dateUtilityFunctions: dateUtilityFunctions)
    }
}
