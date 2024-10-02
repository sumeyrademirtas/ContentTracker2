//
//  Extension.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//


import Foundation

extension Notification.Name {
    static let didAddNewMediaItem = Notification.Name("didAddNewMediaItem")
}

extension Notification.Name {
    static let reloadTableView = Notification.Name("reloadTableView")
}


extension CategoryType {
    init?(rawValue: String) {
        switch rawValue {
        case "Movie": self = .movie
        case "TV Series": self = .tvSerie
        case "Book": self = .book
        case "Podcast": self = .podcast
        case "Theater": self = .theater
        default: return nil
        }
    }
}
