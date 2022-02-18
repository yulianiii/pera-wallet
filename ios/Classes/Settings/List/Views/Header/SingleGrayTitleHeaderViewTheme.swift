// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   SettingsHeaderViewTheme.swift


import Foundation
import MacaroonUIKit

struct SingleGrayTitleHeaderViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let title: TextStyle
    
    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13))
        ]
        
        self.bottomInset = 8
        self.horizontalInset = 24
    }
}