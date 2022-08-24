/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.mapper

import com.algorand.android.decider.CurrencySelectionScreenStateViewTypeDecider
import com.algorand.android.models.ui.CurrencySelectionPreview
import com.algorand.android.ui.settings.selection.CurrencyListItem
import com.algorand.android.utils.DataResource
import javax.inject.Inject

class CurrencySelectionPreviewMapper @Inject constructor(
    private val currencySelectionScreenStateViewTypeDecider: CurrencySelectionScreenStateViewTypeDecider
) {

    fun mapToCurrencySelectionPreview(
        dataResource: DataResource<List<CurrencyListItem>>,
        isLoading: Boolean,
        isError: Boolean
    ): CurrencySelectionPreview {
        return CurrencySelectionPreview(
            isLoading = isLoading,
            isScreenStateViewVisible = isError,
            screenStateViewType = currencySelectionScreenStateViewTypeDecider.decideScreenStateViewType(dataResource),
            isContentVisible = isError.not() && isLoading.not(),
            currencyList = (dataResource as? DataResource.Success)?.data
        )
    }
}
