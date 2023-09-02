//
//  ViewController.swift
//  YourJournal
//
//  Created by 大川裕平 on 08/08/2023.
//

import UIKit
import CoreData
import CoreML

class JouranlDetailVC: UIViewController {
    
    // 新しく追加
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var selectedJournal: Journal? = nil
    
    // Create MLモデルのインスタンスを作成
    let model = try! EnglishEmotionDetectionModel(configuration: MLModelConfiguration())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIDatePickerのモードを日付のみに設定
        datePicker.datePickerMode = .date
        
        // UIDatePickerの最大日付を今日に設定
        datePicker.maximumDate = Date()
        
        
        if let journal = selectedJournal {
            datePicker.date = journal.dayCreated ?? Date()
            descTV.text = journal.desc
            
            if let emotion = journal.emotionResult {
                let emoji = emotionToEmoji(emotion: emotion)
                resultLabel.text = "\(emotion) \(emoji)"
            }
            
        }
    }
    
    @IBAction func analyzeButtonPressed(_ sender: Any) {
        
        guard let inputText = descTV.text else { return }
        
        // テキストをモデルに入力して予測を取得
        let input = EnglishEmotionDetectionModelInput(text: inputText)
        
        
        guard let output = try? model.prediction(input: input) else {
            resultLabel.text = "Analysis failed."
            return
        }
        
        // 予測結果をラベルに表示
        let emotion = "\(output.label)"
        selectedJournal?.emotionResult = emotion // 結果を保存
        let emoji = emotionToEmoji(emotion: emotion)
        resultLabel.text = "\(emotion) \(emoji)" // ラベルと顔文字を一緒に表示
        
    }
    
    
    func emotionToEmoji(emotion: String) -> String {
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

    
    @IBAction func saveAction(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if selectedJournal == nil {
            let entity = NSEntityDescription.entity(forEntityName: "Journal", in: context)
            let newJournal = Journal(entity: entity!, insertInto: context)
            newJournal.id = journalList.count as NSNumber
            newJournal.dayCreated = datePicker.date // UIDatePickerから日付を取得して保存
            newJournal.desc = descTV.text
            
            do {
                try context.save()
                journalList.append(newJournal)
                navigationController?.popViewController(animated: true)
            } catch {
                print("save error.")
            }
        } else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let journal = result as! Journal
                    if journal == selectedJournal {
                        journal.dayCreated = datePicker.date
                        journal.desc = descTV.text
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("Fetch failed.")
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal")
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                let journal = result as! Journal
                if(journal == selectedJournal) {
                    journal.dateDeleted = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Fetch failed.")
        }
    }
    
}

