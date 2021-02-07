//
//  UserSetting.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingData{
    private static let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
    private let boolSettingItems: [Setting] = [.unicodeCandidate, .wesJapCalender, .halfKana, .fullRoman, .typographyLetter, .enableSound, .englishCandidate]
    private var boolSettings: [Setting: Bool]
    private var keyboardLayoutSetting: [Setting: KeyboardLayout]

    static var shared = SettingData()

    private init(){
        self.boolSettings = boolSettingItems.reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getBoolSetting(setting)
        }
        self.keyboardLayoutSetting = [Setting.englishKeyboardLayout, Setting.japaneseKeyboardLayout].reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getKeyboardLayoutSetting(setting)
        }
    }

    mutating func reload(){
        //bool値の設定を更新
        self.boolSettings = boolSettingItems.reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getBoolSetting(setting)
        }
        self.keyboardLayoutSetting = [Setting.englishKeyboardLayout, Setting.japaneseKeyboardLayout].reduce(into: [:]){dictionary, setting in
            dictionary[setting] = Self.getKeyboardLayoutSetting(setting)
        }
        self.kogakiFlickSetting = Self.getKogakiFlickSetting()
        self.kanaSymbolsFlickSetting = Self.getKanaSymbolsFlickSetting()

        self.learningType = Self.learningTypeSetting(.inputAndOutput)

        self.resultViewFontSize = Self.getDoubleSetting(.resultViewFontSize) ?? -1
        self.keyViewFontSize = Self.getDoubleSetting(.keyViewFontSize) ?? -1

        if Self.checkResetSetting(){
            VariableStates.shared.action.sendToDicDataStore(.resetMemory)
        }
    }

    internal func bool(for key: Setting) -> Bool {
        self.boolSettings[key, default: false]
    }

    internal func keyboardLayout(for key: Setting) -> KeyboardLayout {
        if key == .englishKeyboardLayout, let layout = self.keyboardLayoutSetting[Setting.japaneseKeyboardLayout]{
            return self.keyboardLayoutSetting[key, default: layout]
        }
        return self.keyboardLayoutSetting[key, default: .flick]
    }

    private static func getKogakiFlickSetting() -> [FlickDirection: FlickedKeyModel] {
        let value = Self.userDefaults.value(forKey: Setting.koganaKeyFlick.key)
        let setting: KeyFlickSetting
        if let value = value, let data = KeyFlickSetting.get(value){
            setting = data
        }else{
            setting = CustomizableFlickKey.kogana.defaultSetting
        }

        var dict: [FlickDirection: FlickedKeyModel] = [:]
        if let left = setting.left.input == "" ? nil:FlickedKeyModel(labelType: .text(setting.left.label), pressActions: [.input(setting.left.input)]){
            dict[.left] = left
        }
        if let top = setting.top.input == "" ? nil:FlickedKeyModel(labelType: .text(setting.top.label), pressActions: [.input(setting.top.input)]){
            dict[.top] = top
        }
        if let right = setting.right.input == "" ? nil:FlickedKeyModel(labelType: .text(setting.right.label), pressActions: [.input(setting.right.input)]){
            dict[.right] = right
        }
        return dict

    }

    private static func getKanaSymbolsFlickSetting() -> (labelType: KeyLabelType, actions: [ActionType], flick:  [FlickDirection: FlickedKeyModel]) {
        let value = Self.userDefaults.value(forKey: Setting.kanaSymbolsKeyFlick.key)
        let setting: KeyFlickSetting
        if let value = value, let data = KeyFlickSetting.get(value){
            setting = data
        }else{
            setting = CustomizableFlickKey.kanaSymbols.defaultSetting
        }
        var dict: [FlickDirection: FlickedKeyModel] = [:]
        if let left = setting.left.input == "" ? nil:FlickedKeyModel(labelType: .text(setting.left.label), pressActions: [.input(setting.left.input)]){
            dict[.left] = left
        }
        if let top = setting.top.input == "" ? nil:FlickedKeyModel(labelType: .text(setting.top.label), pressActions: [.input(setting.top.input)]){
            dict[.top] = top
        }
        if let right = setting.right.input == "" ? nil:FlickedKeyModel(labelType: .text(setting.right.label), pressActions: [.input(setting.right.input)]){
            dict[.right] = right
        }
        return (.text(setting.center.label), [.input(setting.center.input)], dict)
    }

    var kogakiFlickSetting: [FlickDirection: FlickedKeyModel] = Self.getKogakiFlickSetting()
    var kanaSymbolsFlickSetting: (labelType: KeyLabelType, actions: [ActionType], flick:  [FlickDirection: FlickedKeyModel]) = Self.getKanaSymbolsFlickSetting()

    var learningType: LearningType = Self.learningTypeSetting(.inputAndOutput, initialize: true)

    var resultViewFontSize = Self.getDoubleSetting(.resultViewFontSize) ?? -1
    var keyViewFontSize = Self.getDoubleSetting(.keyViewFontSize) ?? -1

    private static func getKeyboardLayoutSetting(_ setting: Setting) -> KeyboardLayout {
        switch setting{
        case .japaneseKeyboardLayout, .englishKeyboardLayout:
            if let string = Self.userDefaults.string(forKey: setting.key), let type = KeyboardLayout.get(string){
                return type
            }else{
                userDefaults.set(KeyboardLayout.flick.rawValue, forKey: setting.key)
                return .flick
            }
        default: return .flick
        }
    }

    private static func getBoolSetting(_ setting: Setting) -> Bool {
        if let object = Self.userDefaults.object(forKey: setting.key), let bool = object as? Bool{
            return bool
        }else if let bool = DefaultSetting.shared.getBoolDefaultSetting(setting){
            return bool
        }
        return false
    }

    private static func getDoubleSetting(_ setting: Setting) -> Double? {
        if let object = Self.userDefaults.object(forKey: setting.key), let value = object as? Double{
            return value
        }else if let value = DefaultSetting.shared.getDoubleSetting(setting){
            return value
        }
        return nil
    }

    private static func learningTypeSetting(_ current: LearningType, initialize: Bool = false) -> LearningType {
        let result: LearningType
        if let object = Self.userDefaults.object(forKey: Setting.learningType.key),
           let value = LearningType.get(object){
            result = value
        }else{
            result = DefaultSetting.shared.memorySettingDefault
        }
        if !initialize{
            VariableStates.shared.action.sendToDicDataStore(.notifyLearningType(result))
        }
        return result
    }

    static func checkResetSetting() -> Bool {
        if let object = Self.userDefaults.object(forKey: Setting.memoryReset.key),
           let identifier = MemoryResetCondition.identifier(object){
            if let finished = UserDefaults.standard.string(forKey: "finished_reset"), finished == identifier{
                return false
            }
            UserDefaults.standard.set(identifier, forKey: "finished_reset")
            return true
        }
        return false
    }

    mutating func writeLearningTypeSetting(to type: LearningType) {
        Self.userDefaults.set(type.saveValue, forKey: Setting.learningType.key)
        self.learningType = type
        VariableStates.shared.action.sendToDicDataStore(.notifyLearningType(type))
    }

    var qwertyNumberTabKeySetting: [QwertyKeyModel] {
        let customKeys: RomanCustomKeysValue
        if let value = Self.userDefaults.value(forKey: Setting.numberTabCustomKeys.key), let keys = RomanCustomKeysValue.get(value){
            customKeys = keys
        }else if let defaultValue = DefaultSetting.shared.qwertyCustomKeyDefaultSetting(.numberTabCustomKeys){
            customKeys = defaultValue
        }else{
            return []
        }
        let keys = customKeys.keys
        let count = keys.count
        let scale = (7, count)
        return keys.map{key in
            QwertyKeyModel(
                labelType: .text(key.name),
                pressActions: [.input(key.input)],
                variationsModel: VariationsModel(
                    key.longpresses.map{item in
                        (label: .text(item.name), actions: [.input(item.input)])
                    }
                ),
                for: scale
            )
        }
    }
}