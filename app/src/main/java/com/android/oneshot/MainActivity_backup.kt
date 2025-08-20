package com.android.oneshot

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.android.oneshot.ui.theme.*
import kotlinx.coroutines.delay
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            OneshotTheme {
                HackerApp()
            }
        }
    }
}

// Data classes for WiFi networks
data class WiFiNetwork(
    val ssid: String,
    val bssid: String,
    val signalStrength: Int,
    val security: String,
    val frequency: String,
    val isVulnerable: Boolean = false,
    val crackedPassword: String? = null,
    val attackStatus: AttackStatus = AttackStatus.NONE
)

enum class AttackStatus {
    NONE, SCANNING, ATTACKING, SUCCESS, FAILED
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HackerApp() {
    var currentScreen by remember { mutableStateOf(Screen.MAIN) }
    var networks by remember { mutableStateOf<List<WiFiNetwork>>(emptyList()) }
    var isScanning by remember { mutableStateOf(false) }
    var isAttacking by remember { mutableStateOf(false) }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(HackerBlack, TerminalBlack),
                    startY = 0f,
                    endY = 1000f
                )
            )
            .padding(16.dp)
    ) {
        // Header with hacker aesthetic
        HackerHeader()
        
        Spacer(modifier = Modifier.height(24.dp))
        
        when (currentScreen) {
            Screen.MAIN -> {
                MainScreen(
                    onScanClick = { 
                        currentScreen = Screen.SCANNER
                        isScanning = true
                    },
                    onAdvancedClick = { currentScreen = Screen.ADVANCED }
                )
            }
            Screen.SCANNER -> {
                ScannerScreen(
                    networks = networks,
                    isScanning = isScanning,
                    isAttacking = isAttacking,
                    onScanComplete = { scannedNetworks ->
                        networks = scannedNetworks
                        isScanning = false
                    },
                    onAttackClick = { vulnerableNetworks ->
                        isAttacking = true
                        // Start attacking logic here
                    },
                    onBackClick = { currentScreen = Screen.MAIN }
                )
            }
            Screen.ADVANCED -> {
                AdvancedScreen(onBackClick = { currentScreen = Screen.MAIN })
            }
        }
    }
}

enum class Screen {
    MAIN, SCANNER, ADVANCED
}

@Composable
fun HackerHeader() {
    val infiniteTransition = rememberInfiniteTransition(label = "")
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.6f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ), label = ""
    )
    
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(
            text = "◉ ONESHOT ◉",
            style = MaterialTheme.typography.headlineLarge,
            color = NeonGreen,
            modifier = Modifier.alpha(alpha),
            textAlign = TextAlign.Center
        )
        
        Text(
            text = "WiFi WPS Penetration Suite",
            style = MaterialTheme.typography.bodyMedium,
            color = MatrixGreen,
            textAlign = TextAlign.Center
        )
        
        Text(
            text = "» AUTHORIZED TESTING ONLY «",
            style = MaterialTheme.typography.labelSmall,
            color = ErrorRed,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(top = 4.dp)
        )
    }
}

@Composable
fun MainScreen(
    onScanClick: () -> Unit,
    onAdvancedClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(20.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Spacer(modifier = Modifier.height(32.dp))
        
        // Main scan button
        HackerButton(
            text = "⚡ SCAN NETWORKS ⚡",
            onClick = onScanClick,
            color = NeonGreen,
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp)
        )
        
        // Advanced options button
        HackerButton(
            text = "⚙ ADVANCED OPTIONS ⚙",
            onClick = onAdvancedClick,
            color = NeonBlue,
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        // Status card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .border(1.dp, MatrixGreen, RoundedCornerShape(12.dp)),
            colors = CardDefaults.cardColors(containerColor = CardDark)
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    imageVector = Icons.Default.Security,
                    contentDescription = null,
                    tint = NeonOrange,
                    modifier = Modifier.size(32.dp)
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "SYSTEM STATUS",
                    style = MaterialTheme.typography.titleMedium,
                    color = HackerGreen
                )
                
                Text(
                    text = "Root access required for WiFi penetration testing",
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@Composable
fun ScannerScreen(
    networks: List<WiFiNetwork>,
    isScanning: Boolean,
    isAttacking: Boolean,
    onScanComplete: (List<WiFiNetwork>) -> Unit,
    onAttackClick: (List<WiFiNetwork>) -> Unit,
    onBackClick: () -> Unit
) {
    val context = LocalContext.current
    
    // Simulate network scanning
    LaunchedEffect(isScanning) {
        if (isScanning) {
            delay(3000) // Simulate scan time
            onScanComplete(generateMockNetworks())
        }
    }
    
    Column(modifier = Modifier.fillMaxWidth()) {
        // Controls
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            HackerButton(
                text = "← BACK",
                onClick = onBackClick,
                color = ConsoleGray,
                modifier = Modifier.weight(1f)
            )
            
            HackerButton(
                text = "🔍 SCAN",
                onClick = { /* Rescan */ },
                color = NeonBlue,
                modifier = Modifier.weight(1f)
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Vulnerable networks attack button
        val vulnerableNetworks = networks.filter { it.isVulnerable }
        if (vulnerableNetworks.isNotEmpty()) {
            HackerButton(
                text = "⚔ ATTACK ${vulnerableNetworks.size} VULNERABLE NETWORKS ⚔",
                onClick = { onAttackClick(vulnerableNetworks) },
                color = ErrorRed,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
        }
        
        // Network list
        if (isScanning) {
            ScanningIndicator()
        } else {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(networks) { network ->
                    NetworkCard(network = network)
                }
            }
        }
    }
}

@Composable
fun AdvancedScreen(onBackClick: () -> Unit) {
    Column(modifier = Modifier.fillMaxWidth()) {
        HackerButton(
            text = "← BACK TO MAIN",
            onClick = onBackClick,
            color = ConsoleGray,
            modifier = Modifier.fillMaxWidth()
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        Text(
            text = "⚙ ADVANCED OPTIONS ⚙",
            style = MaterialTheme.typography.headlineSmall,
            color = NeonBlue,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
        
        Spacer(modifier = Modifier.height(20.dp))
        
        // Advanced options will be implemented here
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .border(1.dp, NeonBlue, RoundedCornerShape(12.dp)),
            colors = CardDefaults.cardColors(containerColor = CardDark)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "COMING SOON",
                    style = MaterialTheme.typography.titleMedium,
                    color = NeonOrange
                )
                
                Text(
                    text = "• Custom interface selection\n• Manual BSSID targeting\n• PIN generation options\n• Attack timing controls",
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }
    }
}

@Composable
fun HackerButton(
    text: String,
    onClick: () -> Unit,
    color: Color,
    modifier: Modifier = Modifier
) {
    val animatedColor by animateColorAsState(
        targetValue = color,
        animationSpec = tween(300), label = ""
    )
    
    OutlinedButton(
        onClick = onClick,
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .border(
                width = 2.dp,
                color = animatedColor,
                shape = RoundedCornerShape(8.dp)
            ),
        colors = ButtonDefaults.outlinedButtonColors(
            containerColor = Color.Transparent,
            contentColor = animatedColor
        ),
        border = null
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelLarge,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun NetworkCard(network: WiFiNetwork) {
    val cardColor = when {
        network.isVulnerable -> VulnerableRed
        network.security.contains("WPS") -> UnknownOrange
        else -> SafeGreen
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .border(1.dp, cardColor, RoundedCornerShape(8.dp))
            .clickable { /* Network details */ },
        colors = CardDefaults.cardColors(containerColor = CardDark)
    ) {
        Column(
            modifier = Modifier.padding(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = when {
                            network.isVulnerable -> Icons.Default.LockOpen
                            network.security.contains("WPS") -> Icons.Default.Warning
                            else -> Icons.Default.Lock
                        },
                        contentDescription = null,
                        tint = cardColor,
                        modifier = Modifier.size(20.dp)
                    )
                    
                    Spacer(modifier = Modifier.width(8.dp))
                    
                    Column {
                        Text(
                            text = network.ssid,
                            style = MaterialTheme.typography.titleSmall,
                            color = HackerGreen,
                            fontWeight = FontWeight.Bold
                        )
                        
                        Text(
                            text = network.bssid,
                            style = MaterialTheme.typography.bodySmall,
                            color = ConsoleGray
                        )
                    }
                }
                
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "${network.signalStrength}%",
                        style = MaterialTheme.typography.labelSmall,
                        color = when {
                            network.signalStrength > 70 -> NeonGreen
                            network.signalStrength > 40 -> NeonOrange
                            else -> ErrorRed
                        }
                    )
                    
                    Text(
                        text = network.frequency,
                        style = MaterialTheme.typography.labelSmall,
                        color = ConsoleGray
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = network.security,
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray
                )
                
                if (network.isVulnerable) {
                    Text(
                        text = "VULNERABLE",
                        style = MaterialTheme.typography.labelSmall,
                        color = VulnerableRed,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            
            // Show cracked password if available
            network.crackedPassword?.let { password ->
                Spacer(modifier = Modifier.height(8.dp))
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = HackerBlack)
                ) {
                    Row(
                        modifier = Modifier.padding(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "PASSWORD: ",
                            style = MaterialTheme.typography.labelSmall,
                            color = NeonGreen
                        )
                        Text(
                            text = password,
                            style = MaterialTheme.typography.labelSmall,
                            color = NeonBlue,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun ScanningIndicator() {
    val infiniteTransition = rememberInfiniteTransition(label = "")
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000),
            repeatMode = RepeatMode.Reverse
        ), label = ""
    )
    
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp)
    ) {
        Icon(
            imageVector = Icons.Default.Wifi,
            contentDescription = null,
            tint = NeonBlue,
            modifier = Modifier
                .size(64.dp)
                .alpha(alpha)
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            text = "SCANNING NETWORKS...",
            style = MaterialTheme.typography.titleMedium,
            color = NeonBlue,
            modifier = Modifier.alpha(alpha)
        )
        
        Text(
            text = "Discovering WiFi access points",
            style = MaterialTheme.typography.bodySmall,
            color = ConsoleGray
        )
    }
}

// Mock data generator for testing
fun generateMockNetworks(): List<WiFiNetwork> {
    return listOf(
        WiFiNetwork(
            ssid = "HomeRouter_2.4G",
            bssid = "AA:BB:CC:DD:EE:FF",
            signalStrength = 85,
            security = "WPA2-PSK WPS",
            frequency = "2.4GHz",
            isVulnerable = true
        ),
        WiFiNetwork(
            ssid = "OfficeWiFi",
            bssid = "11:22:33:44:55:66",
            signalStrength = 72,
            security = "WPA3-PSK",
            frequency = "5GHz",
            isVulnerable = false
        ),
        WiFiNetwork(
            ssid = "Guest_Network",
            bssid = "77:88:99:AA:BB:CC",
            signalStrength = 45,
            security = "WPA2-PSK WPS",
            frequency = "2.4GHz",
            isVulnerable = true,
            crackedPassword = "password123"
        ),
        WiFiNetwork(
            ssid = "Neighbor_5G",
            bssid = "DD:EE:FF:00:11:22",
            signalStrength = 30,
            security = "WPA2-PSK",
            frequency = "5GHz",
            isVulnerable = false
        )
    )
}

// Legacy functions (keeping for backend functionality)
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
fun HackerAppPreview() {
    OneshotTheme {
        HackerApp()
    }
}
