package experiments

import androidx.compose.runtime.*
import androidx.compose.material.*
import androidx.compose.runtime.mutableStateOf

@Composable
fun MyComposible() {
    println("1")
    var myVal by remember {mutableStateOf(false)}
    Button(onClick = {myVal = !myVal}) {

        Text("sas" + myVal)
    }
}