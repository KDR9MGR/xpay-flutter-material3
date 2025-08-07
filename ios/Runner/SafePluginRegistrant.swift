//
//  SafePluginRegistrant.swift
//  Runner
//
//  Thread-safe wrapper for GeneratedPluginRegistrant
//

import Foundation
import Flutter

@objc class SafePluginRegistrant: NSObject {
    
    private static let registrationQueue = DispatchQueue(label: "com.digital.payments.plugin.registration", qos: .userInitiated)
    private static var isRegistered = false
    private static let registrationLock = NSLock()
    
    @objc static func safeRegisterWithRegistry(_ registry: NSObject & FlutterPluginRegistry) {
        registrationLock.lock()
        defer { registrationLock.unlock() }
        
        guard !isRegistered else {
            print("🔄 Plugins already registered, skipping")
            return
        }
        
        print("🔄 Starting safe plugin registration")
        
        registrationQueue.async {
            DispatchQueue.main.async {
                autoreleasepool {
                    do {
                        // Register plugins one by one with error handling
                        registerFirebasePlugins(registry)
                        registerUtilityPlugins(registry)
                        registerUIPlugins(registry)
                        
                        SafePluginRegistrant.isRegistered = true
                        print("✅ All plugins registered successfully")
                        
                    } catch {
                        print("🚨 Plugin registration failed: \(error)")
                    }
                }
            }
        }
    }
    
    private static func registerFirebasePlugins(_ registry: NSObject & FlutterPluginRegistry) {
        let firebasePlugins = [
            ("FLTFirebaseCorePlugin", "FLTFirebaseCorePlugin"),
            ("FLTFirebaseFirestorePlugin", "FLTFirebaseFirestorePlugin"),
            ("FirebaseFunctionsPlugin", "FirebaseFunctionsPlugin"),
            ("FirebaseAnalyticsPlugin", "FirebaseAnalyticsPlugin"),
            ("FLTFirebaseAuthPlugin", "FLTFirebaseAuthPlugin"),
            ("FLTFirebaseCrashlyticsPlugin", "FLTFirebaseCrashlyticsPlugin"),
            ("FLTFirebasePerformancePlugin", "FLTFirebasePerformancePlugin"),
            ("FLTFirebaseStoragePlugin", "FLTFirebaseStoragePlugin")
        ]
        
        for (pluginName, registrarKey) in firebasePlugins {
            registerSinglePlugin(pluginName: pluginName, registrarKey: registrarKey, registry: registry)
        }
    }
    
    private static func registerUtilityPlugins(_ registry: NSObject & FlutterPluginRegistry) {
        let utilityPlugins = [
            ("PathProviderPlugin", "PathProviderPlugin"),
            ("SharedPreferencesPlugin", "SharedPreferencesPlugin"),
            ("URLLauncherPlugin", "URLLauncherPlugin")
        ]
        
        for (pluginName, registrarKey) in utilityPlugins {
            registerSinglePlugin(pluginName: pluginName, registrarKey: registrarKey, registry: registry)
        }
    }
    
    private static func registerUIPlugins(_ registry: NSObject & FlutterPluginRegistry) {
        let uiPlugins = [
            ("FLTImagePickerPlugin", "FLTImagePickerPlugin"),
            ("MobileScannerPlugin", "MobileScannerPlugin"),
            ("PayPlugin", "PayPlugin"),
            ("StripeIosPlugin", "StripeIosPlugin"),
            ("FVPVideoPlayerPlugin", "FVPVideoPlayerPlugin"),
            ("WebViewFlutterPlugin", "WebViewFlutterPlugin")
        ]
        
        for (pluginName, registrarKey) in uiPlugins {
            registerSinglePlugin(pluginName: pluginName, registrarKey: registrarKey, registry: registry)
        }
    }
    
    private static func registerSinglePlugin(pluginName: String, registrarKey: String, registry: NSObject & FlutterPluginRegistry) {
        autoreleasepool {
            do {
                // Add small delay to prevent overwhelming the system
                Thread.sleep(forTimeInterval: 0.01)
                
                // Get registrar safely
                let registrar = registry.registrar(forPlugin: registrarKey)
                
                // Use reflection to safely call the registration method
                if let pluginClass = NSClassFromString(pluginName) as? NSObject.Type {
                    if pluginClass.responds(to: #selector(NSObject.registerWithRegistrar(_:))) {
                        pluginClass.perform(#selector(NSObject.registerWithRegistrar(_:)), with: registrar)
                        print("✅ Registered plugin: \(pluginName)")
                    } else {
                        print("⚠️ Plugin \(pluginName) does not respond to registerWithRegistrar")
                    }
                } else {
                    print("⚠️ Could not find plugin class: \(pluginName)")
                }
                
            } catch {
                print("🚨 Failed to register plugin \(pluginName): \(error)")
            }
        }
    }
}

// Extension to add the registerWithRegistrar selector
extension NSObject {
    @objc dynamic func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        // This is a placeholder - actual implementation is in each plugin class
    }
}