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

    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var selectedJournal: Journal? = nil
    
    // Create MLモデルのインスタンスを作成
    let model = try! EmotionDetectionModel(configuration: MLModelConfiguration())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(selectedJournal != nil) {
            
            dateTF.text = selectedJournal?.dateCreated
            descTV.text = selectedJournal?.desc 
        }
    }

    @IBAction func analyzeButtonPressed(_ sender: Any) {
        
        guard let inputText = descTV.text else { return }
        
        // テキストをモデルに入力して予測を取得
        let input = EmotionDetectionModelInput(text: inputText)

        
        guard let output = try? model.prediction(input: input) else {
            resultLabel.text = "Analysis failed."
            return
        }
        
        // 予測結果をラベルに表示
        resultLabel.text = "\(output.label)"
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if(selectedJournal == nil) {
            
            let entity = NSEntityDescription.entity(forEntityName: "Journal", in: context)
            let newJournal = Journal(entity: entity!, insertInto: context)
            newJournal.id = journalList.count as NSNumber
            newJournal.dateCreated = dateTF.text
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
                    if(journal == selectedJournal) {
                        journal.dateCreated = dateTF.text
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

