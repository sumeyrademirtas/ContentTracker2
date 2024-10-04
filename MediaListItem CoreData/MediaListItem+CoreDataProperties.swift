//
//  MediaListItem+CoreDataProperties.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//
//

import Foundation
import CoreData


extension MediaListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaListItem> {
        return NSFetchRequest<MediaListItem>(entityName: "MediaListItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var note: String?

}

extension MediaListItem : Identifiable {

}
