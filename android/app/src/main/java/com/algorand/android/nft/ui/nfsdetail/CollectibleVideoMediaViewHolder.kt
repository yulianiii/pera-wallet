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

package com.algorand.android.nft.ui.nfsdetail

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.algorand.android.databinding.ItemCollectibleVideoMediaBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.utils.loadImage

class CollectibleVideoMediaViewHolder(
    private val binding: ItemCollectibleVideoMediaBinding,
    private val listener: CollectibleVideoMediaViewHolderListener
) : BaseCollectibleMediaViewHolder(binding.root) {

    override fun bind(item: BaseCollectibleMediaItem) {
        if (item !is BaseCollectibleMediaItem.VideoCollectibleMediaItem) return
        with(binding.collectibleVideoCollectibleImageView) {
            setOnClickListener { listener.onVideoClick(item.previewUrl, this) }
            context.loadImage(
                item.previewUrl.orEmpty(),
                onResourceReady = {
                    showImage(it)
                    showVideoPlayButton()
                },
                onLoadFailed = { showText(item.errorText) }
            )
        }
    }

    fun interface CollectibleVideoMediaViewHolderListener {
        fun onVideoClick(imageUrl: String?, collectibleImageView: View)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: CollectibleVideoMediaViewHolderListener
        ): CollectibleVideoMediaViewHolder {
            val binding = ItemCollectibleVideoMediaBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleVideoMediaViewHolder(binding, listener)
        }
    }
}
