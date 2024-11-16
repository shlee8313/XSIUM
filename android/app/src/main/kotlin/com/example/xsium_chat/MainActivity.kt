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

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.xsium_chat/app_lifecycle"
    private val XUMM_PACKAGE = "com.xrpllabs.xumm"
    private var isLoginSuccess = false
    private var isXummInitialized = false
    private var xummState = false
    private var isXummStarting = false
    private var lastXummCheck = 0L
    private var startAttempts = 0
    private val maxStartAttempts = 3
    private var isXummLaunched = false
    private var isLoginInProgress = false
    private val activityScope = CoroutineScope(Dispatchers.Main)
    private val XUMM_LAUNCH_TIMEOUT = 5000L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        if (intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT != 0) {
            if (intent.component?.className == MainActivity::class.java.name) {
                finish()
                return
            }
        }
        
        resetXummState()
    }

    private fun resetXummState() {
        isXummLaunched = false
        xummState = false
        isLoginInProgress = false
        isXummInitialized = false
        isXummStarting = false
        startAttempts = 0
        lastXummCheck = 0L
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
                        "startXumm" -> {
                            if (startAttempts >= maxStartAttempts) {
                                result.error("MAX_ATTEMPTS_REACHED", "Maximum start attempts reached", null)
                                return@launch
                            }

                            if (!isXummStarting && !isXummRunning()) {
                                startAttempts++
                                isXummStarting = true
                                initializeXumm(moveToFront = false)
                                withContext(Dispatchers.IO) {
                                    delay(1000)
                                }
                                isXummInitialized = true
                            }

                            if (!isXummRunning()) {
                                result.error("XUMM_NOT_RUNNING", "Failed to start XUMM", null)
                                return@launch
                            }

                            result.success(true)
                        }
                        "moveToBackground" -> {
                            moveTaskToBack(true)
                            result.success(true)
                        }
                        "isXummRunning" -> {
                            val currentTime = System.currentTimeMillis()
                            if (currentTime - lastXummCheck > 500) {
                                xummState = checkXummState()
                                lastXummCheck = currentTime
                            }
                            result.success(xummState)
                        }
                        "getXummState" -> {
                            result.success(xummState && isXummRunning())
                        }
                        "openXummLogin" -> {
                            try {
                                val deepLink = call.argument<String>("deepLink") ?: ""
                                if (isXummInstalled()) {
                                    launchXummWithDeepLink(deepLink)
                                    result.success(true)
                                } else {
                                    result.error("XUMM_NOT_INSTALLED", "XUMM app is not installed", null)
                                }
                            } catch (e: Exception) {
                                isLoginInProgress = false
                                handleXummTerminated()
                                result.error("XUMM_LAUNCH_ERROR", e.message, null)
                            }
                        }
                        "bringToFront" -> {
                            try {
                                isLoginInProgress = false
                                bringChatToFront()
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("BRING_TO_FRONT_ERROR", e.message, null)
                            }
                        }
                        "handleLoginSuccess" -> {
                            handleLoginSuccess()
                            result.success(true)
                        }
                        "resetXummState" -> {
                            try {
                                resetXummState()
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("RESET_ERROR", e.message, null)
                            }
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                } finally {
                    isXummStarting = false
                }
            }
        }
    }

    private fun isNetworkAvailable(): Boolean {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val capabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
        return capabilities?.let {
            it.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        } ?: false
    }

    private suspend fun launchXummWithDeepLink(deepLink: String) {
        withContext(Dispatchers.Main) {
            try {
                isLoginInProgress = true
                
                if (!isXummRunning()) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                    startActivity(launchIntent)
                    
                    val startTime = System.currentTimeMillis()
                    while (!isXummRunning() && 
                           System.currentTimeMillis() - startTime < 3000) {
                        delay(100)
                    }
                }
                
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    data = Uri.parse(deepLink)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                startActivity(intent)
                // moveTaskToBack(true)
                
            } catch (e: Exception) {
                isLoginInProgress = false
                handleXummTerminated()
                throw e
            }
        }
    }


    
    

    private fun initializeXumm(moveToFront: Boolean) {
        if (!isXummRunning() && isXummInstalled()) {
            try {
                val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    if (!moveToFront) {
                        addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                        addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                    }
                }
                
                startActivity(launchIntent)
                Thread.sleep(1000)
                
                if (!moveToFront) {
                    val bringChatToFront = Intent(this, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                    }
                    startActivity(bringChatToFront)
                }
                
                isXummLaunched = true
            } catch (e: Exception) {
                e.printStackTrace()
                isXummLaunched = false
            }
        }
    }



    private fun isXummRunning(): Boolean {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val processes = activityManager.runningAppProcesses ?: return false
            
            for (process in processes) {
                if (process.processName == XUMM_PACKAGE) {
                    val importance = process.importance
                    return importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                }
            }
            return false
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }



    private fun checkXummState(): Boolean {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val processes = activityManager.runningAppProcesses ?: return false
            
            var xummFound = false
            
            for (process in processes) {
                if (process.processName == XUMM_PACKAGE) {
                    xummFound = true
                    val importance = process.importance
                    // val isActive = importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                    val isActive = importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND_SERVICE
                    
                    if (!isActive && isLoginInProgress && !isLoginSuccess) { 
                        window.decorView.post {
                            handleXummTerminated()
                        }
                        return false
                    }
                    return isActive
                }
            }
            
            if (!xummFound && isLoginInProgress && !isLoginSuccess) {
                window.decorView.post {
                    handleXummTerminated()
                }
                return false
            }
            
            return false
        } catch (e: Exception) {
            e.printStackTrace()
            if (isLoginInProgress) {
                window.decorView.post {
                    handleXummTerminated()
                }
            }
            return false
        }
    }


    // private fun checkXummState(): Boolean {
    //     try {
    //         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            
    //         // 먼저 실행 중인 태스크 확인
    //         val runningTasks = activityManager.getRunningTasks(1)
    //         val isActiveTask = runningTasks.isNotEmpty() && 
    //                           runningTasks[0].topActivity?.packageName == XUMM_PACKAGE
            
    //         if (isActiveTask) {
    //             return true
    //         }
            
    //         // 프로세스 상태 확인
    //         val processes = activityManager.runningAppProcesses ?: return false
    //         for (process in processes) {
    //             if (process.processName == XUMM_PACKAGE) {
    //                 return true
    //             }
    //         }
            
    //         if (isLoginInProgress && !isLoginSuccess) {
    //             window.decorView.post {
    //                 handleXummTerminated()
    //             }
    //         }
            
    //         return false
    //     } catch (e: Exception) {
    //         e.printStackTrace()
    //         if (isLoginInProgress) {
    //             window.decorView.post {
    //                 handleXummTerminated()
    //             }
    //         }
    //         return false
    //     }
    // }


    // 사용자가 xumm을 강제종료한 경우
    private fun handleXummTerminated() {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.killBackgroundProcesses(XUMM_PACKAGE)
            // Runtime.getRuntime().exec("am force-stop $XUMM_PACKAGE")
            
            flutterEngine?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("showXummTerminatedDialog", null)
            }
            bringChatToFront()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    //사용자가 Xsium으로 돌아온경우
    private fun handleLoginInterrupt() {
    //     isXummLaunched = false  // XUMM 상태 리셋
    // xummState = false       // XUMM 상태 리셋
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("showLoginInterruptError", null)
        }
    }



      // 추가된 코드: //xumm에서 에러메시지 보내온경우, expired, cancelled등
      private fun handleXummError(error: String) {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.killBackgroundProcesses(XUMM_PACKAGE)
            // Runtime.getRuntime().exec("am force-stop $XUMM_PACKAGE")
            
            flutterEngine?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("showErrorDialog", error)
            }
            bringChatToFront()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private fun handleLoginSuccess() {
        isLoginSuccess = true
        isLoginInProgress = false
        isXummLaunched = false
        resetXummState()
        bringChatToFront()
    }

    private fun bringChatToFront() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or 
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    
    // private fun isXummRunning(): Boolean {
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

    




    private fun isXummInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo(XUMM_PACKAGE, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        
        // 기존 코드
        
        if (isLoginInProgress && isXummLaunched && !isLoginSuccess) {
            handleLoginInterrupt()
        }
        

        // 수정된 코드
        // if (isLoginInProgress && !isLoginSuccess) {
        //     if (isXummRunning() && isXummLaunched) {
        //         handleLoginInterrupt()
        //     }
        // }
    }


    override fun onResume() {
        super.onResume()
        window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        
        // 기존 코드
        /*
        if (isLoginInProgress && isXummLaunched && !isLoginSuccess) {
            if (!isXummRunning()) {
                isXummLaunched = false
                handleXummTerminated()
            } else {
                handleLoginContinue()
            }
        }
        */

        // 수정된 코드
        if (isLoginInProgress && !isLoginSuccess) {
            if (!isXummRunning()) {
                isXummLaunched = false
                handleXummTerminated()
            } else if (isXummLaunched) {
                // XUMM이 실행 중이지만 사용자가 채팅앱으로 돌아온 경우
                handleLoginInterrupt()
                // XUMM을 다시 포그라운드로 가져오기
                // try {
                //     val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                //         addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                //         addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                //         addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                //     }
                //     startActivity(launchIntent)
                // } catch (e: Exception) {
                //     e.printStackTrace()
                // }
            }
        }
    }


    override fun onBackPressed() {
        // 기존 코드
        /*
        if (isLoginInProgress && isXummLaunched) {
            handleLoginContinue()
        } else {
            super.onBackPressed()
        }
        */

        // 수정된 코드
        if (isLoginInProgress && !isLoginSuccess) {
            if (isXummRunning() && isXummLaunched) {
                handleLoginInterrupt()
            }
        } else {
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        resetXummState()
        super.onDestroy()
    }
}