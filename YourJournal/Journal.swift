//
//  Journal.swift
//  YourJournal
//
//  Created by 大川裕平 on 08/08/2023.
//

import CoreData

@objc(Journal)
class Journal: NSManagedObject {
    
    @NSManaged var id: NSNumber!
    @NSManaged var desc: String!
    @NSManaged var dateCreated: String!
    @NSManaged var dateDeleted: Date?
    
}
