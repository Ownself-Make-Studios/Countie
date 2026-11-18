//
//  CountdownWidgetBundle.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import SwiftUI

@main
struct CountdownWidgetBundle: WidgetBundle {
    let kind: String = "CountdownWidget"
    var body: some Widget {
        CountdownWidget()
//        CountdownWidgetLiveActivity()
    }
}
