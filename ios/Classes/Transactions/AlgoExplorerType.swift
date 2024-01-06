// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgoExplorerType.swift

import Foundation

enum AlgoExplorerType {
    case algoexplorer
    case goalseeker

    func transactionURL(with id: String, in network: ALGAPI.Network) -> URL? {
        switch network {
        case .testnet:
            return testNetTransactionURL(with: id)
        case .mainnet, .localnet:
            return mainNetTransactionURL(with: id)
        }
    }

    private func testNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://testnet.algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/testnet/transaction/\(id)")
        }
    }

    private func mainNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/mainnet/transaction/\(id)")
        }
    }
}
