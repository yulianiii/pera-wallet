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
//   AlgosDetailInfoViewCell.swift

import UIKit
import MacaroonUIKit

final class AlgosDetailInfoViewCell:
    CollectionCell<AlgosDetailInfoView>,
    ViewModelBindable {
    weak var delegate: AlgosDetailInfoViewCellDelegate?

    static let theme = AlgosDetailInfoViewTheme()

    override func prepareLayout() {
        super.prepareLayout()
        contextView.customize(Self.theme)
    }

    override func setListeners() {
        contextView.setListeners()
        contextView.delegate = self
    }
}

extension AlgosDetailInfoViewCell: AlgosDetailInfoViewDelegate {
    func algosDetailInfoViewDidTapInfoButton(_ algosDetailInfoView: AlgosDetailInfoView) {
        delegate?.algosDetailInfoViewCellDidTapInfoButton(self)
    }

    func algosDetailInfoViewDidTapBuyButton(_ algosDetailInfoView: AlgosDetailInfoView) {
        delegate?.algosDetailInfoViewCellDidTapBuyButton(self)
    }
}

protocol AlgosDetailInfoViewCellDelegate: AnyObject {
    func algosDetailInfoViewCellDidTapInfoButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell)
    func algosDetailInfoViewCellDidTapBuyButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell)
}
