package com.example.holos

import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.samsung.android.sdk.health.data.HealthDataService
import com.samsung.android.sdk.health.data.HealthDataStore
import com.samsung.android.sdk.health.data.permission.Permission
import com.samsung.android.sdk.health.data.permission.AccessType
import com.samsung.android.sdk.health.data.request.DataType
import com.samsung.android.sdk.health.data.request.DataTypes
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.holos/samsung_health"
    private val TAG = "SamsungHealthSDK"

    private var methodChannel: MethodChannel? = null
    private var healthDataStore: HealthDataStore? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    result.success(checkSamsungHealthInstalled())
                }
                "hasPermission" -> {
                    lifecycleScope.launch {
                        result.success(checkPermissions())
                    }
                }
                "requestPermission" -> {
                    lifecycleScope.launch {
                        result.success(requestPermissions())
                    }
                }
                "getTodayData" -> {
                    lifecycleScope.launch {
                        result.success(getTodayData())
                    }
                }
                "disconnect" -> {
                    disconnect()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Initialize Samsung Health Data SDK
        initializeSamsungHealthSDK()
    }

    private fun initializeSamsungHealthSDK() {
        try {
            healthDataStore = HealthDataService.getStore(applicationContext)
            Log.d(TAG, "Samsung Health Data SDK initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize: ${e.message}", e)
        }
    }

    private fun checkSamsungHealthInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo("com.sec.android.app.shealth", 0)
            true
        } catch (e: Exception) {
            false
        }
    }

    private suspend fun checkPermissions(): Boolean {
        if (healthDataStore == null) return false

        return try {
            val stepsPermission = Permission.of(DataTypes.STEPS, AccessType.READ)
            val grantedPermissions: Set<Permission> = healthDataStore!!.getGrantedPermissions(setOf(stepsPermission))
            grantedPermissions.contains(stepsPermission)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking permissions: ${e.message}", e)
            false
        }
    }

    private suspend fun requestPermissions(): Boolean {
        if (healthDataStore == null) return false

        return try {
            val stepsPermission = Permission.of(DataTypes.STEPS, AccessType.READ)
            val heartRatePermission = Permission.of(DataTypes.HEART_RATE, AccessType.READ)
            val sleepPermission = Permission.of(DataTypes.SLEEP, AccessType.READ)
            val permissions = setOf(stepsPermission, heartRatePermission, sleepPermission)

            val grantedPermissions: Set<Permission> = healthDataStore!!.requestPermissions(permissions, this@MainActivity)
            grantedPermissions.containsAll(permissions)
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting permissions: ${e.message}", e)
            false
        }
    }

    private suspend fun getTodayData(): Map<String, Any?> {
        if (healthDataStore == null) {
            return mapOf("error" to "Health Data Store not initialized")
        }

        // TODO: Implement data reading
        // For now, return placeholder data to test the connection
        return mapOf(
            "steps" to null,
            "avgHeartRate" to null,
            "sleepDuration" to null,
            "status" to "SDK initialized but data reading not yet implemented"
        )
    }

    private fun disconnect() {
        healthDataStore = null
    }

    override fun onDestroy() {
        super.onDestroy()
        disconnect()
    }
}
