//
//  QwertySpaceKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertySpaceKeyModel: QwertyKeyModelProtocol{
    var variableSection = QwertyKeyModelVariableSection()
    
    let pressActions: [ActionType] = [.input(" ")]
    var longPressActions: [KeyLongPressActionType] = [.doOnce(.toggleShowMoveCursorView)]

    let needSuggestView: Bool = false
    let variationsModel = VariationsModel([])
    let keySizeType: QwertyKeySizeType = .space
    init(){}

    func label(width: CGFloat, states: VariableStates, color: Color?, theme: ThemeData) -> KeyLabel {
        switch states.keyboardLanguage{
        case .english:
            return KeyLabel(.text("space"), width: width, theme: theme, textSize: .small, textColor: color)
        case .japanese:
            return KeyLabel(.text("空白"), width: width, theme: theme, textSize: .small, textColor: color)
        }
    }

    func sound() {
        Sound.click()
    }
}
