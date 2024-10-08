//
//  Extension.swift
//  ContentTracker2
//
//  Created by Sümeyra Demirtaş on 10/1/24.
//


import Foundation

// bu extensionlar biraz deneme amacli oldu, bence cok da gerekli degildi
extension Notification.Name {
    static let didAddNewMediaItem = Notification.Name("didAddNewMediaItem")
}

extension Notification.Name {
    static let reloadTableView = Notification.Name("reloadTableView")
}

extension Notification.Name {
    static let didUpdateMediaItem = Notification.Name("didUpdateMediaItem")
}

extension Notification.Name {
    static let didDeleteMediaItem = Notification.Name("didDeleteMediaItem")
}
