//
//  JournalTableView.swift
//  YourJournal
//
//  Created by 大川裕平 on 08/08/2023.
//

import Foundation
import UIKit
import CoreData

var journalList = [Journal]()

class JournalTableView: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchDate: Date? = nil // 検索された日付を保存するための変数
    
    var firstLoad = true
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 検索バーが空の場合、searchDateをnilにリセット
            searchDate = nil
            tableView.reloadData() // テーブルビューを再読み込み
        }
    }
    
    func nonDeletedJournals() -> [Journal] {
        
        var noDeleteJournalList = [Journal]()
        
//        for journal in journalList {
//            if(journal.dateDeleted == nil) {
//                noDeleteJournalList.append(journal)
//            }
//        }
        
//        for journal in journalList {
//                    if let searchDate = searchDate {
//                        if journal.dateDeleted == nil && journal.dayCreated == searchDate {
//                            noDeleteJournalList.append(journal)
//                        }
//                    } else if journal.dateDeleted == nil {
//                        noDeleteJournalList.append(journal)
//                    }
//                }
        
        for journal in journalList {
            if let searchDate = searchDate, let journalDate = journal.dayCreated {
                // 年、月、日のみを取得する
                let calendar = Calendar.current
                let searchComponents = calendar.dateComponents([.year, .month, .day], from: searchDate)
                let journalComponents = calendar.dateComponents([.year, .month, .day], from: journalDate)
                
                // 年、月、日が一致するか確認
                if searchComponents == journalComponents && journal.dateDeleted == nil {
                    noDeleteJournalList.append(journal)
                }
            } else if journal.dateDeleted == nil {
                noDeleteJournalList.append(journal)
            }
        }

        
        // dayCreatedに基づいてソート
            noDeleteJournalList.sort { (journal1, journal2) -> Bool in
                guard let date1 = journal1.dayCreated, let date2 = journal2.dayCreated else {
                    return false
                }
                return date1 > date2 // 新しいものから古いものへの降順でソート
            }
        
        return noDeleteJournalList
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        searchBar.delegate = self
        
        if(firstLoad){
            journalList.removeAll()
            firstLoad = false
            // same firsr 2 lines from save func
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                     let journal = result as! Journal
                    journalList.append(journal)
                }
            } catch  {
                print("fetch failed.")
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // 日付の文字列をDate型に変換
            if let dateString = searchBar.text {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: dateString) {
                    searchDate = date
                }
            }
            
            tableView.reloadData() // テーブルビューを更新して結果を表示
            searchBar.resignFirstResponder() // キーボードを閉じる
        }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let journalCell = tableView.dequeueReusableCell(withIdentifier: "journalCellID", for: indexPath) as! JournalCell
        
        let thisJournal: Journal!
        thisJournal = nonDeletedJournals()[indexPath.row]
        
        journalCell.descLabel.text = thisJournal.desc
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = thisJournal.dayCreated {
            journalCell.dateLabel.text = formatter.string(from: date)
        } else {
            journalCell.dateLabel.text = "Unknown Date"
        }

        // emotionResultを顔文字に変換してセルに表示
        if let emotion = thisJournal.emotionResult {
            let emoji = emotionToEmoji(emotion: emotion)
            journalCell.emotionLabel.text = emoji // ここでは、JournalCellにemotionLabelという名前のUILabelを追加したと仮定しています
        } else {
            journalCell.emotionLabel.text = "" // emotionResultがない場合、ラベルをクリア
        }
        
        return journalCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nonDeletedJournals().count // possibility to crash here
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editJournal", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editJournal") {
            let indexPath =  tableView.indexPathForSelectedRow!
            
            let journalDetail = segue.destination as? JouranlDetailVC
            
            let selectedJournal : Journal!
            selectedJournal = nonDeletedJournals()[indexPath.row]
            journalDetail!.selectedJournal = selectedJournal
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        
        navigationController?.popToRootViewController(animated: true)
        
    }

    @IBAction func analysisPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "ToAnalysis", sender: self)
        
    }
    
    func emotionToEmoji(emotion: String) -> String {
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
