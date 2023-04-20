package Utils

import androidx.compose.runtime.mutableStateOf

@Suppress("NOTHING_TO_INLINE")
inline fun <T> mso(v: T) =
    mutableStateOf(v)