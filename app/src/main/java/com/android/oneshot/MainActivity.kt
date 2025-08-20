package com.android.oneshot

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import com.android.oneshot.ui.theme.OneshotTheme
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            OneshotTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    OneshotApp(
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun OneshotApp(modifier: Modifier = Modifier) {
    var interfaceName by remember { mutableStateOf("wlan0") }
    var bssid by remember { mutableStateOf("") }
    var pin by remember { mutableStateOf("") }
    var showHelp by remember { mutableStateOf(false) }
    var showAdvanced by remember { mutableStateOf(false) }
    var showVersion by remember { mutableStateOf(false) }
    var defaultPin by remember { mutableStateOf(false) }
    var noColors by remember { mutableStateOf(false) }
    var unlimited by remember { mutableStateOf(false) }
    var timeLimit by remember { mutableStateOf("") }
    var delay by remember { mutableStateOf("") }
    var aoss by remember { mutableStateOf(false) }
    var wpsPin by remember { mutableStateOf(false) }
    var output by remember { mutableStateOf("") }
    val context = LocalContext.current

    Column(modifier = modifier) {
        TextField(
            value = interfaceName,
            onValueChange = { interfaceName = it },
            label = { Text("Interface Name") }
        )
        TextField(
            value = bssid,
            onValueChange = { bssid = it },
            label = { Text("BSSID") }
        )
        TextField(
            value = pin,
            onValueChange = { pin = it },
            label = { Text("PIN") }
        )
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = showHelp,
                onCheckedChange = { showHelp = it }
            )
            Text("Show Help")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = showAdvanced,
                onCheckedChange = { showAdvanced = it }
            )
            Text("Show Advanced Options")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = showVersion,
                onCheckedChange = { showVersion = it }
            )
            Text("Show Version")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = defaultPin,
                onCheckedChange = { defaultPin = it }
            )
            Text("Default Pin")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = noColors,
                onCheckedChange = { noColors = it }
            )
            Text("No Colors")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = unlimited,
                onCheckedChange = { unlimited = it }
            )
            Text("Unlimited")
        }
        TextField(
            value = timeLimit,
            onValueChange = { timeLimit = it },
            label = { Text("Time Limit") }
        )
        TextField(
            value = delay,
            onValueChange = { delay = it },
            label = { Text("Delay") }
        )
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = aoss,
                onCheckedChange = { aoss = it }
            )
            Text("AOSS")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = wpsPin,
                onCheckedChange = { wpsPin = it }
            )
            Text("WPS Pin")
        }
        Button(onClick = {
            output = runScript(
                context,
                interfaceName,
                bssid,
                pin,
                showHelp,
                showAdvanced,
                showVersion,
                defaultPin,
                noColors,
                unlimited,
                timeLimit,
                delay,
                aoss,
                wpsPin
            )
        }) {
            Text("Run Oneshot")
        }
        Text(text = output)
    }
}

private fun runScript(
    context: Context,
    interfaceName: String,
    bssid: String,
    pin: String,
    showHelp: Boolean,
    showAdvanced: Boolean,
    showVersion: Boolean,
    defaultPin: Boolean,
    noColors: Boolean,
    unlimited: Boolean,
    timeLimit: String,
    delay: String,
    aoss: Boolean,
    wpsPin: Boolean
): String {
    try {
        val scriptFile = copyScriptToInternalStorage(context)
        val command = buildString {
            append("su -c python ${scriptFile.absolutePath}")
            if (interfaceName.isNotBlank()) append(" -i $interfaceName")
            if (bssid.isNotBlank()) append(" -b $bssid")
            if (pin.isNotBlank()) append(" -p $pin")
            if (showHelp) append(" --help")
            if (showAdvanced) append(" --show-advanced")
            if (showVersion) append(" --version")
            if (defaultPin) append(" -K")
            if (noColors) append(" --no-colors")
            if (unlimited) append(" -L")
            if (timeLimit.isNotBlank()) append(" -t $timeLimit")
            if (delay.isNotBlank()) append(" -d $delay")
            if (aoss) append(" -A")
            if (wpsPin) append(" --wps-pin")
        }

        val process = Runtime.getRuntime().exec(command)
        val reader = BufferedReader(InputStreamReader(process.inputStream))
        val output = StringBuilder()
        var line: String?
        while (reader.readLine().also { line = it } != null) {
            output.append(line).append("\n")
        }
        process.waitFor()
        return output.toString()
    } catch (e: Exception) {
        return e.message ?: "An error occurred"
    }
}

private fun copyScriptToInternalStorage(context: Context): File {
    val scriptFile = File(context.filesDir, "oneshot.py")
    if (!scriptFile.exists()) {
        context.resources.openRawResource(R.raw.oneshot_py).use { inputStream ->
            scriptFile.outputStream().use { outputStream ->
                inputStream.copyTo(outputStream)
            }
        }
        scriptFile.setExecutable(true)
    }
    return scriptFile
}


@Preview(showBackground = true)
@Composable
fun OneshotAppPreview() {
    OneshotTheme {
        OneshotApp()
    }
}
