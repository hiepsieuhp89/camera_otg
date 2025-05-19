package com.lavie.app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val USB_CHANNEL = "com.lavie.app/usb"
    private val CHANNEL = "com.lavie.app/usb_camera"
    private lateinit var usbManager: UsbManager
    private lateinit var permissionIntent: PendingIntent
    private val ACTION_USB_PERMISSION = "com.lavie.app.USB_PERMISSION"
    
    private var usbMethodChannel: MethodChannel? = null
    private var cameraMethodChannel: MethodChannel? = null
    
    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    println("USB device attached")
                    Log.d("USB", "Device attached: ${intent.data}")
                    usbMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                    cameraMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    println("USB device detached")
                    Log.d("USB", "Device detached: ${intent.data}")
                }
                "android.hardware.usb.action.USB_DEVICE_ATTACHED" -> {
                    println("USB device attached (alternative action)")
                    Log.d("USB", "Device attached (alt): ${intent.data}")
                    usbMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                    cameraMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                }
                "android.hardware.usb.action.USB_PERMISSION" -> {
                    println("USB permission dialog shown")
                    Log.d("USB", "Permission requested")
                    usbMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                    cameraMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                }
                ACTION_USB_PERMISSION -> {
                    synchronized(this) {
                        val device: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        val permissionGranted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                        if (permissionGranted) {
                            Log.d("USB", "Permission granted for device: ${device?.deviceName}")
                            usbMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                            cameraMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                        } else {
                            Log.d("USB", "Permission denied for device: ${device?.deviceName}")
                        }
                    }
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize USB manager
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
        
        // Register USB broadcast receivers
        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
            addAction("android.hardware.usb.action.USB_DEVICE_ATTACHED")
            addAction("android.hardware.usb.action.USB_PERMISSION")
            addAction(ACTION_USB_PERMISSION)
        }
        
        // Register the receiver with the correct flags
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(usbReceiver, filter)
        }
        
        // Check for USB devices that are already connected
        val deviceList = usbManager.deviceList
        if (deviceList.isNotEmpty()) {
            Log.d("USB", "Already connected USB devices found at startup: ${deviceList.size}")
        }
        
        // Check if this activity was started by a USB intent
        if (intent?.action == UsbManager.ACTION_USB_DEVICE_ATTACHED ||
            intent?.action == "android.hardware.usb.action.USB_DEVICE_ATTACHED" ||
            intent?.action == "android.hardware.usb.action.USB_PERMISSION") {
            // Will notify Flutter side when method channel is set up
            Log.d("USB", "Activity started by USB intent: ${intent.action}")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup method channels
        usbMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USB_CHANNEL)
        cameraMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Check if activity was started by USB intent and notify now that channels are ready
        if (intent?.action == UsbManager.ACTION_USB_DEVICE_ATTACHED ||
            intent?.action == "android.hardware.usb.action.USB_DEVICE_ATTACHED" ||
            intent?.action == "android.hardware.usb.action.USB_PERMISSION") {
            usbMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
            cameraMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
        }

        usbMethodChannel?.setMethodCallHandler { call, result ->
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
        
        // Camera method channel simply passes through to Flutter for now
        cameraMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkForUSBCameras" -> {
                    try {
                        val deviceList = usbManager.deviceList
                        val hasUsbDevices = deviceList.isNotEmpty()
                        result.success(hasUsbDevices)
                        
                        // If we detect USB devices, also send a notification
                        if (hasUsbDevices) {
                            cameraMethodChannel?.invokeMethod("usbCameraPermissionRequested", null)
                        }
                    } catch (e: Exception) {
                        Log.e("USB", "Error checking for USB cameras", e)
                        result.error("USB_ERROR", "Failed to check for USB cameras: ${e.message}", e.message)
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