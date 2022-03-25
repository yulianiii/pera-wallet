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
//   ManageAssetsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ManageAssetsViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    
    let noContentViewTheme: NoContentViewTheme
    
    let title: TextStyle
    let titleText: EditText
    let titleTopPadding: LayoutMetric
    
    let subtitle: TextStyle
    let subtitleText: EditText
    let subtitleTopPadding: LayoutMetric
    
    let searchInputViewTheme: SearchInputViewTheme
    let searchInputViewTopPadding: LayoutMetric
    
    let collectionViewTopPadding: LayoutMetric
    let cellSpacing: LayoutMetric
    
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        
        self.noContentViewTheme = NoContentViewCommonTheme()
        
        self.title = [
            .textOverflow(SingleLineFittingText()),
        ]
        let titleFont = Fonts.DMSans.medium.make(32)
        let titleLineHeightMultiplier = 0.96
        self.titleText = .attributedString(
            "asset-remove-title"
                .localized
                .attributed([
                    .font(titleFont),
                    .letterSpacing(-0.32),
                    .lineHeightMultiplier(titleLineHeightMultiplier, titleFont),
                    .paragraph([
                        .lineHeightMultiple(titleLineHeightMultiplier),
                        .textAlignment(.left)
                    ]),
                    .textColor(AppColors.Components.Text.main)
                ])
        )
        self.titleTopPadding = 32
        
        self.subtitle = [
            .textOverflow(FittingText()),
        ]
        let subtitleFont = Fonts.DMSans.regular.make(15)
        let subtitleLineHeightMultiplier = 1.23
        self.subtitleText = .attributedString(
            "asset-remove-subtitle"
                .localized
                .attributed([
                    .font(subtitleFont),
                    .lineHeightMultiplier(subtitleLineHeightMultiplier, subtitleFont),
                    .paragraph([
                        .lineHeightMultiple(subtitleLineHeightMultiplier),
                        .textAlignment(.left)
                    ]),
                    .textColor(AppColors.Components.Text.gray)
                ])
        )
        self.subtitleTopPadding = 16
        
        self.searchInputViewTheme = SearchInputViewCommonTheme(
            placeholder: "account-detail-assets-search".localized,
            family: family
        )
        self.searchInputViewTopPadding = 40
        
        self.collectionViewTopPadding = 20
        self.cellSpacing = 0
        
        self.horizontalPadding = 24
    }
}
