package com.android.oneshot

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
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
import com.android.oneshot.ui.theme.*
import kotlinx.coroutines.delay

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

enum class AttackStatus { NONE, SCANNING, ATTACKING, SUCCESS, FAILED }

enum class Screen {
    MAIN,
    SCANNER,
    ADVANCED
}

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
                Brush.verticalGradient(
                    colors = listOf(HackerBlack, TerminalBlack)
                )
            )
            .padding(16.dp)
    ) {
        HackerHeader()
        
        when (currentScreen) {
            Screen.MAIN -> {
                MainScreen(
                    onScanClick = { currentScreen = Screen.SCANNER },
                    onAdvancedClick = { currentScreen = Screen.ADVANCED }
                )
            }
            Screen.SCANNER -> {
                ScannerScreen(
                    networks = networks,
                    isScanning = isScanning,
                    isAttacking = isAttacking,
                    onScanComplete = { scanResults ->
                        networks = scanResults
                        isScanning = false
                    },
                    onAttackClick = { targets ->
                        isAttacking = true
                    },
                    onBackClick = { currentScreen = Screen.MAIN }
                )
            }
            Screen.ADVANCED -> {
                AdvancedScreen(
                    onBackClick = { currentScreen = Screen.MAIN }
                )
            }
        }
    }
}

@Composable
fun HackerHeader() {
    val infiniteTransition = rememberInfiniteTransition(label = "glow")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ), label = "glow"
    )

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = "◉ ONESHOT ◉",
            style = MaterialTheme.typography.headlineLarge,
            color = NeonGreen.copy(alpha = glowAlpha),
            textAlign = TextAlign.Center
        )
        Text(
            text = "WiFi WPS Penetration Suite",
            style = MaterialTheme.typography.bodyMedium,
            color = MatrixGreen,
            textAlign = TextAlign.Center
        )
        Text(
            text = "[ UNAUTHORIZED ACCESS DETECTED ]",
            style = MaterialTheme.typography.bodySmall,
            color = ErrorRed,
            textAlign = TextAlign.Center
        )
    }
    
    Spacer(modifier = Modifier.height(32.dp))
}

@Composable
fun MainScreen(
    onScanClick: () -> Unit,
    onAdvancedClick: () -> Unit
) {
    Column(
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxSize()
    ) {
        HackerButton(
            text = "⚡ SCAN NETWORKS ⚡",
            onClick = onScanClick,
            color = NeonGreen,
            modifier = Modifier.fillMaxWidth()
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        HackerButton(
            text = "⚙ ADVANCED OPTIONS ⚙",
            onClick = onAdvancedClick,
            color = NeonBlue,
            modifier = Modifier.fillMaxWidth()
        )
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
    LaunchedEffect(isScanning) {
        if (isScanning) {
            delay(3000)
            onScanComplete(generateMockNetworks())
        }
    }
    
    Column {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            HackerButton(
                text = "← BACK",
                onClick = onBackClick,
                color = ConsoleGray,
                modifier = Modifier.weight(1f)
            )
            
            Spacer(modifier = Modifier.width(8.dp))
            
            HackerButton(
                text = if (isScanning) "SCANNING..." else "SCAN NOW",
                onClick = { 
                    if (!isScanning) {
                        onScanComplete(generateMockNetworks())
                    }
                },
                color = NeonBlue,
                modifier = Modifier.weight(2f)
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        if (isAttacking) {
            Text(
                text = ">>> ATTACK IN PROGRESS <<<",
                style = MaterialTheme.typography.bodyMedium,
                color = ErrorRed,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            ScanningIndicator()
        }
        
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(networks) { network ->
                NetworkCard(network = network)
            }
        }
    }
}

@Composable
fun AdvancedScreen(onBackClick: () -> Unit) {
    Column {
        Row {
            HackerButton(
                text = "← BACK",
                onClick = onBackClick,
                color = ConsoleGray
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            text = "ADVANCED PENETRATION TOOLS",
            style = MaterialTheme.typography.headlineSmall,
            color = NeonBlue,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(8.dp)),
            colors = CardDefaults.cardColors(containerColor = NeonBlue.copy(alpha = 0.1f))
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "PAYLOAD CONFIGURATION",
                    style = MaterialTheme.typography.titleMedium,
                    color = NeonOrange
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "Custom wordlist: /system/wordlists/rockyou.txt",
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray
                )
                
                Text(
                    text = "Attack mode: WPS PIN + Dictionary",
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray
                )
                
                Text(
                    text = "Threads: 16 | Timeout: 30s",
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray
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
    Button(
        onClick = onClick,
        modifier = modifier
            .clip(RoundedCornerShape(8.dp)),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.Transparent
        )
    ) {
        Text(
            text = text,
            color = color,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun NetworkCard(network: WiFiNetwork) {
    val cardColor = when {
        network.isVulnerable -> VulnerableRed.copy(alpha = 0.2f)
        network.security.contains("WPS") -> UnknownOrange.copy(alpha = 0.2f)
        else -> SafeGreen.copy(alpha = 0.1f)
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp)),
        colors = CardDefaults.cardColors(containerColor = cardColor)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Icon(
                    imageVector = Icons.Filled.Wifi,
                    contentDescription = null,
                    tint = when {
                        network.signalStrength > -50 -> NeonGreen
                        network.signalStrength > -70 -> NeonOrange
                        else -> ErrorRed
                    }
                )
                
                Text(
                    text = "${network.signalStrength} dBm",
                    style = MaterialTheme.typography.bodySmall,
                    color = ConsoleGray
                )
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = network.ssid,
                style = MaterialTheme.typography.titleMedium,
                color = HackerGreen,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = network.bssid,
                style = MaterialTheme.typography.bodySmall,
                color = ConsoleGray
            )
            
            Text(
                text = "Security: ${network.security}",
                style = MaterialTheme.typography.bodySmall,
                color = when {
                    network.isVulnerable -> NeonGreen
                    network.security.contains("WPS") -> NeonOrange
                    else -> ErrorRed
                }
            )
            
            Text(
                text = "Frequency: ${network.frequency}",
                style = MaterialTheme.typography.bodySmall,
                color = ConsoleGray
            )
            
            if (network.isVulnerable) {
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "⚠ VULNERABLE TO WPS ATTACK ⚠",
                    style = MaterialTheme.typography.bodySmall,
                    color = VulnerableRed,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(HackerBlack.copy(alpha = 0.3f))
                        .padding(8.dp)
                )
            }
            
            if (network.crackedPassword != null) {
                Text(
                    text = "Password: ${network.crackedPassword}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = NeonGreen,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun ScanningIndicator() {
    val infiniteTransition = rememberInfiniteTransition(label = "scanning")
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000),
            repeatMode = RepeatMode.Reverse
        ), label = "scanning"
    )
    
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxWidth()
    ) {
        Icon(
            imageVector = Icons.Filled.Wifi,
            contentDescription = null,
            tint = NeonBlue.copy(alpha = alpha),
            modifier = Modifier.size(24.dp)
        )
        
        Spacer(modifier = Modifier.width(8.dp))
        
        Text(
            text = "Scanning for vulnerable networks...",
            style = MaterialTheme.typography.bodyMedium,
            color = NeonBlue.copy(alpha = alpha)
        )
    }
    
    Spacer(modifier = Modifier.height(16.dp))
    
    Text(
        text = "Please wait while we probe WPS vulnerabilities",
        style = MaterialTheme.typography.bodySmall,
        color = ConsoleGray,
        textAlign = TextAlign.Center,
        modifier = Modifier.fillMaxWidth()
    )
}

fun generateMockNetworks(): List<WiFiNetwork> {
    return listOf(
        WiFiNetwork("NETGEAR_5G", "aa:bb:cc:dd:ee:01", -45, "WPA2-PSK WPS", "5.2 GHz", true),
        WiFiNetwork("Linksys_Guest", "aa:bb:cc:dd:ee:02", -52, "WEP WPS", "2.4 GHz", true),
        WiFiNetwork("ASUS_WiFi", "aa:bb:cc:dd:ee:03", -38, "WPA3-SAE", "5.8 GHz", false),
        WiFiNetwork("TP-Link_Home", "aa:bb:cc:dd:ee:04", -67, "WPA2-PSK WPS", "2.4 GHz", true),
        WiFiNetwork("Verizon_FIOS", "aa:bb:cc:dd:ee:05", -41, "WPA2-Enterprise", "5.2 GHz", false),
        WiFiNetwork("Belkin.2E4", "aa:bb:cc:dd:ee:06", -73, "WPS", "2.4 GHz", true),
        WiFiNetwork("xfinitywifi", "aa:bb:cc:dd:ee:07", -69, "Open", "2.4 GHz", false),
        WiFiNetwork("DIRECT-roku", "aa:bb:cc:dd:ee:08", -58, "WPA2-PSK", "2.4 GHz", false),
        WiFiNetwork("ATT_5G_WiFi", "aa:bb:cc:dd:ee:09", -48, "WPA2-PSK WPS", "5.8 GHz", true),
        WiFiNetwork("MySpectrumWiFi", "aa:bb:cc:dd:ee:10", -62, "WPA2-PSK", "2.4 GHz", false)
    )
}

@Preview(showBackground = true)
@Composable
fun HackerAppPreview() { 
    OneshotTheme { 
        HackerApp() 
    } 
}
