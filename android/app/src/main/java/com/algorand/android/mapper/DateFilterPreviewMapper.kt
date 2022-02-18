/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.mapper

import com.algorand.android.decider.DateFilterImageResourceDecider
import com.algorand.android.decider.DateFilterTitleDecider
import com.algorand.android.decider.DateFilterTitleResIdDecider
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ui.DateFilterPreview
import javax.inject.Inject

class DateFilterPreviewMapper @Inject constructor(
    private val dateFilterImageResourceDecider: DateFilterImageResourceDecider,
    private val dateFilterTitleDecider: DateFilterTitleDecider,
    private val dateFilterTitleResIdDecider: DateFilterTitleResIdDecider,
) {

    fun mapToDateFilterPreview(dateFilter: DateFilter): DateFilterPreview {
        return DateFilterPreview(
            dateFilterImageResourceDecider.decideDateFilterImageRes(dateFilter),
            dateFilterTitleDecider.decideDateFilterTitle(dateFilter),
            dateFilterTitleResIdDecider.decideDateFilterTitleResId(dateFilter)
        )
    }
}