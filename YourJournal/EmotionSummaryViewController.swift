//
//  EmotionSummaryViewController.swift
//  YourJournal
//
//  Created by 大川裕平 on 26/08/2023.
//

import UIKit
import CoreData
import Charts // 追加

class EmotionSummaryViewController: UIViewController {
    
    @IBOutlet weak var thisWeekEmojiLabel: UILabel!
    @IBOutlet weak var lastWeekEmojiLabel: UILabel!
    @IBOutlet weak var emotionChartView: BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTopEmotions()
        setupBarChart()
    }
    
    func displayTopEmotions() {
        let dates = weekDates()
            
            let thisWeekEmotions = fetchEmotionCounts(from: dates.thisWeek.from, to: dates.thisWeek.to)
            let lastWeekEmotions = fetchEmotionCounts(from: dates.lastWeek.from, to: dates.lastWeek.to)
            
            let thisWeekTopEmotion = topEmotion(from: thisWeekEmotions)
            let lastWeekTopEmotion = topEmotion(from: lastWeekEmotions)
            
        thisWeekEmojiLabel.text = emoji(emotion: thisWeekTopEmotion)
        lastWeekEmojiLabel.text = emoji(emotion: lastWeekTopEmotion)
    }
    
    func setupBarChart() {
        let dates = monthDates()
        let emotions = fetchEmotionCounts(from: dates.from, to: dates.to)
        var dataEntries: [BarChartDataEntry] = []
        
        for (index, emotion) in emotions.enumerated() {
            let emotionName = emotion.key
            let emotionCount = emotion.value
            let dataEntry = BarChartDataEntry(x: Double(index), y: Double(emotionCount) / 30.0)
            dataEntries.append(dataEntry)
        }
        
        let dataSet = BarChartDataSet(entries: dataEntries, label: "Emotions")
        let data = BarChartData(dataSet: dataSet)
        emotionChartView.data = data
    }
    
    
    
    // 以下はサポート関数やデータのフェッチ、絵文字のマッピングなど...
    
    func weekDates() -> (thisWeek: (from: Date, to: Date), lastWeek: (from: Date, to: Date)) {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfThisWeek = calendar.date(byAdding: .day, value: 6, to: startOfThisWeek)!
        
        let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek)!
        let endOfLastWeek = calendar.date(byAdding: .day, value: 6, to: startOfLastWeek)!
        
        return (thisWeek: (startOfThisWeek, endOfThisWeek), lastWeek: (startOfLastWeek, endOfLastWeek))
    }
    
    func monthDates() -> (from: Date, to: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        return (from: startOfMonth, to: endOfMonth)
    }
    
    func fetchEmotionCounts(from startDate: Date, to endDate: Date) -> [String: Int] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        fetchRequest.predicate = NSPredicate(format: "(dayCreated >= %@) AND (dayCreated <= %@)", startDate as NSDate, endDate as NSDate)
        
        var emotionCounts: [String: Int] = ["期待": 0, "恐れ": 0, "喜び": 0, "嫌悪": 0, "信頼": 0, "悲しみ": 0, "驚き": 0, "怒り": 0]
        
        do {
            let results = try context.fetch(fetchRequest)
            for journal in results {
                if let emotion = journal.emotionResult {
                    emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1
                }
            }
        } catch {
            print("Error fetching journals: \(error)")
        }
        
        return emotionCounts
    }
    
    func topEmotion(from counts: [String: Int]) -> String {
        return counts.max(by: { a, b in a.value < b.value })?.key ?? ""
    }
    
    func emoji(emotion: String) -> String {
        switch emotion {
        case "期待":
            return "😊" // 期待に対する顔文字
        case "恐れ":
            return "😨"
        case "喜び":
            return "😄"
        case "嫌悪":
            return "😠"
        case "信頼":
            return "🤝"
        case "悲しみ":
            return "😢"
        case "驚き":
            return "😲"
        case "怒り":
            return "😡"
        default:
            return "❓"
        }
    }

}
