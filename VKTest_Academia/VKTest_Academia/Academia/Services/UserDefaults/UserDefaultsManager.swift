import Foundation

// Протокол для управления UserDefaults
protocol IUserDefaultsManager {
    func storeGroupInUserDefaults(_ group: String)
    func retrieveGroupFromUserDefaults() -> String?
    func storeScheduleInUserDefaults(_ schedule: [Date: [CalendarModel]])
    func retrieveScheduleFromUserDefaults() -> [Date: [CalendarModel]]?
}

// Реализация управления UserDefaults
class UserDefaultsManager: IUserDefaultsManager {
    let scheduleUserDefaultsKey = "storedSchedule"
    let groupUserDefaultsKey = "storedGroup"

    func storeGroupInUserDefaults(_ group: String) {
        UserDefaults.standard.set(group, forKey: groupUserDefaultsKey)
    }

    func retrieveGroupFromUserDefaults() -> String? {
        return UserDefaults.standard.string(forKey: groupUserDefaultsKey)
    }
    
    func storeScheduleInUserDefaults(_ schedule: [Date: [CalendarModel]]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(schedule) {
            UserDefaults.standard.set(encodedData, forKey: scheduleUserDefaultsKey)
        }
    }

    func retrieveScheduleFromUserDefaults() -> [Date: [CalendarModel]]? {
        if let storedData = UserDefaults.standard.data(forKey: scheduleUserDefaultsKey) {
            let decoder = JSONDecoder()
            if let storedSchedule = try? decoder.decode([Date: [CalendarModel]].self, from: storedData) {
                return storedSchedule
            }
        }
        return nil
    }
}
