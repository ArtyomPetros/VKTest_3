import Foundation

// Протокол для управления календарем
protocol ICalendarManager {
    var isLoading: Bool { get set }
    var schedule: [Date: [CalendarModel]] { get set }
    var currentDay: Date { get set }
    var currentWeek: [Date] { get set }
    var group: String { get set }
    
    func fetchSchedule(forGroup group: String)
    func refreshData()
}

// Реализация управления календарем
class CalendarManager: ObservableObject, ICalendarManager {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var schedule: [Date: [CalendarModel]] = [:]
    @Published var currentDay: Date = Date()
    @Published var currentWeek: [Date] = []
    @Published var group: String = "ПМ22-5" {
        didSet {
            storeGroupInUserDefaults(group)
        }
    }
    // MARK: - Dependencies
        private let dateUtilityFunctions: IDateUtilityFunctions
    // MARK: - Initialization
    init(userDefaultsManager: IUserDefaultsManager, dateUtilityFunctions: IDateUtilityFunctions) {
            self.userDefaultsManager = userDefaultsManager
            self.dateUtilityFunctions = dateUtilityFunctions

            if let storedSchedule = retrieveScheduleFromUserDefaults() {
                self.schedule = storedSchedule
            }
            fetchSchedule(forGroup: group)
            self.group = retrieveGroupFromUserDefaults() ?? "ПМ22-5"
        }
    
    // MARK: - UserDefaults
    private var userDefaultsManager: IUserDefaultsManager = UserDefaultsManager()

    private func storeGroupInUserDefaults(_ group: String) {
        userDefaultsManager.storeGroupInUserDefaults(group)
    }

    private func retrieveGroupFromUserDefaults() -> String? {
        return userDefaultsManager.retrieveGroupFromUserDefaults()
    }
    
    func storeScheduleInUserDefaults(_ schedule: [Date: [CalendarModel]]) {
        userDefaultsManager.storeScheduleInUserDefaults(schedule)
    }

    func retrieveScheduleFromUserDefaults() -> [Date: [CalendarModel]]? {
        return userDefaultsManager.retrieveScheduleFromUserDefaults()
    }
    
    // MARK: - Schedule Fetching
      func fetchSchedule(forGroup group: String) {
          
          if let storedSchedule = retrieveScheduleFromUserDefaults() {
                  self.schedule = storedSchedule
                  
          } else { self.isLoading = true }
          let today = Date()
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          
          let number_day = 0//
          
          guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: number_day, to: today) else {
              return
          }
          
          let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: newDate))!
          let endOfWeek = Calendar.current.date(byAdding: .day, value: 30, to: startOfWeek)!
          
          // Определение дат текущей недели
          var calendar = Calendar.current
          calendar.firstWeekday = 2
          currentWeek = (0...31).compactMap {
              calendar.date(byAdding: .day, value: $0, to: startOfWeek)
          }
          
          let rightStartOfWeek = dateFormatter.string(from: (startOfWeek)).replacingOccurrences(of: "-", with: ".")
          let rightEndOfWeek = dateFormatter.string(from: endOfWeek).replacingOccurrences(of: "-", with: ".")
          
          let groupUppercase = group.uppercased()
          
          let searchUrl = URL(string: "https://ruz.fa.ru/api/search?term=\(groupUppercase)&type=group")!
          URLSession.shared.dataTask(with: searchUrl) { data, _, _ in
              if let data = data, let decoderData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]], let firstData = decoderData.first, let groupCode = firstData["id"] as? String {
                  
                  let scheduleUrl = URL(string: "https://ruz.fa.ru/api/schedule/group/\(groupCode)?start=\(rightStartOfWeek)&finish=\(rightEndOfWeek)&lng=1")!
                  
                  URLSession.shared.dataTask(with: scheduleUrl) { data, _, _ in
                      if let data = data, let scheduleData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                          var result: [Date: [CalendarModel]] = [:]
                          let entryDateFormatter = DateFormatter()
                          entryDateFormatter.dateFormat = "yyyy.MM.dd"
                          for entry in scheduleData {
                              
                              if let dateString = entry["date"] as? String, let entryDate = entryDateFormatter.date(from: dateString) {
                                  
                                  let lecturerTitle = self.handleVacancy(lecturerName: entry["lecturer_title"] as! String)
                                  
                                  let scheduleEntry = CalendarModel(
                                      lessonNumberStart: entry["lessonNumberStart"] as! Int,
                                      discipline: entry["discipline"] as! String,
                                      kindOfWork: entry["kindOfWork"] as! String,
                                      beginLesson: entry["beginLesson"] as! String,
                                      endLesson: entry["endLesson"] as! String,
                                      lecturer_title: lecturerTitle,
                                      auditorium: entry["auditorium"] as! String,
                                      date: entryDate
                                  )
                                  result[entryDate, default: []].append(scheduleEntry)
                              }
                          }
                          DispatchQueue.main.async {
                                      self.isLoading = false
                                      let sortedArray = result.sorted(by: { $0.key < $1.key })
                                      self.schedule = Dictionary(uniqueKeysWithValues: sortedArray)
                                      self.storeScheduleInUserDefaults(self.schedule)
                                  }
                          
                          
                      }
                      
                  }.resume()
              }
          }.resume()
      }

    // MARK: - Utility Functions
    private let helperFunctions: IDateUtilityFunctions = DateUtilityFunctions()

    func extractDate(date: Date, format: String) -> String {
        return helperFunctions.extractDate(date: date, format: format)
    }
    
    func isToday(date: Date) -> Bool {
        return helperFunctions.isToday(date: date, currentDay: currentDay)
    }
    
    func isCurrentHourForLesson(_ lesson: CalendarModel) -> Bool {
        return helperFunctions.isCurrentHourForLesson(lesson)
    }
    
    // MARK: - Data Refresh
    func refreshData() {
        fetchSchedule(forGroup: group)
    }
}
