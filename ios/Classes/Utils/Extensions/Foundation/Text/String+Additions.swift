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

//   String+Additions.swift

import Foundation

extension String {
    func safeSubstring(
        with range: Range<Index>
    ) -> Substring {
        let from = range.lowerBound
        let to = range.upperBound

        guard from <= to else {
            return self[startIndex...]
        }

        guard from >= startIndex && to <= endIndex else {
            return self[startIndex...]
        }

        return self[from..<to]
    }
}

extension StringProtocol {
    var endIndexOfFirstWord: Index {
        let aRange = rangeOfCharacter(from: .whitespacesAndNewlines)
        return aRange?.lowerBound ?? endIndex
    }

    var startIndexOfLastWord: Index {
        let aRange = rangeOfCharacter(from: .whitespacesAndNewlines, options: .backwards)
        return aRange?.upperBound ?? startIndex
    }
}

extension String? {
    func toURL() -> URL? {
        return self
            .unwrapNonEmptyString()
            .unwrap(URL.init)
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    var isDigits: Bool {
        if isEmpty { return false }
        // The inverted set of .decimalDigits is every character minus digits
        let nonDigits = CharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: nonDigits) == nil
    }
}
