//
//  WindowLevelHelper.swift
//  timer_date
//
//  Created by 野口祥生 on 2025/05/23.
//

import Foundation
import AppKit

/// アプリのメインウィンドウを常に前面に保つ
@MainActor
func makeWindowFloating() {
    if let window = NSApp.windows.first {
        window.level = .floating
    }
}
