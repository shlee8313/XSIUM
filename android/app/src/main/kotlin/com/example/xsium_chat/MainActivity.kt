// package com.example.xsium_chat

// import android.app.ActivityManager
// import android.content.Context
// import android.content.Intent
// import android.net.Uri
// import android.net.ConnectivityManager
// import android.net.NetworkCapabilities
// import android.content.pm.PackageManager
// import android.os.Bundle
// import android.view.WindowManager
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel
// import kotlinx.coroutines.CoroutineScope
// import kotlinx.coroutines.Dispatchers
// import kotlinx.coroutines.delay
// import kotlinx.coroutines.launch
// import kotlinx.coroutines.withContext

// class MainActivity: FlutterActivity() {
//     private val CHANNEL = "com.example.xsium_chat/app_lifecycle"
//     private val XUMM_PACKAGE = "com.xrpllabs.xumm"
//     private var isLoginSuccess = false
//     private var isXummInitialized = false
//     private var xummState = false
//     private var isXummStarting = false
//     private var lastXummCheck = 0L
//     private var startAttempts = 0
//     private val maxStartAttempts = 3
//     private var isXummLaunched = false
    
//     private var isLoginInProgress = false
//     private val activityScope = CoroutineScope(Dispatchers.Main)
//     private val XUMM_LAUNCH_TIMEOUT = 5000L // 5초 타임아웃




//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
        
//         window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
//         if (intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT != 0) {
//             if (intent.component?.className == MainActivity::class.java.name) {
//                 finish()
//                 return
//             }
//         }
        
//         resetXummState()
//     }

//     private fun resetXummState() {
//         isXummLaunched = false
//         xummState = false
//         isLoginInProgress = false
//         isXummInitialized = false
//         isXummStarting = false
//         startAttempts = 0
//         lastXummCheck = 0L
//     }

//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
        
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> 
//             activityScope.launch {
//                 try {
//                     when (call.method) {
//                         // Handle various methods here...
//                         "isNetworkAvailable" -> {
//                             result.success(isNetworkAvailable())
//                         }
//                         "startXumm" -> {
//                             if (startAttempts >= maxStartAttempts) {
//                                 result.error("MAX_ATTEMPTS_REACHED", "Maximum start attempts reached", null)
//                                 return@launch
//                             }

//                             if (!isXummStarting && !isXummRunning()) {
//                                 startAttempts++
//                                 isXummStarting = true
//                                 initializeXumm(moveToFront = false)
//                                 withContext(Dispatchers.IO) {
//                                     delay(1000)
//                                 }
//                                 isXummInitialized = true
//                             }

//                             if (!isXummRunning()) {
//                                 result.error("XUMM_NOT_RUNNING", "Failed to start XUMM", null)
//                                 return@launch
//                             }

//                             result.success(true)
//                         }
//                         "moveToBackground" -> {
//                             moveTaskToBack(true)
//                             result.success(true)
//                         }
//                         "isXummRunning" -> {
//                             val currentTime = System.currentTimeMillis()
//                             if (currentTime - lastXummCheck > 500) {
//                                 xummState = checkXummState()
//                                 lastXummCheck = currentTime
//                             }
//                             result.success(xummState)
//                         }
//                         "getXummState" -> {
//                             result.success(xummState && isXummRunning())
//                         }
//                         "openXummLogin" -> {
//                             try {
//                                 val deepLink = call.argument<String>("deepLink") ?: ""
//                                 if (isXummInstalled()) {
//                                     launchXummWithDeepLink(deepLink)
//                                     result.success(true)
//                                 } else {
//                                     result.error("XUMM_NOT_INSTALLED", "XUMM app is not installed", null)
//                                 }
//                             } catch (e: Exception) {
//                                 isLoginInProgress = false
//                                 result.error("XUMM_LAUNCH_ERROR", e.message, null)
//                             }
//                         }
//                         "bringToFront" -> {
//                             try {
//                                 isLoginInProgress = false  // 로그인 상태 해제
//                                 val intent = Intent(this@MainActivity, MainActivity::class.java).apply {
//                                     flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or 
//                                            Intent.FLAG_ACTIVITY_NEW_TASK or
//                                            Intent.FLAG_ACTIVITY_SINGLE_TOP
//                                     addCategory(Intent.CATEGORY_LAUNCHER)
//                                 }
//                                 startActivity(intent)
//                                 result.success(true)
//                             } catch (e: Exception) {
//                                 result.error("BRING_TO_FRONT_ERROR", e.message, null)
//                             }
//                         }
//                         "onXummClosed" -> {
//                             result.error("XUMM_CLOSED", "XUMM application was closed", null)
//                         }
//                         "loginInterrupted" -> {
//                             isLoginInProgress = false
//                             isXummLaunched = false
//                             resetXummState()
//                             result.success(null)
//                         }
//                         "handleLoginSuccess" -> {
//                         handleLoginSuccess()
//                         result.success(true)
//                     }
//                     "forceStopXummAndHandleClosure" -> {
//                            val showError = call.argument<Boolean>("showError") ?: true
//                            forceStopXummAndHandleClosure(showError)
//                            result.success(true)
//                        }
//                         "resetXummState" -> {
//                             try {
//                                 resetXummState()
//                                 result.success(true)
//                             } catch (e: Exception) {
//                                 result.error("RESET_ERROR", e.message, null)
//                             }
//                         }
//                         else -> {
//                             result.notImplemented()
//                         }
//                     }
//                 } finally {
//                     isXummStarting = false
//                 }
//             }
//         }
//     }

//     // New method to check network availability
//     private fun isNetworkAvailable(): Boolean {
//         val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
//         val capabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
//         return capabilities?.let {
//             it.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) // Checks if there is internet connection
//         } ?: false
//     }

//     private suspend fun launchXummWithDeepLink(deepLink: String) {
//         withContext(Dispatchers.Main) {
//             try {
//                 isLoginInProgress = true
                
//                 // XUMM 실행이 필요한 경우
//                 if (!isXummRunning()) {
//                     val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
//                         addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                         addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
//                     }
//                     startActivity(launchIntent)
                    
//                     // XUMM 실행 대기 (최대 3초)
//                     val startTime = System.currentTimeMillis()
//                     while (!isXummRunning() && 
//                            System.currentTimeMillis() - startTime < 3000) {
//                         delay(100)
//                     }
//                 }
                
//                 // DeepLink 실행
//                 val intent = Intent(Intent.ACTION_VIEW).apply {
//                     data = Uri.parse(deepLink)
//                     addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                     addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
//                 }
//                 startActivity(intent)
//                 moveTaskToBack(true)
                
//             } catch (e: Exception) {
//                 isLoginInProgress = false
//                 forceStopXummAndHandleClosure(true)
//                 throw e
//             }
//         }
//     }

//     private fun initializeXumm(moveToFront: Boolean) {
//         if (!isXummRunning() && isXummInstalled()) {
//             try {
//                 val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
//                     addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                     if (!moveToFront) {
//                         addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
//                         addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
//                     }
//                 }
                
//                 startActivity(launchIntent)
//                 Thread.sleep(1000)
                
//                 if (!moveToFront) {
//                     val bringChatToFront = Intent(this, MainActivity::class.java).apply {
//                         flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
//                     }
//                     startActivity(bringChatToFront)
//                 }
                
//                 isXummLaunched = true
//             } catch (e: Exception) {
//                 e.printStackTrace()
//                 isXummLaunched = false
//             }
//         }
//     }


    
//         private fun checkXummState(): Boolean {
//             try {
//                 val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
//                 val processes = activityManager.runningAppProcesses ?: return false
                
//                 var xummFound = false
                
//                 for (process in processes) {
//                     if (process.processName == XUMM_PACKAGE) {
//                         xummFound = true
//                         val importance = process.importance
//                         val isActive = importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND_SERVICE
                        
//                         if (!isActive && isLoginInProgress && !isLoginSuccess) { 
//                             window.decorView.post {
//                                 forceStopXummAndHandleClosure()
//                             }
//                             return false
//                         }
//                         return isActive
//                     }
//                 }
                
//                 if (!xummFound && isLoginInProgress && !isLoginSuccess) {
//                     window.decorView.post {
//                         forceStopXummAndHandleClosure()
//                     }
//                     return false
//                 }
                
//                 return false
//             } catch (e: Exception) {
//                 e.printStackTrace()
//                 if (isLoginInProgress) {
//                     window.decorView.post {
//                         forceStopXummAndHandleClosure()
//                     }
//                 }
//                 return false
//             }
//         }
    
    
//         // [추가] XUMM 강제 종료 및 처리 메서드
//         private fun forceStopXummAndHandleClosure(showError: Boolean = true) {
//             try {
//                 val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
//                 activityManager.killBackgroundProcesses(XUMM_PACKAGE)
//                 // Runtime.getRuntime().exec("am force-stop $XUMM_PACKAGE")
                
//             } catch (e: Exception) {
//                 e.printStackTrace()
//             } finally {
//                 if (showError) {
//                     flutterEngine?.let { engine ->
//                         MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
//                             .invokeMethod("onLoginInterrupted", null)
//                     }
//                 }
//             }
//         }


//             // 로그인 성공 처리 메서드 추가
//             private fun handleLoginSuccess() {
//                 isLoginSuccess = true
//                 isLoginInProgress = false
//                 isXummLaunched = false
//                 forceStopXummAndHandleClosure(showError = false)
//                 bringChatToFront()
//             }
        

//         private fun handleXummClosed() {
//             isLoginInProgress = false
//             isXummLaunched = false
//             isLoginSuccess = false
//             resetXummState()
            
//             // [수정] onError 메시지 제거
//             flutterEngine?.let { engine ->
//                 MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
//                     .invokeMethod("onXummClosed", null)
//             }
//         }


            
//     // 채팅앱을 foreground로 가져오는 메서드
//     private fun bringChatToFront() {
//         try {
//             val intent = Intent(this, MainActivity::class.java).apply {
//                 flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or 
//                         Intent.FLAG_ACTIVITY_NEW_TASK or
//                         Intent.FLAG_ACTIVITY_SINGLE_TOP or
//                         Intent.FLAG_ACTIVITY_CLEAR_TOP
//                 addCategory(Intent.CATEGORY_LAUNCHER)
//             }
//             startActivity(intent)
//         } catch (e: Exception) {
//             e.printStackTrace()
//         }
//     }


//     private fun isXummRunning(): Boolean {
//     try {
//         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
//         val processes = activityManager.runningAppProcesses ?: return false
        
//         for (process in processes) {
//             if (process.processName == XUMM_PACKAGE) {
//                 val importance = process.importance
//                 return importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND_SERVICE
//             }
//         }
//         return false
//     } catch (e: Exception) {
//         e.printStackTrace()
//         return false
//     }
// }

//     private fun isXummInstalled(): Boolean {
//         return try {
//             packageManager.getPackageInfo(XUMM_PACKAGE, 0)
//             true
//         } catch (e: PackageManager.NameNotFoundException) {
//             false
//         }
//     }

//     private fun handleLoginInterruption() {
//         // Send message to Flutter to indicate login interruption
//         flutterEngine?.let { engine ->
//             MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
//                 .invokeMethod("onLoginInterrupted", "로그인이 중단되었습니다.")
//         }
//         isLoginInProgress = false
//     }
    
//     override fun onNewIntent(intent: Intent) {
//         super.onNewIntent(intent)
//         setIntent(intent)
        
//         if (isLoginInProgress && isXummLaunched && !isLoginSuccess) {
//             // 로그인 중단 다이얼로그를 표시하도록 Flutter에 알림
//             flutterEngine?.let { engine ->
//                 MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
//                     .invokeMethod("showLoginInterruptDialog", null)
//             }
//         }
//     }
    


    
//     override fun onResume() {
//         super.onResume()
//         window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        
//         if (isLoginInProgress && !isLoginSuccess) {
//             if (!isXummRunning()) {
//                 forceStopXummAndHandleClosure(true)
//             }
//         }
//     }


    
//     override fun onBackPressed() {
//         if (isLoginInProgress && isXummLaunched) {
//             // 로그인 중에는 다이얼로그 표시
//             flutterEngine?.let { engine ->
//                 MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
//                     .invokeMethod("showLoginInterruptDialog", null)
//             }
//         } else {
//             super.onBackPressed()
//         }
//     }
    
//     // onWindowFocusChanged 수정
//     // override fun onWindowFocusChanged(hasFocus: Boolean) {
//     //     super.onWindowFocusChanged(hasFocus)
//     //     if (hasFocus && (isXummLaunched || isLoginInProgress)) {
//     //         // [수정] 강제 종료 로직 제거
//     //         flutterEngine?.let { engine ->
//     //             MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
//     //                 .invokeMethod("showLoginInterruptDialog", null)
//     //         }
//     //     }
//     // }

    

//     // override fun onNewIntent(intent: Intent) {
//     //     super.onNewIntent(intent)
//     //     setIntent(intent)
        
//     //     if (isLoginInProgress && isXummLaunched) {
//     //         // 로그인 중에 채팅앱으로 돌아오면 XUMM 강제 종료
//     //         forceStopXummAndHandleClosure()
//     //     }
//     // }

//     override fun onDestroy() {
//         resetXummState()
//         super.onDestroy()
//     }
// }





package com.example.xsium_chat

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.graphics.PixelFormat
import android.view.View
import android.os.Handler
import android.os.Looper
import android.util.Log as developer




class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.xsium_chat/app_lifecycle"
    private val XUMM_PACKAGE = "com.xrpllabs.xumm"
    private val activityScope = CoroutineScope(Dispatchers.Main)
    private val XUMM_LAUNCH_TIMEOUT = 5000L

    // XUMM 상태 관련
    private enum class XummState {
        IDLE,
        INITIALIZING,
        RUNNING,
        SUCCESS,
        FAILED,
        CANCELLED
    }
    
    private var xummState = XummState.IDLE
    private var isLoginInProgress = false
    private var lastXummCheck = 0L
    private var startAttempts = 0
    private val maxStartAttempts = 3

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 기존 코드
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
        
        // Surface 관련 설정 추가
        window.setFormat(PixelFormat.TRANSLUCENT)
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                                            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        
        // Surface 하드웨어 가속 최적화 설정 추가
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
        
        if (intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT != 0) {
            if (intent.component?.className == MainActivity::class.java.name) {
                finish()
                return
            }
        }
        
        resetState()
    }

    private fun resetState() {
        developer.d("XUMM", "Resetting state")
        xummState = XummState.IDLE
        isLoginInProgress = false
        lastXummCheck = 0L
        startAttempts = 0
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> 
            activityScope.launch {
                try {
                    when (call.method) {
                        "isNetworkAvailable" -> {
                            result.success(isNetworkAvailable())
                        }
                        "openXummLogin" -> {
                            try {
                                val deepLink = call.argument<String>("deepLink") ?: ""
                                developer.d("XUMM", "Attempting to open XUMM with deep link: $deepLink")
                                
                                if (isXummInstalled()) {
                                    // 먼저 XUMM 앱을 실행
                                    val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                    }
                                    
                                    startActivity(launchIntent)
                                    
                                    // XUMM 앱이 실행될 때까지 대기
                                    var waitTime = 0
                                    while (!isXummRunning() && waitTime < 5000) {
                                        Thread.sleep(100)
                                        waitTime += 100
                                    }
                                    
                                    // Deep Link 처리
                                    if (isXummRunning()) {
                                        val intent = Intent(Intent.ACTION_VIEW).apply {
                                            data = Uri.parse(deepLink)
                                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                                            setPackage(XUMM_PACKAGE)
                                        }
                                        startActivity(intent)
                                        result.success(true)
                                    } else {
                                        result.error("XUMM_LAUNCH_FAILED", "Failed to launch XUMM app", null)
                                    }
                                } else {
                                    result.error("XUMM_NOT_INSTALLED", "XUMM app is not installed", null)
                                }
                            } catch (e: Exception) {
                                developer.e("XUMM", "Error launching XUMM: ${e.message}")
                                result.error("XUMM_LAUNCH_ERROR", e.message, null)
                            }
                        }
                        "bringToFront" -> {
                            try {
                                isLoginInProgress = false  // 로그인 상태 해제
                                val intent = Intent(this@MainActivity, MainActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or 
                                        Intent.FLAG_ACTIVITY_NEW_TASK or
                                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                                    addCategory(Intent.CATEGORY_LAUNCHER)
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                developer.e("XUMM", "Error bringing to front: ${e.message}")
                                result.error("BRING_TO_FRONT_ERROR", e.message, null)
                            }
                        }
                        "handleLoginSuccess" -> {
                            handleLoginSuccess()
                            result.success(true)
                        }
                        "resetState" -> {
                            resetState()
                            result.success(true)
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                } catch (e: Exception) {
                    developer.e("XUMM", "Error in method channel: ${e.message}")
                    result.error("CHANNEL_ERROR", e.message, null)
                }
            }
        }
    }

    private suspend fun launchXummWithDeepLink(deepLink: String) {
        // 상태 체크
        if (xummState == XummState.SUCCESS || isLoginInProgress) {
            developer.d("XUMM", "Login already in progress or completed")
            return
        }
    
        withContext(Dispatchers.Main) {
            try {
                isLoginInProgress = true
                
                // XUMM 실행이 필요한 경우
                if (!isXummRunning()) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }
                    startActivity(launchIntent)
                    
                    // killed 상태에서 XUMM 실행 대기 시간 증가
                    val startTime = System.currentTimeMillis()
                    var isLaunched = false
                    while (!isLaunched && System.currentTimeMillis() - startTime < 15000) {  // 15초로 증가
                        if (isXummRunning()) {
                            isLaunched = true
                            delay(1000)  // XUMM 앱 초기화를 위한 추가 대기
                        } else {
                            delay(100)
                        }
                    }
                    
                    if (!isLaunched) {
                        throw Exception("Failed to launch XUMM app")
                    }
                }
    
                // Deep Link 처리
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    data = Uri.parse(deepLink)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                    setPackage(XUMM_PACKAGE)  // 명시적으로 XUMM 패키지 지정
                }
                startActivity(intent)
                moveTaskToBack(true)
                
                xummState = XummState.RUNNING
            } catch (e: Exception) {
                handleLoginError(e)
                throw e
            }
        }
    }

    // private fun isXummRunning(): Boolean {
    //     try {
    //         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    //         val processes = activityManager.runningAppProcesses ?: return false
            
    //         for (process in processes) {
    //             if (process.processName == XUMM_PACKAGE) {
    //                 val importance = process.importance
    //                 return importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND_SERVICE &&
    //                        importance >= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
    //             }
    //         }
    //         return false
    //     } catch (e: Exception) {
    //         developer.e("XUMM", "Error checking XUMM state: ${e.message}")
    //         return false
    //     }
    // }

    private fun isXummRunning(): Boolean {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            // 디버깅 모드를 고려한 더 유연한 체크
            return activityManager.runningAppProcesses?.any { 
                it.processName == XUMM_PACKAGE && 
                it.importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_SERVICE 
            } ?: false
        } catch (e: Exception) {
            developer.e("XUMM", "Error checking XUMM state: ${e.message}")
            return false
        }
    }



    // private fun isXummRunning(): Boolean {
    //     try {
    //         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    //         val tasks = activityManager.getRunningTasks(Int.MAX_VALUE)
    //         for (task in tasks) {
    //             if (task.topActivity?.packageName == XUMM_PACKAGE) {
    //                 return true
    //             }
    //         }
    //         return false
    //     } catch (e: Exception) {
    //         developer.e("XUMM", "Error checking if XUMM is running: ${e.message}")
    //         return false
    //     }
    // }

    private fun notifyLoginSuccess() {
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onLoginSuccess", null)
        }
        
        Handler(Looper.getMainLooper()).postDelayed({
            resetState()
            moveToMainScreen()
        }, 1500)
    }


    // private fun handleLoginSuccess() {
    //     activityScope.launch(Dispatchers.Default) {
    //         if (xummState == XummState.SUCCESS) {
    //             developer.d("XUMM", "Login success already processed")
    //             return@launch
    //         }
            
    //         try {
    //             // 백그라운드에서 처리
    //             forceCloseXumm()
                
    //             // UI 스레드로 전환
    //             withContext(Dispatchers.Main) {
    //                 xummState = XummState.SUCCESS
    //                 isLoginInProgress = false
    //                 notifyLoginSuccess()
    //             }
    //         } catch (e: Exception) {
    //             handleLoginError(e)
    //         }
    //     }
    // }

    private fun handleLoginSuccess() {
        activityScope.launch(Dispatchers.Main) {
            if (xummState == XummState.SUCCESS) {
                return@launch
            }
            
            try {
                xummState = XummState.SUCCESS
                isLoginInProgress = false
                
                // XUMM 종료와 화면 전환을 동시에 처리
                launch(Dispatchers.Default) {
                    forceCloseXumm()
                }
                
                // 즉시 로그인 성공 처리
                flutterEngine?.let { engine ->
                    MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onLoginSuccess", null)
                }
                
                // 즉시 메인 화면으로 이동
                moveToMainScreen()
            } catch (e: Exception) {
                handleLoginError(e)
            }
        }
    }

    private fun handleLoginError(error: Exception) {
        developer.e("XUMM", "Login error: ${error.message}")
        
        xummState = XummState.FAILED
        isLoginInProgress = false
        
        forceCloseXumm()
        resetState()
        
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("showErrorDialog", "login_processing_error")
        }
    }


    private fun forceCloseXumm() {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.killBackgroundProcesses(XUMM_PACKAGE)
            Runtime.getRuntime().exec("am force-stop $XUMM_PACKAGE")
        } catch (e: Exception) {
            developer.e("XUMM", "Error force closing XUMM: ${e.message}")
        }
    }

    // private fun forceCloseXumm() {
    //     try {
    //         developer.d("XUMM", "Force closing XUMM")

    //         // Surface 재생성 최적화를 위한 처리 추가
    //         window.decorView.let { view ->
    //             view.visibility = View.INVISIBLE
    //             Handler(Looper.getMainLooper()).postDelayed({
    //                 try {
    //                     // XUMM 앱 종료 처리
    //                     val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    //                     activityManager.killBackgroundProcesses(XUMM_PACKAGE)
                        
    //                     val closeIntent = Intent(XUMM_PACKAGE + ".CLOSE")
    //                     closeIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    //                     sendBroadcast(closeIntent)
                        
    //                     Runtime.getRuntime().exec("am force-stop $XUMM_PACKAGE")

    //                     // Surface 재생성 전 추가 지연
    //                     Handler(Looper.getMainLooper()).postDelayed({
    //                         // Surface 재생성 최적화
    //                         window.setFlags(
    //                             WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
    //                             WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
    //                         )
                            
    //                         // Surface 가시성 복원
    //                         view.visibility = View.VISIBLE
    //                     }, 100) // Surface 재생성 지연시간

    //                 } catch (e: Exception) {
    //                     developer.e("XUMM", "Error during XUMM force close: ${e.message}")
    //                     // 에러 발생 시에도 Surface 복원
    //                     view.visibility = View.VISIBLE
    //                 }
    //             }, 100) // XUMM 종료 처리 지연시간
    //         }
            
    //     } catch (e: Exception) {
    //         developer.e("XUMM", "Error force closing XUMM: ${e.message}")
    //     }
    // }

    private fun moveToMainScreen() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            startActivity(intent)
        } catch (e: Exception) {
            developer.e("XUMM", "Error moving to main screen: ${e.message}")
        }
    }

    private fun isXummInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo(XUMM_PACKAGE, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun isNetworkAvailable(): Boolean {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val capabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
        return capabilities?.let {
            it.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        } ?: false
    }

    // override fun onNewIntent(intent: Intent) {
    //     super.onNewIntent(intent)
    //     setIntent(intent)
        
    //     if (isLoginInProgress && xummState == XummState.RUNNING) {
    //         handleLoginInterrupt()
    //     }
    // }

    private fun handleLoginInterrupt() {
        developer.d("XUMM", "Login interrupted")
        
        forceCloseXumm()
        resetState()
        
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("showLoginInterruptError", null)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)  // Optional, only if needed for later processing
        
        if (isLoginInProgress && xummState == XummState.RUNNING) {
            handleLoginInterrupt()  // Interrupt login if needed when a new intent is received
        }
    }
    
    override fun onResume() {
        super.onResume()
        window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        
        // Surface 상태 확인 및 복원
        if (window.decorView.visibility != View.VISIBLE) {
            window.decorView.visibility = View.VISIBLE
        }
        
        if (isLoginInProgress && xummState == XummState.RUNNING) {
            if (!isXummRunning()) {
                Handler(Looper.getMainLooper()).postDelayed({
                    if (!isXummRunning()) {
                        handleLoginInterrupt()
                    }
                }, 500)
            }
        }
    }

    
    override fun onBackPressed() {
        if (isLoginInProgress && xummState == XummState.RUNNING) {
            handleLoginInterrupt()  // Allow interrupting the login process with back press
        } else {
            super.onBackPressed()  // Proceed with the normal back press action
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (isLoginInProgress && xummState == XummState.RUNNING) {
            // Ensure to properly clean up or reset if needed
            resetState()
        }
    }
}