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
    @IBOutlet weak var thisWeekEmotionLabel: UILabel!
    @IBOutlet weak var lastWeekEmotionLabel: UILabel!
    
    @IBOutlet weak var emotionChartView: BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTopEmotions()
        setupBarChart()
    }
    
    func displayTopEmotions() {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let dates = weekDates()
        
        let thisWeekEmotions = fetchEmotionCounts(from: dates.thisWeek.from, to: dates.thisWeek.to)
        let lastWeekEmotions = fetchEmotionCounts(from: dates.lastWeek.from, to: dates.lastWeek.to)
        
        let thisWeekTopEmotion = topEmotion(from: thisWeekEmotions)
        let lastWeekTopEmotion = topEmotion(from: lastWeekEmotions)
        
        thisWeekEmojiLabel.text = emoji(emotion: thisWeekTopEmotion)
        lastWeekEmojiLabel.text = emoji(emotion: lastWeekTopEmotion)
        
        // クラスのラベルを表示するためのコード
        thisWeekEmotionLabel.text = thisWeekTopEmotion
        lastWeekEmotionLabel.text = lastWeekTopEmotion
        
        let endTime = CFAbsoluteTimeGetCurrent()  // 処理終了時刻
        let elapsedTime = endTime - startTime
        print("Elapsed time for displaying top emotions: \(elapsedTime) seconds")
    }
    
    func setupBarChart() {
        
        let startTime = CFAbsoluteTimeGetCurrent()  // 処理開始時刻
        
        let dates = last30Days()  // 修正された関数を使用
        let emotions = fetchEmotionCounts(from: dates.from, to: dates.to)
        var dataEntries: [BarChartDataEntry] = []
        var emotionNames: [String] = []
        
        var highestEmotionCount = 0.0 // 最も高い感情の出現回数を保存する変数
        
        for (index, emotion) in emotions.enumerated() {
            let emotionName = emotion.key
            let emotionCount = emotion.value
            let normalizedCount = (Double(emotionCount) / 30.0) * 100 // 値を100倍
            if normalizedCount > highestEmotionCount { // 最も高い感情の出現回数を更新
                highestEmotionCount = normalizedCount
            }
            let dataEntry = BarChartDataEntry(x: Double(index), y: normalizedCount)
            dataEntries.append(dataEntry)
            emotionNames.append(emotionName)
        }
        
        // Y軸の最大値を最も高い感情の出現回数に合わせる
        emotionChartView.leftAxis.axisMaximum = highestEmotionCount + 5.0  // 少し余裕を持たせるために+5を加える
        
        let dataSet = BarChartDataSet(entries: dataEntries, label: "The Proportions of Each Emotions Over the Past 30 Days")
        let data = BarChartData(dataSet: dataSet)
        emotionChartView.data = data

        // X軸のラベルとして感情のクラスの名前を設定します
        emotionChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: emotionNames)
        emotionChartView.xAxis.granularity = 1
        emotionChartView.xAxis.labelPosition = .bottomInside
        
        // Y軸のラベルを表示
//        emotionChartView.leftAxis.axisMaximum = 100.0
        emotionChartView.rightAxis.enabled = false
        
        // グリッドラインを非表示にする
        emotionChartView.xAxis.drawGridLinesEnabled = false
        emotionChartView.leftAxis.drawGridLinesEnabled = false
        
        emotionChartView.notifyDataSetChanged()
        
        let endTime = CFAbsoluteTimeGetCurrent()  // 処理終了時刻
        let elapsedTime = endTime - startTime
        print("Elapsed time for setting up chart: \(elapsedTime) seconds")
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
    
//    func monthDates() -> (from: Date, to: Date) {
//        let calendar = Calendar.current
//        let now = Date()
//
//        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
//        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
//
//        return (from: startOfMonth, to: endOfMonth)
//    }
    
    func last30Days() -> (from: Date, to: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        
        return (from: thirtyDaysAgo, to: now)
    }
    
    func fetchEmotionCounts(from startDate: Date, to endDate: Date) -> [String: Int] {
        let startTime = CFAbsoluteTimeGetCurrent()  // 処理開始時刻
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        fetchRequest.predicate = NSPredicate(format: "(dayCreated >= %@) AND (dayCreated <= %@)", startDate as NSDate, endDate as NSDate)
        
        var emotionCounts: [String: Int] = ["Sadness": 0, "Fear": 0, "Joy": 0, "Surprise": 0, "Anger": 0, "Love": 0]
        
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
        
        let endTime = CFAbsoluteTimeGetCurrent()  // 処理終了時刻
        let elapsedTime = endTime - startTime
        print("Elapsed time for fetching data: \(elapsedTime) seconds")
        
        return emotionCounts
    }
    
    func topEmotion(from counts: [String: Int]) -> String {
        return counts.max(by: { a, b in a.value < b.value })?.key ?? ""
    }
    
    func emoji(emotion: String) -> String {
        switch emotion {
        case "Love":
            return "🥰"
        case "Fear":
            return "😨"
        case "Joy":
            return "😄"
        case "Sadness":
            return "😢"
        case "Surprise":
            return "😲"
        case "Anger":
            return "😡"
        default:
            return "❓"
        }
    }

}
