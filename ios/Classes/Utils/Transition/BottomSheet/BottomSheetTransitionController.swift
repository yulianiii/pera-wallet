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
//   BottomSheetTransitionController.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomSheet
import UIKit

final class BottomSheetTransitionController: MacaroonBottomSheet.BottomSheetTransitionController {
    init(presentingViewController: UIViewController, completion: @escaping () -> Void) {
        super.init(
            presentingViewController: presentingViewController,
            presentationConfiguration: BottomSheetPresentationConfiguration(),
            completion: completion
        )

        presentationConfiguration.overlayStyleSheet.handle = [
            .image("icon-bottom-sheet-handle")
        ]

        presentationConfiguration.chromeStyle = [
            .backgroundColor("bottomOverlayBackground")
        ]

        presentationConfiguration.overlayStyleSheet.backgroundShadow = MacaroonUIKit.Shadow(
            color: UIColor.clear,
            opacity: 0,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (16, 16),
            corners: .allCorners
        )
    }
}