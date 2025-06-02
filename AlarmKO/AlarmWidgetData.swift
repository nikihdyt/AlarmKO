import Foundation

struct AlarmWidgetData {
    let wakeUpTime: DateComponents
    
    static func loadWakeUpTimeDateComponent() -> DateComponents {
        let sharedDefaults = UserDefaults(suiteName: "group.com.AlarmKO")
        
        let hour = sharedDefaults?.integer(forKey: "widgetWakeHour") ?? 8
        let minute = sharedDefaults?.integer(forKey: "widgetWakeMinute") ?? 0
        
        return DateComponents(hour: hour, minute: minute)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        if let date = calendar.date(from: wakeUpTime) {
            return formatter.string(from: date)
        }
        return "8:00 AM"
    }
}
