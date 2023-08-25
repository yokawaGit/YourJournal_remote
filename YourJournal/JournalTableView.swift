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

class JournalTableView: UITableViewController {
    
    var firstLoad = true
    
    func nonDeletedJournals() -> [Journal] {
        var noDeleteJournalList = [Journal]()
        for journal in journalList {
            if(journal.dateDeleted == nil) {
                noDeleteJournalList.append(journal)
            }
        }
        
        return noDeleteJournalList
    }
    
    override func viewDidLoad() {
        if(firstLoad){
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
    
}
