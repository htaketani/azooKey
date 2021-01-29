//
//  KeyboardView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

//キーボードの状態管理
enum TabState: Equatable{
    case hira
    case abc
    case number
    case other(String)

    static func ==(lhs: TabState, rhs: TabState) -> Bool {
        switch (lhs, rhs) {
        case (.hira, .hira), (.abc, .abc), (.number, .number): return true
        case let (.other(ls), .other(rs)): return ls == rs
        default:
            return false
        }
    }
}

enum KeyboardLanguage{
    case english
    case japanese
}

enum KeyboardOrientation{
    case vertical       //width<height
    case horizontal     //height<width
}

//layout, orientation, language, inputstyleに関わらず保持すべきデータ。
final class KeyboardModelVariableSection: ObservableObject{
    @Published var keyboardOrientation: KeyboardOrientation = .vertical
    @Published var isTextMagnifying = false
    @Published var isResultViewExpanded = false
    @Published var magnifyingText = ""
    @Published var refreshing = true
    func refreshView(){
        refreshing.toggle()
    }
}

struct KeyboardModel {
    let expandedResultModel = ExpandedResultModel()
    let resultModel = ResultModel()

    let variableSection: KeyboardModelVariableSection = KeyboardModelVariableSection()
    func expandResultView(_ results: [ResultData]) {
        self.variableSection.isResultViewExpanded = true
        self.expandedResultModel.expand(results: results)
    }
    func collapseResultView(){
        self.variableSection.isResultViewExpanded = false
    }

}

fileprivate struct MessageManager{
    let necessaryMessages: [MessageViewData] = [
        MessageViewData(
            id: "ver1.5_update_loudstxt_alert",
            title: "お願い",
            description: "内部データの更新のため本体アプリを開きます。よろしいですか？",
            needOpenContainer: true,
            detailsURL: "https://azookey.netlify.app/"
        )
    ]
}

struct KeyboardView: View {
    //二つ以上になったらまとめてvariableSectioinにすること！
    @ObservedObject private var modelVariableSection: KeyboardModelVariableSection
    private let model: KeyboardModel

    init(){
        self.model = Store.shared.keyboardViewModel
        self.modelVariableSection = self.model.variableSection
    }

    var body: some View {
        ZStack{[unowned modelVariableSection] in
            
            Design.shared.colors.backGroundColor
                .frame(maxWidth: .infinity)
            if modelVariableSection.isResultViewExpanded{
                ExpandedResultView(model: self.model.expandedResultModel)
                    .padding(.bottom, 2)
            }else{
                VStack(spacing: 0){
                    ResultView(model: model.resultModel)
                        .padding(.vertical, 6)
                    if modelVariableSection.refreshing{
                        switch (modelVariableSection.keyboardOrientation, Store.shared.keyboardLayout){
                        case (.vertical, .flick):
                            VerticalFlickKeyboardView(Store.shared.keyboardModel as! VerticalFlickKeyboardModel)
                        case (.vertical, .qwerty):
                            VerticalQwertyKeyboardView(Store.shared.keyboardModel as! VerticalQwertyKeyboardModel)
                        case (.horizontal, .flick):
                            HorizontalKeyboardView(Store.shared.keyboardModel as! HorizontalFlickKeyboardModel)
                        case (.horizontal, .qwerty):
                            HorizontalQwertyKeyboardView(Store.shared.keyboardModel as! HorizontalQwertyKeyboardModel)
                        }
                    }else{
                        switch (modelVariableSection.keyboardOrientation, Store.shared.keyboardLayout){
                        case (.vertical, .flick):
                            VerticalFlickKeyboardView(Store.shared.keyboardModel as! VerticalFlickKeyboardModel)
                        case (.vertical, .qwerty):
                            VerticalQwertyKeyboardView(Store.shared.keyboardModel as! VerticalQwertyKeyboardModel)
                        case (.horizontal, .flick):
                            HorizontalKeyboardView(Store.shared.keyboardModel as! HorizontalFlickKeyboardModel)
                        case (.horizontal, .qwerty):
                            HorizontalQwertyKeyboardView(Store.shared.keyboardModel as! HorizontalQwertyKeyboardModel)
                        }
                    }
                }.padding(.bottom, 2)
            }
            if modelVariableSection.isTextMagnifying{
                LargeTextView(modelVariableSection.magnifyingText)
            }
            
            ForEach(UserSettingDepartment.necessaryMessages, id: \.id){data in
                MessageView(data: data)
            }
        }
    }
}
