import SwiftUI

struct ContentView: View {
    let userDefaultsManager = UserDefaultsManager()
    let dateUtilityFunctions = DateUtilityFunctions()
    @State private var swipeDirection: SwipeDirection = .none
    enum SwipeDirection {
        case none, left, right
    }
    @State private var groupNumber: String = ""
    @State private var showKindOfWorkFor: String? = nil
    @State private var selectedEntryID: String?
    
    @ObservedObject var fetcher: CalendarManager
    init() {
           self.fetcher = CalendarManager(userDefaultsManager: userDefaultsManager, dateUtilityFunctions: dateUtilityFunctions)
       }
    
    @State var userProfilePicData: Data?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    @State private var targetDate: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDateAsString = formatter.string(from: Date())
        return formatter.date(from: currentDateAsString)!
    }()
    
    
    @Environment(\.colorScheme) var colorScheme
    
    private var newMessageButtonColor: Color {
        return colorScheme == .dark ? Color("LightG") : Color("HomeBG")
    }
    
    @Environment(\.colorScheme) var colorSchemeR
    
    private var newMessageButtonColorRevers: Color {
        return colorSchemeR == .dark ? Color("HomeBG") : Color("LightG")
    }
    
    @Namespace var animation
    
    @available(iOS 16.0, *)
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            headerView()
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 15){
                        ForEach(fetcher.currentWeek, id: \.self) { day in
                            VStack(spacing: 10){
                                Text(fetcher.extractDate(date: day, format: "dd"))
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(day == targetDate ? (colorScheme == .dark ? .black : .white) : .gray)
                                
                                Text(fetcher.extractDate(date: day, format: "EEE"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(day == targetDate ? (colorScheme == .dark ? .black : .white) : .gray)
                            }
                            .foregroundStyle(fetcher.isToday(date: day) ? .primary : .tertiary)
                            .foregroundColor(fetcher.isToday(date: day) ? .white : .black)
                            .frame(width: 45, height: 70)
                            .background(
                                ZStack{
                                    if day == targetDate {
                                        RoundedRectangle(cornerRadius: 15, style: .continuous )
                                            .fill(newMessageButtonColor)
                                            .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                    }
                                }
                            )
                            .contentShape(Capsule())
                            .id(day)
                            .onTapGesture{
                                withAnimation(.interpolatingSpring){
                                    fetcher.currentDay = day
                                    targetDate = fetcher.currentDay
                                    selectedEntryID = nil
                                    showKindOfWorkFor = nil
                                    proxy.scrollTo(day, anchor: .center)
                                }
                                
                                playHapticFeedback()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: targetDate) { newTargetDate in
                        // Прокрутите к новому целевому дню при изменении targetDate
                        withAnimation {
                        proxy.scrollTo(newTargetDate, anchor: .center)
                        }
                    }
            }
            
            VStack {
                if fetcher.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Подождите, мы уже \nизучаем ваше расписание:)")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    
                } else if let lessonsForTargetDate = fetcher.schedule[targetDate] {
                    let mergedEntries = fetcher.mergeScheduleEntries(lessonsForTargetDate)
                    ForEach(mergedEntries, id: \.id) { entry in
                        HStack(alignment: .top, spacing: 30){
                            VStack(spacing: 10){
                                Circle()
                                    .fill(fetcher.isCurrentHourForLesson(entry) ? newMessageButtonColor : .clear)
                                    .frame(width: 15, height: 15)
                                    .background(
                                        Circle()
                                            .stroke(newMessageButtonColor, lineWidth: 1)
                                            .padding(-3)
                                    )
                                    .scaleEffect(fetcher.isCurrentHourForLesson(entry) ? 1 : 0.8)
                                
                                Rectangle()
                                    .fill(newMessageButtonColor)
                                    .frame(width: 3)
                            }
                            
                            VStack{
                                HStack(alignment: .top, spacing: 10){
                                    VStack(alignment: .leading, spacing: 12){
                                        HStack(alignment: .top) {
                                            Text(entry.discipline)
                                                .font(fetcher.isCurrentHourForLesson(entry) ? .title2 : .title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(fetcher.isCurrentHourForLesson(entry) ? .white : newMessageButtonColor)
                                                .lineLimit(nil)
                                                .lineLimit(3)
                                        }
                                        if showKindOfWorkFor == entry.id {
                                            Text(entry.kindOfWork)
                                                .font(.callout)
                                                .foregroundColor(fetcher.isCurrentHourForLesson(entry) ? .white.opacity(0.7) : .secondary)
                                        }
                                        Text(entry.auditorium)
                                            .padding(.top, 3)
                                            .font(.callout)
                                            .foregroundStyle(fetcher.isCurrentHourForLesson(entry) ? .white : .secondary)
                                        Text(entry.lecturer_title)
                                            .font(.callout)
                                            .foregroundStyle(fetcher.isCurrentHourForLesson(entry) ? .white.opacity(0.7) : .secondary)
                                        Text("\(entry.beginLesson) - \(entry.endLesson)")
                                            .font(fetcher.isCurrentHourForLesson(entry) ? .title : .callout)
                                            .foregroundStyle(fetcher.isCurrentHourForLesson(entry) ? .white : .secondary)
                                            .fontWeight(fetcher.isCurrentHourForLesson(entry) ? .bold : .regular)
                                    }
                                    .hLeading()
                                }
                            }
                            
                            .foregroundColor(fetcher.isCurrentHourForLesson(entry) ? newMessageButtonColorRevers : newMessageButtonColor)
                            .padding(fetcher.isCurrentHourForLesson(entry) ? 15: 0)
                            .padding(.bottom, fetcher.isCurrentHourForLesson(entry) ? 0 : 10)
                            .padding(selectedEntryID == entry.id ? 15: 0)
                            .padding(.bottom, selectedEntryID == entry.id ? 0 : 10)
                            .hLeading()
                            .background(selectedEntryID == entry.id ? Color("Blue").opacity(0.2) : Color.clear)
                            .cornerRadius(selectedEntryID == entry.id ? 25 : 0)
                            .background(Color("Main_c").cornerRadius(25).opacity(fetcher.isCurrentHourForLesson(entry) ? 1 : 0))
                            
                            
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)){
                                if showKindOfWorkFor == entry.id {
                                    showKindOfWorkFor = nil
                                } else {
                                    playHapticFeedbackSwipe()
                                    showKindOfWorkFor = entry.id
                                }
                                
                                
                                if selectedEntryID == entry.id {
                                    selectedEntryID = nil
                                } else {
                                    selectedEntryID = entry.id
                                }
                            }
                            playHapticFeedbackKind()
                        }
                        
                        .hLeading()
                    }
                    .offset(y: 10)
                    .padding(.horizontal)
                } else {
                    VStack {
                        Image("G1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                        Text("Нет занятий")
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .foregroundColor(newMessageButtonColor)
                    }
                    .offset(y:150)
                }
            }
            
            Rectangle()
                .frame(height: 16)
                .foregroundStyle(.clear)
            
            
        }
        .padding(.bottom, 30)
        .gesture(DragGesture(minimumDistance: 50, coordinateSpace: .local)
            .onEnded { value in
                if value.translation.width < 0 {
                    withAnimation {
                        goToNextDay()
                    }
                    playHapticFeedbackSwipe()
                } else if value.translation.width > 0 {
                    withAnimation {
                        goToPreviousDay()
                    }
                    playHapticFeedbackSwipe()
                }
            }
        )
        .refreshable {
            withAnimation {
                fetcher.refreshData()
            }
        }
        .onAppear {
            fetcher.refreshData()
        }
    }
    
    func headerView() -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.gray)
                TextField("Номер группы", text: $fetcher.group)
                    .textCase(.uppercase)
                    .textInputAutocapitalization(.characters)
                    .font(.system(.largeTitle, weight: .bold))
                    .onChange(of: fetcher.group) { newValue in
                        fetcher.fetchSchedule(forGroup: newValue)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
        }
        .padding(.top)
        .padding(.horizontal)
        .zIndex(1)
        .padding(.bottom)
    }
    
    func playHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    func playHapticFeedbackKind() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func playHapticFeedbackSwipe() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    func goToNextDay() {
        swipeDirection = .left
        if let lastDay = fetcher.currentWeek.last, targetDate != lastDay {
            if let index = fetcher.currentWeek.firstIndex(of: targetDate) {
                targetDate = fetcher.currentWeek[index + 1]
                fetcher.currentDay = targetDate
                selectedEntryID = nil
                showKindOfWorkFor = nil
            }
        }
    }
    
    func goToPreviousDay() {
        swipeDirection = .right
        if let firstDay = fetcher.currentWeek.first, targetDate != firstDay {
            if let index = fetcher.currentWeek.firstIndex(of: targetDate) {
                targetDate = fetcher.currentWeek[index - 1]
                fetcher.currentDay = targetDate
                selectedEntryID = nil
                showKindOfWorkFor = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
