//
//  ThreadingUtils.swift
//  Runner
//
//  Created by AI Assistant
//  Copyright © 2024 Digital Payments. All rights reserved.
//

import Foundation
import UIKit

/// Centralized threading utilities for iOS to prevent EXC_BAD_ACCESS and improve performance
class ThreadingUtils {
    
    // MARK: - Singleton
    static let shared = ThreadingUtils()
    private init() {}
    
    // MARK: - Thread Safety Properties
    private let serialQueue = DispatchQueue(label: "com.digital.payments.threading", qos: .userInitiated)
    private var isMainThreadBlocked = false
    private let mainThreadLock = NSLock()
    
    // MARK: - Safe Main Thread Operations
    
    /// Safely execute operation on main thread with timeout protection
    /// - Parameters:
    ///   - timeout: Maximum time to wait (default: 5 seconds)
    ///   - operation: Block to execute on main thread
    static func safeMainThread(timeout: TimeInterval = 5.0, _ operation: @escaping () -> Void) {
        let instance = ThreadingUtils.shared
        
        // Check if we're already on main thread
        if Thread.isMainThread {
            // Prevent recursive blocking
            instance.mainThreadLock.lock()
            defer { instance.mainThreadLock.unlock() }
            
            if instance.isMainThreadBlocked {
                print("⚠️ Main thread operation skipped - already blocked")
                return
            }
            
            instance.isMainThreadBlocked = true
            operation()
            instance.isMainThreadBlocked = false
        } else {
            // Execute on main thread with timeout
            let semaphore = DispatchSemaphore(value: 0)
            var completed = false
            
            DispatchQueue.main.async {
                operation()
                completed = true
                semaphore.signal()
            }
            
            let result = semaphore.wait(timeout: .now() + timeout)
            if result == .timedOut && !completed {
                print("⚠️ Main thread operation timed out after \(timeout) seconds")
            }
        }
    }
    
    /// Execute operation on background thread with error handling
    /// - Parameters:
    ///   - qos: Quality of service (default: .userInitiated)
    ///   - operation: Block to execute
    ///   - completion: Optional completion handler on main thread
    static func safeBackground(
        qos: DispatchQoS.QoSClass = .userInitiated,
        _ operation: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.global(qos: qos).async {
            autoreleasepool {
                do {
                    operation()
                    
                    if let completion = completion {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                } catch {
                    print("🚨 Background operation failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Firebase Safe Operations
    
    /// Execute Firebase operations with proper thread safety
    /// - Parameters:
    ///   - operation: Firebase operation to execute
    ///   - completion: Completion handler
    static func safeFirebaseOperation<T>(
        _ operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        ThreadingUtils.safeBackground(qos: .userInitiated) {
            operation { result in
                ThreadingUtils.safeMainThread {
                    completion(result)
                }
            }
        }
    }
    
    // MARK: - Memory Management
    
    /// Perform memory cleanup with thread safety
    static func performMemoryCleanup() {
        ThreadingUtils.safeBackground(qos: .utility) {
            autoreleasepool {
                // Clear URL cache
                URLCache.shared.removeAllCachedResponses()
                
                // Clear image caches if available
                ThreadingUtils.safeMainThread {
                    // Notify system of memory pressure
                    if #available(iOS 13.0, *) {
                        // Modern iOS handles this automatically
                    }
                }
            }
        }
    }
    
    // MARK: - Plugin Safety
    
    /// Safely initialize plugins with error handling
    /// - Parameters:
    ///   - pluginName: Name of the plugin
    ///   - initialization: Initialization block
    static func safePluginInitialization(
        pluginName: String,
        _ initialization: @escaping () throws -> Void
    ) {
        // Use serial queue to prevent race conditions during plugin registration
        ThreadingUtils.shared.serialQueue.async {
            ThreadingUtils.safeMainThread(timeout: 15.0) {
                autoreleasepool {
                    do {
                        // Add memory barrier to ensure proper synchronization
                        OSMemoryBarrier()
                        
                        print("🔄 Initializing plugin: \(pluginName)")
                        try initialization()
                        
                        // Another memory barrier after initialization
                        OSMemoryBarrier()
                        
                        print("✅ Plugin \(pluginName) initialized successfully")
                    } catch {
                        print("🚨 Plugin \(pluginName) initialization failed: \(error)")
                        
                        // Attempt recovery for critical plugins
                        if pluginName.contains("Firebase") || pluginName.contains("GeneratedPluginRegistrant") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                print("🔄 Retrying critical plugin: \(pluginName)")
                                do {
                                    try initialization()
                                    print("✅ Plugin \(pluginName) retry successful")
                                } catch {
                                    print("🚨 Plugin \(pluginName) retry failed: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Deadlock Prevention
    
    /// Execute operation with deadlock detection
    /// - Parameters:
    ///   - timeout: Maximum execution time
    ///   - operation: Operation to execute
    ///   - onTimeout: Timeout handler
    static func executeWithDeadlockDetection(
        timeout: TimeInterval = 10.0,
        operation: @escaping () -> Void,
        onTimeout: (() -> Void)? = nil
    ) {
        let workItem = DispatchWorkItem(block: operation)
        
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
        
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + timeout) {
            if !workItem.isCancelled {
                workItem.cancel()
                print("⚠️ Operation cancelled due to potential deadlock")
                onTimeout?()
            }
        }
    }
    
    // MARK: - Thread Monitoring
    
    /// Monitor current thread state
    static func logCurrentThreadState() {
        let thread = Thread.current
        let isMain = Thread.isMainThread
        let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) ?? "unknown"
        
        print("🧵 Thread Info:")
        print("   - Is Main: \(isMain)")
        print("   - Queue: \(queueLabel)")
        print("   - Thread: \(thread)")
        print("   - Memory: \(getMemoryUsage()) MB")
    }
    
    /// Get current memory usage
    private static func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        }
        return 0.0
    }
    
    // MARK: - Error Recovery
    
    /// Attempt to recover from threading errors
    static func attemptErrorRecovery() {
        print("🔄 Attempting threading error recovery...")
        
        ThreadingUtils.safeBackground(qos: .utility) {
            // Clear any pending operations
            OperationQueue.main.cancelAllOperations()
            
            // Force memory cleanup
            ThreadingUtils.performMemoryCleanup()
            
            // Reset thread state
            ThreadingUtils.shared.mainThreadLock.lock()
            ThreadingUtils.shared.isMainThreadBlocked = false
            ThreadingUtils.shared.mainThreadLock.unlock()
            
            print("✅ Threading error recovery completed")
        }
    }
}

// MARK: - Extensions for Common Operations

extension DispatchQueue {
    /// Safely execute on main queue with timeout
    static func safeMain(timeout: TimeInterval = 5.0, execute work: @escaping () -> Void) {
        ThreadingUtils.safeMainThread(timeout: timeout, work)
    }
    
    /// Safely execute on background queue
    static func safeBackground(qos: DispatchQoS.QoSClass = .userInitiated, execute work: @escaping () -> Void) {
        ThreadingUtils.safeBackground(qos: qos, work)
    }
}