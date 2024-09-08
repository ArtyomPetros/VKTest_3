import SwiftUI

extension View{
    func hLeading()->some View{
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    func hTrailing()->some View{
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    func hCenter()->some View{
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func getSafeArea()->UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else{
            return.zero
        }
        return safeArea
    }
}


extension CalendarManager {
    func handleVacancy(lecturerName: String) -> String {
            if lecturerName.contains("Вакансия") {
                return "Преподаватель не назначен"
            }
            return lecturerName
        }
    func mergeScheduleEntries(_ entries: [CalendarModel]) -> [CalendarModel] {
        var mergedEntries: [CalendarModel] = []
        var alreadyProcessedNumbers: Set<Int> = []
        
        func shortenFullName(_ fullName: String) -> String? {
            let nameComponents = fullName.split(separator: " ")
            guard nameComponents.count == 3 else { return nil }
            
            let surname = nameComponents[0]
            let nameInitial = nameComponents[1].prefix(1) + "."
            let patronymicInitial = nameComponents[2].prefix(1) + "."
            
            return "\(surname) \(nameInitial) \(patronymicInitial)"
        }
        
        for entry in entries {
            if alreadyProcessedNumbers.contains(entry.lessonNumberStart) {
                continue
            }
            
            let similarTimeEntries = entries.filter { $0.lessonNumberStart == entry.lessonNumberStart }
            alreadyProcessedNumbers.insert(entry.lessonNumberStart)
            
            // Group entries by discipline
            let groupedByDiscipline = Dictionary(grouping: similarTimeEntries) { $0.discipline }
            
            for (discipline, groupedEntries) in groupedByDiscipline {
                if groupedEntries.count > 1 {
                    let kindOfWork = groupedEntries.first?.kindOfWork ?? ""
                    let beginLesson = groupedEntries.first?.beginLesson ?? ""
                    let endLesson = groupedEntries.first?.endLesson ?? ""
                    let date = groupedEntries.first?.date ?? Date()
                    
                    let lecturerAuditoriumInfo = groupedEntries.map { entry -> String in
                        let shortenedName = shortenFullName(entry.lecturer_title) ?? entry.lecturer_title
                        return "\(shortenedName) - \(entry.auditorium)\n"
                    }
                    
                    let combinedLecturerAuditorium = lecturerAuditoriumInfo.joined(separator: "")
                    
                    let combinedEntry = CalendarModel(lessonNumberStart: entry.lessonNumberStart,
                                                      discipline: discipline,
                                                      kindOfWork: kindOfWork,
                                                      beginLesson: beginLesson,
                                                      endLesson: endLesson,
                                                      lecturer_title: combinedLecturerAuditorium,
                                                      auditorium: "",
                                                      date: date)
                    mergedEntries.append(combinedEntry)
                } else {
                    mergedEntries.append(contentsOf: groupedEntries)
                }
            }
        }
        
        return mergedEntries
    }
}
