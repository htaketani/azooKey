//
//  TabNavigationEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension TabBarItemLabelType: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.text(l), .text(r)):
            return l == r
        case let (.image(l), .image(r)):
            return l == r
        case let (.imageAndText(l), .imageAndText(r)):
            return l == r
        default:
            return false
        }
    }
}

struct EditingTabBarItem: Identifiable, Equatable {
    let id = UUID()
    var label: TabBarItemLabelType
    var actions: EditingCodableActions
    var disclosed: Bool

    init(label: TabBarItemLabelType, actions: EditingCodableActions, disclosed: Bool = false){
        self.label = label
        self.actions = actions
        self.disclosed = disclosed
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label && lhs.actions == rhs.actions
    }
}

struct EditingTabBarView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding private var tabBarData: TabBarData
    @State private var items: [EditingTabBarItem] = []
    @State private var editMode = EditMode.inactive
    @Binding private var manager: CustardManager

    init(tabBarData: Binding<TabBarData>, manager: Binding<CustardManager>){
        debug("initializer")
        self._items = State(initialValue: tabBarData.wrappedValue.items.indices.map{i in
            EditingTabBarItem(
                label: tabBarData.wrappedValue.items[i].label,
                actions: EditingCodableActions(tabBarData.wrappedValue.items[i].actions.map{EditingCodableActionData($0)})
            )
        })
        self._tabBarData = tabBarData
        self._manager = manager
    }

    var body: some View {
        Form {
            Section{
                Button{
                    items.append(
                        EditingTabBarItem(
                            label: .text("アイテム"),
                            actions: EditingCodableActions([EditingCodableActionData(.moveTab(.system(.user_hira)))])
                        )
                    )
                } label: {
                    HStack{
                        Image(systemName: "plus")
                        Text("アイテムを追加")
                    }
                }
            }

            Section(header: Text("アイテム")){
                List{
                    ForEach(items.indices, id: \.self){i in
                        HStack{
                            VStack(spacing: 20){
                                DisclosureGroup{
                                    HStack{
                                        Text("表示")
                                        Spacer()
                                        TabNavigationViewItemLabelEditView("ラベルを設定", item: $items[i])
                                    }
                                    NavigationLink(destination: KeyActionsEditView($items[i], actions: items[i].actions, availableCustards: manager.availableCustards)){
                                        Text("押した時の動作")
                                        Spacer()
                                        let label = (items[i].actions.list.first?.data.label ?? "動作なし") + (items[i].actions.list.count > 1 ? "など" : "")
                                        Text(label)
                                            .foregroundColor(.gray)
                                    }
                                } label: {
                                    switch items[i].label{
                                    case let .text(text):
                                        Text(text)
                                    case let .imageAndText(value):
                                        HStack{
                                            Image(systemName: value.systemName)
                                            Text(value.text)
                                        }
                                    case let .image(image):
                                        Image(systemName: image)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: onMove)
                }
            }
        }
        .navigationBarTitle(Text("タブバーの編集"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button{
            self.save()
            presentationMode.wrappedValue.dismiss()
        }label: {
            Text("保存")
        }, trailing: editButton)
        .environment(\.editMode, $editMode)
    }

    private func save(){
        do{
            debug("セーブする！", self.items)
            self.tabBarData = TabBarData(identifier: tabBarData.identifier, items: self.items.map{
                TabBarItem(label: $0.label, actions: $0.actions.list.map{$0.data})
            })
            try manager.saveTabBarData(tabBarData: self.tabBarData)
        } catch {
            debug(error)
        }
    }

    private var editButton: some View {
        Button{
            switch editMode{
            case .inactive:
                editMode = .active
            case .active, .transient:
                editMode = .inactive
            @unknown default:
                editMode = .inactive
            }
        } label: {
            switch editMode{
            case .inactive:
                Text("削除と順番")
            case .active, .transient:
                Text("完了")
            @unknown default:
                Text("完了")
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

}

struct TabNavigationViewItemLabelEditView: View {
    internal init(_ placeHolder: LocalizedStringKey, item: Binding<EditingTabBarItem>) {
        self.placeHolder = placeHolder
        self._item = item
        switch item.wrappedValue.label{
        case let .text(text):
            self._labelText = State(initialValue: text)
        case let .image(systemName: image):
            break
        case let .imageAndText(value):
            break
        }
    }

    @Binding private var item: EditingTabBarItem
    @State private var labelText = ""

    private let placeHolder: LocalizedStringKey

    var body: some View {
        TextField(placeHolder, text: $labelText){ _ in } onCommit: {
            item.label = .text(labelText)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}