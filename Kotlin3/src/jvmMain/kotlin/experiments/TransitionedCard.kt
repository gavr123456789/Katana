package experiments

import androidx.compose.animation.*
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.*
import Utils.contentTransform

@OptIn(ExperimentalMaterialApi::class, ExperimentalAnimationApi::class)
@Composable
fun TransitionedCard() {
    var expanded by remember { mutableStateOf(false) }
    Surface(
        color = MaterialTheme.colors.primary,
        onClick = { expanded = !expanded }
    ) {
        AnimatedContent(
            targetState = expanded,
            transitionSpec = {
                contentTransform()
            }
        ) { targetExpanded ->
            if (targetExpanded) {
                Text("asdasdqwe\nqweqwe\nqwa\nsasqwe")
            } else {
                Text("Click me")
            }
        }
    }
}