package cx.iio.the_daily_dad

import android.content.Context
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.support.v4.media.MediaBrowserCompat
import androidx.media.MediaBrowserServiceCompat
import android.support.v4.media.MediaDescriptionCompat
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import java.util.*

class AutoMediaService : MediaBrowserServiceCompat() {
    private lateinit var mediaSession: MediaSessionCompat
    private var textToSpeech: TextToSpeech? = null
    private var currentQueue: MutableList<MediaBrowserCompat.MediaItem> = mutableListOf()
    private var currentIndex: Int = 0
    private var isPlaying: Boolean = false
    private var categoryData: MutableMap<String, List<Map<String, Any>>> = mutableMapOf()

    companion object {
        private const val ROOT_ID = "root"
        private const val CATEGORY_NEWS = "news"
        private const val CATEGORY_JOKES = "jokes"
        private const val CATEGORY_FACTOIDS = "factoids"
        private const val CATEGORY_QUOTES = "quotes"
        private const val CATEGORY_TRIVIA = "trivia"

        @Volatile
        private var INSTANCE: AutoMediaService? = null

        val instance: AutoMediaService?
            get() = INSTANCE
    }

    override fun onCreate() {
        super.onCreate()
        INSTANCE = this
        android.util.Log.d("AutoMediaService", "Service onCreate called, instance set")

        // Initialize MediaSessionCompat
        mediaSession = MediaSessionCompat(this@AutoMediaService, "AutoMediaService")
        sessionToken = mediaSession.sessionToken
        android.util.Log.d("AutoMediaService", "MediaSession initialized, sessionToken set")

        // Set callback for media session
        mediaSession.setCallback(object : MediaSessionCompat.Callback() {
            override fun onPlay() {
                this@AutoMediaService.onPlay()
            }

            override fun onPause() {
                this@AutoMediaService.onPause()
            }

            override fun onStop() {
                this@AutoMediaService.onStop()
            }

            override fun onSkipToNext() {
                this@AutoMediaService.onSkipToNext()
            }

            override fun onSkipToPrevious() {
                this@AutoMediaService.onSkipToPrevious()
            }

            override fun onPlayFromMediaId(mediaId: String?, extras: Bundle?) {
                mediaId?.let { this@AutoMediaService.onPlayFromMediaId(it, extras) }
            }
        })

        // Initialize TextToSpeech
        textToSpeech = TextToSpeech(this@AutoMediaService) { status ->
            if (status == TextToSpeech.SUCCESS) {
                textToSpeech?.language = Locale.getDefault()
            }
        }

        // Set initial playback state
        updatePlaybackState()
    }

    override fun onGetRoot(clientPackageName: String, clientUid: Int, rootHints: Bundle?): MediaBrowserServiceCompat.BrowserRoot? {
        android.util.Log.d("AutoMediaService", "onGetRoot called for client: $clientPackageName")
        return MediaBrowserServiceCompat.BrowserRoot(ROOT_ID, null)
    }

    override fun onLoadChildren(parentId: String, result: Result<List<MediaBrowserCompat.MediaItem>>) {
        android.util.Log.d("AutoMediaService", "onLoadChildren called for parentId: $parentId")
        val children = when (parentId) {
            ROOT_ID -> {
                android.util.Log.d("AutoMediaService", "Loading root categories")
                val categories = listOf(
                    createMediaItem("News", CATEGORY_NEWS, true),
                    createMediaItem("Jokes", CATEGORY_JOKES, true),
                    createMediaItem("Factoids", CATEGORY_FACTOIDS, true),
                    createMediaItem("Quotes", CATEGORY_QUOTES, true),
                    createMediaItem("Trivia", CATEGORY_TRIVIA, true)
                )
                android.util.Log.d("AutoMediaService", "Created ${categories.size} root categories")
                categories
            }
            else -> {
                // Load items for the selected category
                android.util.Log.d("AutoMediaService", "Loading items for category: $parentId")
                loadCategoryItems(parentId)
            }
        }
        android.util.Log.d("AutoMediaService", "Sending ${children.size} items for parentId: $parentId")
        result.sendResult(children)
    }

    private fun createMediaItem(title: String, mediaId: String, isBrowsable: Boolean): MediaBrowserCompat.MediaItem {
        val description = MediaDescriptionCompat.Builder()
            .setMediaId(mediaId)
            .setTitle(title)
            .build()

        val flags = if (isBrowsable) {
            MediaBrowserCompat.MediaItem.FLAG_BROWSABLE
        } else {
            MediaBrowserCompat.MediaItem.FLAG_PLAYABLE
        }

        return MediaBrowserCompat.MediaItem(description, flags)
    }

    private fun loadCategoryItems(categoryId: String): List<MediaBrowserCompat.MediaItem> {
        android.util.Log.d("AutoMediaService", "Loading category items for: $categoryId")
        android.util.Log.d("AutoMediaService", "Available categories: ${categoryData.keys.joinToString()}")
        android.util.Log.d("AutoMediaService", "Category data map size: ${categoryData.size}")

        // Log all category keys for debugging
        categoryData.keys.forEach { key ->
            android.util.Log.d("AutoMediaService", "  Category key: '$key' (length: ${key.length})")
        }

        val items = categoryData[categoryId]
        android.util.Log.d("AutoMediaService", "Found ${items?.size ?: 0} items for category '$categoryId'")

        if (items == null) {
            android.util.Log.w("AutoMediaService", "No items found for category '$categoryId' - category not in map")
            return emptyList()
        }

        if (items.isEmpty()) {
            android.util.Log.w("AutoMediaService", "Items list is empty for category '$categoryId'")
            return emptyList()
        }

        android.util.Log.d("AutoMediaService", "Processing ${items.size} items for category '$categoryId'")

        return items.mapIndexed { index, item ->
            val title = when (categoryId) {
                CATEGORY_NEWS -> item["title"] as? String ?: ""
                CATEGORY_JOKES -> item["joke"] as? String ?: ""
                CATEGORY_FACTOIDS -> item["fact"] as? String ?: ""
                CATEGORY_QUOTES -> {
                    val quote = item["quote"] as? String ?: (item["q"] as? String ?: "")
                    val author = item["author"] as? String ?: (item["a"] as? String ?: "Unknown")
                    "$quote - $author"
                }
                CATEGORY_TRIVIA -> item["question"] as? String ?: ""
                else -> ""
            }

            val description = MediaDescriptionCompat.Builder()
                .setMediaId("$categoryId:$index")
                .setTitle(title)
                .build()

            MediaBrowserCompat.MediaItem(description, MediaBrowserCompat.MediaItem.FLAG_PLAYABLE)
        }
    }

    fun setCategoryItems(categoryId: String, items: List<Map<String, Any>>) {
        android.util.Log.d("AutoMediaService", "Setting category items for $categoryId: ${items.size} items")
        categoryData[categoryId] = items
        android.util.Log.d("AutoMediaService", "Category data stored. Total categories: ${categoryData.keys.size}")

        // Notify Android Auto that the media items have changed for this category
        try {
            notifyChildrenChanged(categoryId)
            android.util.Log.d("AutoMediaService", "Notified children changed for category: $categoryId")
        } catch (e: Exception) {
            android.util.Log.e("AutoMediaService", "Error notifying children changed: $e")
        }

        // Also notify root in case categories list changed
        try {
            notifyChildrenChanged(ROOT_ID)
            android.util.Log.d("AutoMediaService", "Notified children changed for root")
        } catch (e: Exception) {
            android.util.Log.e("AutoMediaService", "Error notifying root children changed: $e")
        }

        // Reset queue if this was the current category
        if (currentQueue.isNotEmpty() &&
            currentQueue.firstOrNull()?.description?.mediaId?.startsWith(categoryId) == true) {
            currentQueue.clear()
            currentIndex = 0
        }
    }

    private fun onPlayFromMediaId(mediaId: String, extras: Bundle?) {
        val parts = mediaId.split(":")
        if (parts.size == 2) {
            val categoryId = parts[0]
            val index = parts[1].toIntOrNull() ?: 0

            // Load items for this category if not already loaded
            val items = loadCategoryItems(categoryId)
            if (items.isNotEmpty()) {
                currentQueue.clear()
                currentQueue.addAll(items)
                playItem(categoryId, index)
            }
        }
    }

    private fun playItem(categoryId: String, index: Int) {
        if (index < currentQueue.size) {
            currentIndex = index
            val item = currentQueue[index]
            val text = item.description.title?.toString() ?: ""

            // Stop any current playback
            textToSpeech?.stop()

            // Speak the text
            textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
            isPlaying = true

            // Update metadata
            val metadata = MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE, text)
                .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, "$categoryId:$index")
                .build()
            mediaSession.setMetadata(metadata)

            updatePlaybackState()
        }
    }

    private fun onPlay() {
        if (currentQueue.isNotEmpty() && currentIndex < currentQueue.size) {
            val item = currentQueue[currentIndex]
            val text = item.description.title?.toString() ?: ""
            textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
            isPlaying = true
            updatePlaybackState()
        }
    }

    private fun onPause() {
        textToSpeech?.stop()
        isPlaying = false
        updatePlaybackState()
    }

    private fun onStop() {
        textToSpeech?.stop()
        isPlaying = false
        updatePlaybackState()
    }

    private fun onSkipToNext() {
        if (currentIndex < currentQueue.size - 1) {
            currentIndex++
            val mediaId = currentQueue[currentIndex].description.mediaId ?: ""
            val categoryId = mediaId.split(":").getOrNull(0) ?: ""
            playItem(categoryId, currentIndex)
        }
    }

    private fun onSkipToPrevious() {
        if (currentIndex > 0) {
            currentIndex--
            val mediaId = currentQueue[currentIndex].description.mediaId ?: ""
            val categoryId = mediaId.split(":").getOrNull(0) ?: ""
            playItem(categoryId, currentIndex)
        }
    }

    private fun updatePlaybackState() {
        val state = if (isPlaying) {
            PlaybackStateCompat.STATE_PLAYING
        } else {
            PlaybackStateCompat.STATE_PAUSED
        }

        val playbackState = PlaybackStateCompat.Builder()
            .setState(state, PlaybackStateCompat.PLAYBACK_POSITION_UNKNOWN, 1.0f)
            .setActions(
                PlaybackStateCompat.ACTION_PLAY or
                PlaybackStateCompat.ACTION_PAUSE or
                PlaybackStateCompat.ACTION_SKIP_TO_NEXT or
                PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS
            )
            .build()

        mediaSession.setPlaybackState(playbackState)
    }

    override fun onDestroy() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        mediaSession.release()
        INSTANCE = null
        super.onDestroy()
    }
}
