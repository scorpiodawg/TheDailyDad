package cx.iio.the_daily_dad

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
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

                // Set audio attributes for Android Auto - use STREAM_MUSIC so it plays through car speakers
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .build()
                textToSpeech?.setAudioAttributes(audioAttributes)

                android.util.Log.d("AutoMediaService", "TextToSpeech initialized successfully with audio attributes")
            } else {
                android.util.Log.e("AutoMediaService", "TextToSpeech initialization failed with status: $status")
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
        android.util.Log.d("AutoMediaService", "onPlayFromMediaId called with mediaId: $mediaId")
        val parts = mediaId.split(":")
        if (parts.size == 2) {
            val categoryId = parts[0]
            val index = parts[1].toIntOrNull() ?: 0
            android.util.Log.d("AutoMediaService", "Playing category: $categoryId, index: $index")

            // Load items for this category if not already loaded
            val items = loadCategoryItems(categoryId)
            if (items.isNotEmpty()) {
                currentQueue.clear()
                currentQueue.addAll(items)
                playItem(categoryId, index)
            } else {
                android.util.Log.w("AutoMediaService", "No items found for category: $categoryId")
            }
        } else {
            android.util.Log.w("AutoMediaService", "Invalid mediaId format: $mediaId")
        }
    }

    private fun playItem(categoryId: String, index: Int) {
        if (index < currentQueue.size) {
            currentIndex = index
            val item = currentQueue[index]
            val text = item.description.title?.toString() ?: ""

            android.util.Log.d("AutoMediaService", "playItem called - text length: ${text.length}, TTS ready: ${textToSpeech != null}")

            if (text.isEmpty()) {
                android.util.Log.w("AutoMediaService", "Text is empty, cannot play")
                return
            }

            if (textToSpeech == null) {
                android.util.Log.e("AutoMediaService", "TextToSpeech is null!")
                return
            }

            // Check if TTS is ready
            val ttsStatus = textToSpeech?.isLanguageAvailable(Locale.getDefault()) ?: TextToSpeech.ERROR
            android.util.Log.d("AutoMediaService", "TTS language availability: $ttsStatus")

            // Stop any current playback
            textToSpeech?.stop()

            // Request audio focus for playback
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val focusRequest = audioManager.requestAudioFocus(
                null,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
            )
            android.util.Log.d("AutoMediaService", "Audio focus request result: $focusRequest")

            // Speak the text with QUEUE_FLUSH to replace any current speech
            val speakResult = textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "tts_${categoryId}_${index}")
            android.util.Log.d("AutoMediaService", "TTS speak called, result: $speakResult")

            if (speakResult == TextToSpeech.SUCCESS) {
                android.util.Log.d("AutoMediaService", "TTS speak queued successfully")
            }

            if (speakResult == TextToSpeech.ERROR) {
                android.util.Log.e("AutoMediaService", "TTS speak returned ERROR")
            }

            isPlaying = true

            // Update metadata
            val metadata = MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE, text)
                .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, "$categoryId:$index")
                .build()
            mediaSession.setMetadata(metadata)

            updatePlaybackState()
        } else {
            android.util.Log.w("AutoMediaService", "Index $index out of bounds for queue size ${currentQueue.size}")
        }
    }

    private fun onPlay() {
        android.util.Log.d("AutoMediaService", "onPlay called")
        if (currentQueue.isNotEmpty() && currentIndex < currentQueue.size) {
            val item = currentQueue[currentIndex]
            val text = item.description.title?.toString() ?: ""
            android.util.Log.d("AutoMediaService", "Playing text: ${text.take(50)}...")

            if (textToSpeech != null) {
                val speakResult = textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
                android.util.Log.d("AutoMediaService", "TTS speak result: $speakResult")
                isPlaying = true
                updatePlaybackState()
            } else {
                android.util.Log.e("AutoMediaService", "TextToSpeech is null in onPlay")
            }
        } else {
            android.util.Log.w("AutoMediaService", "Cannot play - queue empty or index out of bounds")
        }
    }

    private fun onPause() {
        android.util.Log.d("AutoMediaService", "onPause called")
        textToSpeech?.stop()
        isPlaying = false

        // Release audio focus
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.abandonAudioFocus(null)

        updatePlaybackState()
    }

    private fun onStop() {
        android.util.Log.d("AutoMediaService", "onStop called")
        textToSpeech?.stop()
        isPlaying = false

        // Release audio focus
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.abandonAudioFocus(null)

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
