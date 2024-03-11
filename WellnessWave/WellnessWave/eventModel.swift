//
//  eventModel.swift
//  WellnessWave
//
//  Created by Ho sun Song on 3/3/24.
//

import Foundation

struct Event: CustomStringConvertible {
    let startDate: Date
    let endDate: Date
    let duration: Int
    let title: String // Include the title of the event
    
    init?(dictionary: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Use a fixed locale for parsing
        
        if let startDateStr = dictionary["startDate"] as? String, // Ensure keys match your format
           let endDateStr = dictionary["endDate"] as? String,
           let startDate = dateFormatter.date(from: startDateStr),
           let endDate = dateFormatter.date(from: endDateStr),
           let duration = dictionary["duration"] as? Int,
           let title = dictionary["title"] as? String { // Parse the title
            
            self.startDate = startDate
            self.endDate = endDate
            self.duration = duration
            self.title = title // Assign the title
        } else {
            return nil
        }
    }
    
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formattedStartDate = dateFormatter.string(from: startDate)
        let formattedEndDate = dateFormatter.string(from: endDate)
        
        // Include the title in the event's description
        return "Title: \(title), starts at: \(formattedStartDate), ends at: \(formattedEndDate), duration: \(duration) minutes"
    }
}
