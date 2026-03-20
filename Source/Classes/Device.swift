//
//  Device.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    static var all: [String: Any] {
        var details: [String: Any] = [:]

        details["iOS Version"] = UIDevice.current.systemVersion

        let width = String(Int(UIScreen.main.bounds.size.width))
        let height = String(Int(UIScreen.main.bounds.size.height))
        details["Device"] = UIDevice.modelName()
        details["Screen"] = "\(width) x \(height)"
        details["Uptime"] = "\(Int(ProcessInfo.processInfo.systemUptime) / 60) mins"

        if let timezone = TimeZone.current.abbreviation() {
            details["Timezone"] = timezone
        }
        details["Language"] = Locale.preferredLanguages.first ?? "unknown"
        return details
    }
}

extension UIDevice {
    static func modelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
