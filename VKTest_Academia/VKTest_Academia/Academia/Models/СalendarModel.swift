import UIKit
import Combine

struct CalendarModel: Identifiable, Codable {
    var id: String {
        "\(lessonNumberStart)-\(date)-\(discipline)"
    }
    let lessonNumberStart: Int
    let discipline: String
    let kindOfWork: String
    let beginLesson: String
    let endLesson: String
    var lecturer_title: String
    let auditorium: String
    let date: Date
}



