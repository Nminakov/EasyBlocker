//
//  CallDirectoryHandler.swift
//  Easy Blocker Ext.
//
//  Created by Nikita Minakov on 12/26/20.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    private var fileUrl: URL? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.studio.devlav.easy-blocker")?.appendingPathComponent("numbers")
        return url
    }
    
    private func loadList() -> [NumberEntry] {
        guard
            let path = fileUrl?.path else {
            return []
        }
        if
            FileManager.default.fileExists(atPath: path),
            let data = FileManager.default.contents(atPath: path)
        {
            do {
                let numbers = try JSONDecoder().decode([NumberEntry].self, from: data)
                return numbers
            }
            catch {
                print(error)
            }
        }
        return []
    }

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        addAllBlockingPhoneNumbers(to: context)
        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        let numbers = loadList().map { Int64($0.number) }
        let allPhoneNumbers: [CXCallDirectoryPhoneNumber] = numbers
        context.removeAllBlockingEntries()
        
        for phoneNumber in allPhoneNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
