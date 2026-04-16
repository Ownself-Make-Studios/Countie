//
//  ModalStore.swift
//  Countie
//
//  Created by Nabil Ridhwan on 26/8/25.
//

import Foundation
internal import Combine

class ModalStore: ObservableObject {
    @Published var isSelectedCountdown: CountdownItem? = nil
}
