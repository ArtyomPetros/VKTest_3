import Foundation

protocol IDateUtilityFunctions {
    func extractDate(date: Date, format: String) -> String
    func isToday(date: Date, currentDay: Date) -> Bool
    func isCurrentHourForLesson(_ lesson: CalendarModel) -> Bool
}

// Реализация функций работы с DateUtilityFunctions
class DateUtilityFunctions: IDateUtilityFunctions {
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func isToday(date: Date, currentDay: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    func isCurrentHourForLesson(_ lesson: CalendarModel) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        guard let startDate = dateFormatter.date(from: "\(self.extractDate(date: lesson.date, format: "yyyy.MM.dd")) \(lesson.beginLesson)"),
              let endDate = dateFormatter.date(from: "\(self.extractDate(date: lesson.date, format: "yyyy.MM.dd")) \(lesson.endLesson)") else {
            return false
        }
        
        let now = Date()
        return now >= startDate && now <= endDate
    }
}
