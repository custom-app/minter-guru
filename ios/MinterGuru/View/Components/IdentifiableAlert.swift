//
//  IdentifiableAlert.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation
import SwiftUI

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
    
    static func build(id: String, title: String, message: String, action: (() -> Void)? = nil) -> IdentifiableAlert {
        return IdentifiableAlert(id: id, alert: {
            Alert(
                title: Text(LocalizedStringKey(title)),
                message: Text(LocalizedStringKey(message)),
                dismissButton: .default(Text("Ok"), action: {
                    action?()
                })
            )
        })
    }
    
    static func buildDestructive(id: String,
                                 title: String,
                                 message: String,
                                 primaryText: String = "No",
                                 destructiveText: String = "Yes",
                                 destructiveAction: (() -> Void)? = nil) -> IdentifiableAlert {
        return IdentifiableAlert(id: id, alert: {
            Alert(
                title: Text(LocalizedStringKey(title)),
                message: Text(LocalizedStringKey(message)),
                primaryButton: .default(Text(primaryText)),
                secondaryButton: .destructive(Text(destructiveText)) {
                    destructiveAction?()
                }
            )
        })
    }
    
    static func buildSingleAction(id: String,
                                  title: String,
                                  message: String,
                                  actionText: String = "Yes",
                                  cancelText: String = "No",
                                  action: (() -> Void)? = nil) -> IdentifiableAlert {
        return IdentifiableAlert(id: id, alert: {
            Alert(
                title: Text(LocalizedStringKey(title)),
                message: Text(LocalizedStringKey(message)),
                primaryButton: .default(Text(cancelText)),
                secondaryButton: .default(Text(actionText)) {
                    action?()
                }
            )
        })
    }
    
    static func networkError() -> IdentifiableAlert {
        return IdentifiableAlert.build(
            id: "response is not successful",
            title: "An error has occured",
            message: "Please check your internet connection and try again"
        )
    }
}
