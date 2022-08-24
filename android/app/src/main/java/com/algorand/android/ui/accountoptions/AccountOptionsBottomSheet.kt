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

package com.algorand.android.ui.accountoptions

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountDetailAccountsOptionsBinding
import com.algorand.android.models.Account
import com.algorand.android.utils.Resource
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AccountOptionsBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_account_detail_accounts_options,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    private val args by navArgs<AccountOptionsBottomSheetArgs>()

    private val binding by viewBinding(BottomSheetAccountDetailAccountsOptionsBinding::bind)

    private val accountOptionsViewModel: AccountOptionsViewModel by viewModels()

    private val publicKey: String
        get() = args.publicKey

    private val notificationObserverCollector: suspend (Resource<Unit>?) -> Unit = {
        it?.use(onLoadingFinished = ::navBack)
    }

    private val notificationFilterCheckCollector: suspend (Boolean?) -> Unit = { isMuted ->
        isMuted?.let { setupNotificationOptionButton(it) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupViewPassphraseButton()
        setupCopyButton()
        setupShowQrButton()
        setupAuthAddressButton()
        setupRekeyOptionButton()
        setupRenameAccountButton()
        setupRemoveAccountButton()
        initObservers()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            accountOptionsViewModel.notificationFilterOperationFlow.collectLatest(notificationObserverCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            accountOptionsViewModel.notificationFilterCheckFlow.collect(notificationFilterCheckCollector)
        }
    }

    private fun setupRekeyOptionButton() {
        if (accountOptionsViewModel.getAccountType() != Account.Type.WATCH) {
            binding.rekeyButton.apply {
                show()
                setOnClickListener { navToRekeyAccountFragment() }
            }
        }
    }

    private fun setupNotificationOptionButton(isMuted: Boolean) {
        binding.notificationButton.apply {
            val textRes = if (isMuted) R.string.unmute_notifications else R.string.mute_notifications
            val iconRes = if (isMuted) R.drawable.ic_notification_unmute else R.drawable.ic_empty_notification
            setText(textRes)
            setIconResource(iconRes)
            setOnClickListener { accountOptionsViewModel.startFilterOperation(isMuted.not()) }
            show()
        }
    }

    private fun setupAuthAddressButton() {
        if (accountOptionsViewModel.isRekeyedToAnotherAccount()) {
            binding.authAddressButton.apply {
                show()
                setOnClickListener {
                    navToShowQrBottomSheet(
                        getString(R.string.auth_account_address),
                        accountOptionsViewModel.getAuthAddress().orEmpty()
                    )
                }
            }
        }
    }

    private fun setupRemoveAccountButton() {
        binding.disconnectAccountButton.apply {
            setOnClickListener { navToDisconnectAccountConfirmationBottomSheet() }
            show()
        }
    }

    private fun setupRenameAccountButton() {
        binding.renameAccountButton.apply {
            setOnClickListener { navToRenameAccountBottomSheet() }
            show()
        }
    }

    private fun navToRekeyAccountFragment() {
        nav(AccountOptionsBottomSheetDirections.actionAccountOptionsBottomSheetToRekeyAccountFragment(publicKey))
    }

    private fun navToDisconnectAccountConfirmationBottomSheet() {
        nav(
            AccountOptionsBottomSheetDirections.actionAccountOptionsBottomSheetToWarningConfirmationNavigation(
                accountOptionsViewModel.getRemovingAccountWarningConfirmationModel()
            )
        )
    }

    private fun navToRenameAccountBottomSheet() {
        nav(
            AccountOptionsBottomSheetDirections.actionAccountOptionsBottomSheetToRenameAccountBottomSheet(
                accountOptionsViewModel.getAccountName(),
                publicKey
            )
        )
    }

    private fun navToShowQrBottomSheet(title: String, publicKey: String) {
        nav(AccountOptionsBottomSheetDirections.actionAccountOptionsBottomSheetToShowQrBottomSheet(title, publicKey))
    }

    private fun setupViewPassphraseButton() {
        if (accountOptionsViewModel.getAccountType() == Account.Type.STANDARD) {
            binding.viewPassphraseButton.apply {
                show()
                setOnClickListener { navToViewPassphraseBottomSheet() }
            }
        }
    }

    private fun setupCopyButton() {
        with(binding) {
            copyAddressLayout.setOnClickListener {
                val publicKey = accountOptionsViewModel.getAccountAddress() ?: return@setOnClickListener
                context?.copyToClipboard(publicKey, ADDRESS_COPY_LABEL, false)
                showTopToast(getString(R.string.address_copied_to_clipboard), publicKey.toShortenedAddress())
                navBack()
            }
            addressTextView.text = accountOptionsViewModel.getAccountAddress()
        }
    }

    private fun setupShowQrButton() {
        binding.showQrButton.setOnClickListener {
            navToShowQrBottomSheet(getString(R.string.qr_code), publicKey)
        }
    }

    private fun navToViewPassphraseBottomSheet() {
        nav(
            AccountOptionsBottomSheetDirections
                .actionAccountOptionsBottomSheetToViewPassphraseLockBottomSheet(publicKey)
        )
    }

    companion object {
        private const val ADDRESS_COPY_LABEL = "address"
    }
}
