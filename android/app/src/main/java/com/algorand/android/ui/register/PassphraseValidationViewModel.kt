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

package com.algorand.android.ui.register

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.tracking.onboarding.register.OnboardingVerifyPassphraseEventTracker
import kotlinx.coroutines.launch

class PassphraseValidationViewModel @ViewModelInject constructor(
    private val onboardingVerifyPassphraseEventTracker: OnboardingVerifyPassphraseEventTracker
) : BaseViewModel() {

    fun logOnboardingNextClickEvent() {
        viewModelScope.launch {
            onboardingVerifyPassphraseEventTracker.logOnboardingVerifyPassphraseEvent()
        }
    }
}
