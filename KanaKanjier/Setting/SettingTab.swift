//
//  SettingTab.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
import StoreKit

struct SettingTabView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection
    @State private var text = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("キーボードの種類")){
                    //KeyboardLayoutSettingItemView(Store.shared.keyboardTypeSetting, setTogether: true, id: 11)
                    NavigationLink(destination: KeyboardLayoutTypeDetailsView()){
                        HStack{
                            Text("キーボードの種類を設定する")
                            Spacer()
                        }
                    }
                }
                switch (storeVariableSection.keyboardType, storeVariableSection.englishKeyboardLayout){
                case (.flick, .flick):
                    Section(header: Text("カスタムキー")){
                        VStack{
                            Text("「小ﾞﾟ」キーと「､｡?!」キーで入力する文字をカスタマイズすることができます。")
                            ImageSlideshowView(pictures: ["flickCustomKeySetting0","flickCustomKeySetting1","flickCustomKeySetting2"])
                        }
                        NavigationLink(destination: FlickCustomKeysSettingSelectView()){
                            HStack{
                                Text("設定する")
                                Spacer()
                            }
                        }
                    }
                case (.flick, .qwerty), (.qwerty, .flick):
                    Section(header: Text("カスタムキー")){
                        VStack{
                            Text("「小ﾞﾟ」キーと「､｡?!」キーで入力する文字をカスタマイズすることができます。")
                            ImageSlideshowView(pictures: ["flickCustomKeySetting0","flickCustomKeySetting1","flickCustomKeySetting2"])
                        }
                        NavigationLink(destination: FlickCustomKeysSettingSelectView()){
                            HStack{
                                Text("設定する")
                                Spacer()
                            }
                        }
                        VStack{
                            Text("数字タブの青枠部分に好きな記号や文字を割り当てられます。")
                            ImageSlideshowView(pictures: ["romanCustomKeySetting0","romanCustomKeySetting1","romanCustomKeySetting2"])
                        }
                        NavigationLink(destination: RomanCustomKeysItemView(Store.shared.numberTabCustomKeysSettingNew)){
                            HStack{
                                Text("設定する")
                                Spacer()
                            }
                        }
                    }

                case (.qwerty, .qwerty):
                    Section(header: Text("カスタムキー")){
                        VStack{
                            Text("数字タブの青枠部分に好きな記号や文字を割り当てられます。")
                            ImageSlideshowView(pictures: ["romanCustomKeySetting0","romanCustomKeySetting1","romanCustomKeySetting2"])
                        }
                        NavigationLink(destination: RomanCustomKeysItemView(Store.shared.numberTabCustomKeysSettingNew)){
                            HStack{
                                Text("設定する")
                                Spacer()
                            }
                        }
                    }
                }
                Section(header: Text("サウンド")){
                    BooleanSettingItemView(Store.shared.enableSoundSetting)
                }
                /*
                Section(header: Text("言語")){
                    HStack{
                        Text("使用言語の設定")
                        Spacer()
                        Picker(selection: $text, label: Text("")) {
                            Text("日本語のみ").tag("ja")
                            Text("英語のみ").tag("en")
                            Text("日本語・英語").tag("ja_en")
                        }
                        .labelsHidden()
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150, height: 70)
                        .clipped()
                    }
                }
                */
                Section(header: Text("表示")){
                    FontSizeSettingItemView(Store.shared.keyViewFontSizeSetting, .key, availableValues: [
                        -1,
                        15,
                        16,
                        17,
                        18,
                        19,
                        20,
                        21,
                        22,
                        23,
                        24,
                        25,
                        26,
                        27,
                        28
                    ])
                    FontSizeSettingItemView(Store.shared.resultViewFontSizeSetting, .result, availableValues: [
                        -1,
                        12,
                        13,
                        14,
                        15,
                        16,
                        17,
                        18,
                        19,
                        20,
                        21,
                        22,
                        23,
                        24,
                    ])
                }
                Section(header: Text("変換")){
                    switch storeVariableSection.keyboardType{
                    case .flick:
                        EmptyView()
                    case .qwerty:
                        BooleanSettingItemView(Store.shared.englishCandidateSetting)
                    }
                    BooleanSettingItemView(Store.shared.halfKanaSetting)
                    BooleanSettingItemView(Store.shared.fullRomanSetting)
                    BooleanSettingItemView(Store.shared.typographyLetterSetting)
                    BooleanSettingItemView(Store.shared.wesJapCalenderSetting)
                    BooleanSettingItemView(Store.shared.unicodeCandidateSetting)
                    NavigationLink(destination: AdditionalDictManageView()) {
                        HStack{
                            Text("絵文字と顔文字")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: AzooKeyUserDictionaryView()) {
                        HStack{
                            Text("azooKeyユーザ辞書")
                            Spacer()
                        }
                    }
                }

                Section(header: Text("テンプレート")){
                    NavigationLink(destination: TemplateListView()) {
                        HStack{
                            Text("テンプレートの管理")
                            Spacer()
                        }
                    }
                }

                Section(header: Text("学習機能")){
                    //BooleanSettingItemView(Store.shared.stopLearningWhenSearchSetting)
                    LearningTypeSettingItemView(Store.shared.memorySetting)
                    MemoryResetSettingItemView(Store.shared.memoryResetSetting)
                }
                Section(header: Text("このアプリについて")){
                    NavigationLink(destination: ContactView()) {
                        HStack{
                            Text("お問い合わせ")
                            Spacer()
                        }
                    }
                    /*
                    HStack{
                        Button{
                            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                                SKStoreReviewController.requestReview(in: windowScene)
                            }
                        }label: {
                            Text("レビューする")
                        }

                        Spacer()
                    }.foregroundColor(.primary)
 */
                    FallbackLink("プライバシーポリシー", destination: URL(string: "https://azookey.netlify.app/PrivacyPolicy")!)
                        .foregroundColor(.primary)
                    FallbackLink("利用規約", destination: URL(string: "https://azookey.netlify.app/TermsOfService")!)
                        .foregroundColor(.primary)
                    NavigationLink(destination: UpdateInfomationView()) {
                        HStack{
                            Text("更新履歴")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: OpenSourceSoftWaresLicenceView()) {
                        HStack{
                            Text("ライセンス")
                            Spacer()
                        }
                    }
                    HStack{
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "取得中です")
                    }

                }

            }
            .navigationBarTitle(Text("設定"), displayMode: .large)
            .onAppear(){
                if Store.shared.shouldTryRequestReview, Store.shared.shouldRequestReview(){
                    if let windowScene = UIApplication.shared.windows.first?.windowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .font(.body)
    }
}

struct SettingTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingTabView()
    }
}
