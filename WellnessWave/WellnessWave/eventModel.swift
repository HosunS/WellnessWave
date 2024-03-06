//
//  eventModel.swift
//  WellnessWave
//
//  Created by Ho sun Song on 3/3/24.
//

import Foundation

struct Event {
    var title: String
    var startDate: Date
    var endDate: Date
    var duration: Int
    var isAllDay: Bool
    var dayOfWeek: String
    
    init?(dictionary: [String: Any]) {
        guard let title = dictionary["title"] as? String,
              let startDateStr = dictionary["startDate"] as? String,
              let endDateStr = dictionary["endDate"] as? String,
              let duration = dictionary["duration"] as? Int,
              let isAllDay = dictionary["isAllDay"] as? Bool,
              let dayOfWeek = dictionary["dayOfWeek"] as? String,
              let startDate = Event.dateFormatter.date(from: startDateStr),
              let endDate = Event.dateFormatter.date(from: endDateStr) else {
            return nil
        }
        
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.isAllDay = isAllDay
        self.dayOfWeek = dayOfWeek
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
}
