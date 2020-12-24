//
//  SettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct KeyFlickSettingItemView: View {
    typealias ItemViewModel = SettingItemViewModel<KeyFlickSetting>
    typealias ItemModel = SettingItem<KeyFlickSetting>

    init(_ viewModel: ItemViewModel){
        self.item = viewModel.item
        self.viewModel = viewModel
    }
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    // TODO: 可能になったタイミングでReturnKeyTypeを設定する
    var body: some View {
        VStack{
            HStack{
                Text("\(Image(systemName: "arrow.left"))左フリック")
                TextField("入力する文字", text: $viewModel.value.left)
                    .padding(.vertical, 2)
                Divider()
                PasteLongPressButton($viewModel.value.left)
                    .padding(.horizontal, 5)
            }
            HStack{
                Text("\(Image(systemName: "arrow.up"))上フリック")
                TextField("入力する文字", text: $viewModel.value.top)
                    .padding(.vertical, 2)
                Divider()
                PasteLongPressButton($viewModel.value.top)
                    .padding(.horizontal, 5)
            }
            HStack{
                Text("\(Image(systemName: "arrow.right"))右フリック")
                TextField("入力する文字", text: $viewModel.value.right)
                    .padding(.vertical, 2)
                Divider()
                PasteLongPressButton($viewModel.value.right)
                    .padding(.horizontal, 5)
            }

        }
    }
}