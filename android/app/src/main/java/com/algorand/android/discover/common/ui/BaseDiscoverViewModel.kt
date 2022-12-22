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

package com.algorand.android.discover.common.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.customviews.PeraWebView
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.utils.preference.ThemePreference
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

abstract class BaseDiscoverViewModel : BaseViewModel() {

    private val _discoverWebViewFlow: MutableStateFlow<PeraWebView?> = MutableStateFlow(null)
    private val _discoverLastErrorFlow: MutableStateFlow<WebViewError?> = MutableStateFlow(null)

    fun saveWebView(webView: PeraWebView?) {
        viewModelScope.launch {
            _discoverWebViewFlow
                .emit(webView)
        }
    }

    fun getWebView(): PeraWebView? {
        return _discoverWebViewFlow.value
    }

    fun saveLastError(error: WebViewError?) {
        viewModelScope.launch {
            _discoverLastErrorFlow
                .emit(error)
        }
    }

    fun getLastError(): WebViewError? {
        return _discoverLastErrorFlow.value
    }

    abstract fun onPageRequested()
    abstract fun onPageFinished()
    abstract fun onError()
    abstract fun onHttpError()
    open fun onPageUrlChanged() {}
    abstract fun getDiscoverThemePreference(): ThemePreference
}