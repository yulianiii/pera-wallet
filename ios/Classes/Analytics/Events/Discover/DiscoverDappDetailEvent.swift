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

//   DiscoverDappDetailEvent.swift

import Foundation
import MacaroonVendors

struct DiscoverDappDetailEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(dappParameters: DiscoverDappParamaters) {
        self.name = .discoverDappDetail

        var tempMetadata: ALGAnalyticsMetadata = [:]
        tempMetadata[.dappURL] = dappParameters.url

        if let dappName = dappParameters.name {
            tempMetadata[.dappName] = dappName
        }

        self.metadata = tempMetadata
    }
}

extension AnalyticsEvent where Self == DiscoverDappDetailEvent {
    static func discoverDappDetail(dappParameters: DiscoverDappParamaters) -> Self {
        return DiscoverDappDetailEvent(dappParameters: dappParameters)
    }
}