//
//  ColorPickerInformatio.swift
//  NetSchool App
//
//  Created by Arthur on 22.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import Foundation
class ColorPickerInformation{
    var title: String
    let y_marg: CGFloat
    let x_marg: CGFloat
    let k: CGFloat
    func init_title(count: Int){
        for _ in 0...count{
            title += "\n"
        }
    }
    func get_width(width: CGFloat) -> CGFloat{
        return width
    }
    init(model_name: String) {
        title = ""
        if model_name.contains("iPhone"){
            k = 8
        }else if model_name.contains("10.5 Inch"){
            k = 22
        }else if model_name.contains("9.7 Inch") || model_name.contains("iPad Air") || model_name.contains("iPad 5"){
            k = 20
        }else {
            k = 27
        }
        if model_name.contains("iPhone 5"){
            y_marg = -3
            x_marg = -6
            self.init_title(count: 6)
        }else if model_name.contains("iPhone 6 Plus"){
            y_marg = -5
            x_marg = 6
            self.init_title(count: 8)
        }else if model_name.contains("iPhone 7 Plus"){
            y_marg = -5
            x_marg = 7
            self.init_title(count: 8)
        }else if model_name.contains("iPhone 8 Plus"){
            y_marg = -5
            x_marg = 5
            self.init_title(count: 8)
        }else if model_name.contains("iPhone X"){
            y_marg = -6
            x_marg = 3
            self.init_title(count: 7)
        }else if model_name.contains("iPad"){
            y_marg = -4
            x_marg = 3
            self.init_title(count: 6)
        }else{
            y_marg = -10
            x_marg = 0
            self.init_title(count: 7)
        }
    }
}

