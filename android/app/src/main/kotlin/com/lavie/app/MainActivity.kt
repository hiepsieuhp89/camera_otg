package com.lavie.app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.lavie.app/usb"
    private lateinit var usbManager: UsbManager
    private lateinit var permissionIntent: PendingIntent
    private val ACTION_USB_PERMISSION = "com.lavie.app.USB_PERMISSION"
    
    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_USB_PERMISSION == intent.action) {
                synchronized(this) {
                    val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    }
                    
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        device?.apply {
                            Log.d("USB", "Permission granted for device: $deviceName")
                        }
                    } else {
                        Log.d("USB", "Permission denied for device")
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        
        // Create an explicit intent for the broadcast receiver
        val intent = Intent(ACTION_USB_PERMISSION)
        intent.setPackage(packageName)
        
        permissionIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            }
        )
        
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        
        // Register the receiver with the correct flags
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(usbReceiver, filter)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsbDevices" -> {
                    try {
                        // Use native USB manager API
                        val deviceList = usbManager.deviceList
                        val devices = deviceList.values.map { device ->
                            mapOf(
                                "name" to (device.deviceName ?: "Unknown Device"),
                                "vid" to device.vendorId,
                                "pid" to device.productId,
                                "source" to "native"
                            )
                        }
                        
                        Log.d("USB", "Found ${devices.size} USB devices")
                        for (device in devices) {
                            Log.d("USB", "USB device: ${device["name"]}, VID: ${device["vid"]}, PID: ${device["pid"]}")
                        }
                        
                        result.success(devices)
                    } catch (e: Exception) {
                        Log.e("USB", "Error getting USB devices", e)
                        result.error("USB_ERROR", "Failed to get USB devices: ${e.message}", e.message)
                    }
                }
                "requestUsbPermission" -> {
                    try {
                        // Request permission for all devices
                        val deviceList = usbManager.deviceList
                        if (deviceList.isEmpty()) {
                            result.error("NO_DEVICE", "No USB devices found", null)
                            return@setMethodCallHandler
                        }
                        
                        for (device in deviceList.values) {
                            if (!usbManager.hasPermission(device)) {
                                usbManager.requestPermission(device, permissionIntent)
                                Log.d("USB", "Requesting permission for: ${device.deviceName}")
                            } else {
                                Log.d("USB", "Already has permission for: ${device.deviceName}")
                            }
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("USB", "Error requesting permission", e)
                        result.error("PERMISSION_ERROR", "Failed to request USB permission", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(usbReceiver)
        } catch (e: Exception) {
            Log.e("USB", "Error on destroy", e)
        }
    }
} 