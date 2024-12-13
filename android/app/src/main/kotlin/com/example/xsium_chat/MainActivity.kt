
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

    // 
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    
        // UI 및 Surface 설정을 하나의 flags로 통합
        window.apply {
            // 필수 플래그들을 비트 연산으로 한 번에 설정
            addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
            )
            
            // 투명도 설정
            setFormat(PixelFormat.TRANSLUCENT)
            
            // System UI 설정
            decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                                         View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        }
        
        // 중복 실행 방지 로직
        if (isTaskRoot.not() && intent.hasCategory(Intent.CATEGORY_LAUNCHER)) {
            finish()
            return
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
                        // "openXummLogin" -> {
                        //     try {
                        //         val deepLink = call.argument<String>("deepLink") ?: ""
                        //         developer.d("XUMM", "Attempting to open XUMM with deep link: $deepLink")
                        
                        //         if (isXummInstalled()) {
                        //             isLoginInProgress = true
                        //             xummState = XummState.INITIALIZING
                        
                        //             // XUMM 앱 실행
                        //             val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                        //                 addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        //                 addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        //                 addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        //             }
                        //             startActivity(launchIntent)
                        
                        //             // XUMM 실행 상태 체크
                        //             withContext(Dispatchers.Default) {
                        //                 var waitTime = 0
                        //                 while (!isXummRunning() && waitTime < 5000) {  // 5초로 대기 시간 설정
                        //                     delay(100)
                        //                     waitTime += 100
                        //                 }
                        
                        //                 if (isXummRunning()) {
                        //                     delay(500)  // 대기 후 XUMM 앱이 실행 중이라면
                        
                        //                     // 이미 로그인 진행 중인지 체크
                        //                     if (!isLoginInProgress) {
                        //                         withContext(Dispatchers.Main) {
                        //                             val intent = Intent(Intent.ACTION_VIEW).apply {
                        //                                 data = Uri.parse(deepLink)
                        //                                 addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        //                                 addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        //                                 addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        //                             }
                        //                             startActivity(intent)
                        //                             xummState = XummState.RUNNING
                        //                             result.success(true)
                        //                         }
                        //                     } else {
                        //                         // 이미 로그인 중이면 중복 요청을 막음
                        //                         withContext(Dispatchers.Main) {
                        //                             isLoginInProgress = false
                        //                             xummState = XummState.FAILED
                        //                             result.error("XUMM_ALREADY_LOGGING_IN", "Login already in progress", null)
                        //                         }
                        //                     }
                        //                 } else {
                        //                     withContext(Dispatchers.Main) {
                        //                         isLoginInProgress = false
                        //                         xummState = XummState.FAILED
                        //                         result.error("XUMM_LAUNCH_FAILED", "Failed to launch XUMM app", null)
                        //                     }
                        //                 }
                        //             }
                        //         } else {
                        //             result.error("XUMM_NOT_INSTALLED", "XUMM app is not installed", null)
                        //         }
                        //     } catch (e: Exception) {
                        //         isLoginInProgress = false
                        //         xummState = XummState.FAILED
                        //         developer.e("XUMM", "Error launching XUMM: ${e.message}")
                        //         result.error("XUMM_LAUNCH_ERROR", e.message, null)
                        //     }
                        // }  
                        "openXummLogin" -> {
                            activityScope.launch {
                                try {
                                    val deepLink = call.argument<String>("deepLink") ?: ""
                                    developer.d("XUMM", "Attempting to open XUMM with deep link: $deepLink")

                                    if (isXummInstalled()) {
                                        isLoginInProgress = true
                                        xummState = XummState.INITIALIZING

                                        // 먼저 딥링크로 시도
                                        try {
                                            val deepLinkIntent = Intent(Intent.ACTION_VIEW).apply {
                                                data = Uri.parse(deepLink)
                                                setPackage(XUMM_PACKAGE)
                                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                                                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                                        Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                            }
                                            startActivity(deepLinkIntent)
                                            xummState = XummState.RUNNING
                                            result.success(true)
                                        } catch (e: Exception) {
                                            // 딥링크 실패시 XUMM 앱 실행 후 재시도
                                            val launchIntent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)?.apply {
                                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                                                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                                        Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                            }
                                            startActivity(launchIntent)

                                            // XUMM 실행 대기
                                            var waitTime = 0
                                            while (!isXummRunning() && waitTime < 3000) {
                                                delay(100)
                                                waitTime += 100
                                            }

                                            delay(500)  // 초기화 대기

                                            // 딥링크 재시도
                                            val retryIntent = Intent(Intent.ACTION_VIEW).apply {
                                                data = Uri.parse(deepLink)
                                                setPackage(XUMM_PACKAGE)
                                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                                                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                                        Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                            }
                                            startActivity(retryIntent)
                                            xummState = XummState.RUNNING
                                            result.success(true)
                                        }
                                    } else {
                                        result.error("XUMM_NOT_INSTALLED", "XUMM app is not installed", null)
                                    }
                                } catch (e: Exception) {
                                    isLoginInProgress = false
                                    xummState = XummState.FAILED
                                    developer.e("XUMM", "Error launching XUMM: ${e.message}")
                                    result.error("XUMM_LAUNCH_ERROR", e.message, null)
                                }
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
                        "handleXummError" -> {
                            try {
                                val error = call.arguments as String
                                handleXummError(error)
                                result.success(true)
                            } catch (e: Exception) {
                                developer.e("XUMM", "Error handling XUMM error: ${e.message}")
                                result.error("HANDLE_ERROR_FAILED", e.message, null)
                            }
                        }
                        "resetXummState" -> {
                            try {
                                resetState()
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("RESET_ERROR", e.message, null)
                            }
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
                            delay(500)  // XUMM 앱 초기화를 위한 추가 대기
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


    private fun isXummRunning(): Boolean {
        return try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val processes = activityManager.runningAppProcesses ?: return false
            
            processes.any { process -> 
                process.processName == XUMM_PACKAGE && 
                process.importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND_SERVICE
            }
        } catch (e: Exception) {
            developer.e("XUMM", "Error checking XUMM state: ${e.message}")
            false
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

    // private fun isXummRunning(): Boolean {
    //     try {
    //         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    //         // 디버깅 모드를 고려한 더 유연한 체크
    //         return activityManager.runningAppProcesses?.any { 
    //             it.processName == XUMM_PACKAGE && 
    //             it.importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_SERVICE 
    //         } ?: false
    //     } catch (e: Exception) {
    //         developer.e("XUMM", "Error checking XUMM state: ${e.message}")
    //         return false
    //     }
    // }


    // private fun isXummRunning(): Boolean {
    //     return try {
    //         // 패키지의 기본 활동이 실행 중인지 확인
    //         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    //         val tasks = activityManager.getRunningTasks(1)
    //         if (tasks.isNotEmpty()) {
    //             val topActivity = tasks[0].topActivity
    //             topActivity?.packageName == XUMM_PACKAGE
    //         } else {
    //             false
    //         }
    //     } catch (e: Exception) {
    //         developer.e("XUMM", "Error checking XUMM state: ${e.message}")
    //         false
    //     }
    // }
    


    // private fun isXummRunning(): Boolean {
    //     return try {
    //         val packageManager = context.packageManager
    //         val intent = packageManager.getLaunchIntentForPackage(XUMM_PACKAGE)
    //         intent != null && isActivityRunning(XUMM_PACKAGE)
    //     } catch (e: Exception) {
    //         false
    //     }
    // }
    // private fun isXummRunning(): Boolean {
    //     return try {
    //         val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    //         // 더 간단한 로직으로 변경
    //         activityManager.runningAppProcesses?.any { it.processName == XUMM_PACKAGE } == true
    //     } catch (e: Exception) {
    //         developer.e("XUMM", "Error checking XUMM state: ${e.message}")
    //         false
    //     }
    // }
    
    private fun isActivityRunning(packageName: String): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return activityManager.appTasks.any { 
            it.taskInfo.baseActivity?.packageName == packageName 
        }
    }

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

    // private fun handleLoginInterrupt() {
    //     developer.d("XUMM", "Login interrupted")
        
    //     forceCloseXumm()
    //     resetState()
        
    //     flutterEngine?.let { engine ->
    //         MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
    //             .invokeMethod("showLoginInterruptError", null)
    //     }
    // }

    private fun handleXummError(error: String) {
        try {
            // XSIUM으로 즉시 이동
            moveToMainScreen()
            forceCloseXumm()
            resetState()
            
            flutterEngine?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("showXummError", error)
            }
            
            
        } catch (e: Exception) {
            developer.e("XUMM", "Error handling XUMM error: ${e.message}")
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