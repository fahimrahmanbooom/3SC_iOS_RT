//
//  UIDevice.swift
//  PokeApp
//
//  Created by Fahim Rahman on 11/5/25.
//

import UIKit

extension UIDevice {
    static var isiPad: Bool {
        return current.userInterfaceIdiom == .pad
    }

    static var isiPhone: Bool {
        return current.userInterfaceIdiom == .phone
    }
}
