//
//  ArrayBuilder.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

@resultBuilder
struct ArrayBuilder {
    public static func buildBlock<T>(_ values: T...) -> [T] {
        return values
    }
}
