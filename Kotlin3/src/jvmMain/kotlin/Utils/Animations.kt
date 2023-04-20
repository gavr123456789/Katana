package Utils

import androidx.compose.animation.*
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.tween
import androidx.compose.ui.unit.IntSize

@OptIn(ExperimentalAnimationApi::class)
fun AnimatedContentScope<Boolean>.contentTransform() =
    fadeIn(animationSpec = tween(150, 150)) with
            fadeOut(animationSpec = tween(150)) using
            SizeTransform { initialSize, targetSize ->
                if (targetState) {
                    keyframes {
                        IntSize(targetSize.width, initialSize.height) at 150
                        durationMillis = 300
                    }
                } else {
                    keyframes {
                        IntSize(initialSize.width, targetSize.height) at 150
                        durationMillis = 300
                    }
                }
            }