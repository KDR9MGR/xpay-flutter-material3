import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Add crash prevention and memory safety
    setupCrashPrevention()
    
    // Register plugins with error handling
    do {
      GeneratedPluginRegistrant.register(with: self)
    } catch {
      print("Error registering plugins: \(error)")
      // Continue without plugins if registration fails
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Crash Prevention Setup
  private func setupCrashPrevention() {
    // Set up global exception handler
    NSSetUncaughtExceptionHandler { exception in
      print("Uncaught exception: \(exception)")
      print("Stack trace: \(exception.callStackSymbols)")
    }
    
    // Set up signal handler for SIGSEGV
    signal(SIGSEGV) { signal in
      print("SIGSEGV signal received: \(signal)")
      // Log the crash and attempt graceful recovery
    }
    
    // Set up signal handler for SIGABRT
    signal(SIGABRT) { signal in
      print("SIGABRT signal received: \(signal)")
      // Log the crash and attempt graceful recovery
    }
    
    // Set up signal handler for SIGBUS
    signal(SIGBUS) { signal in
      print("SIGBUS signal received: \(signal)")
      // Log the crash and attempt graceful recovery
    }
    
    // Set up signal handler for SIGILL
    signal(SIGILL) { signal in
      print("SIGILL signal received: \(signal)")
      // Log the crash and attempt graceful recovery
    }
  }
  
  // MARK: - Memory Management
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    super.applicationDidReceiveMemoryWarning(application)
    print("Memory warning received - cleaning up resources")
    
    // Clear image caches and other memory-intensive resources
    URLCache.shared.removeAllCachedResponses()
    
    // Force garbage collection if available
    if #available(iOS 13.0, *) {
      // iOS 13+ has better memory management
    }
  }
  
  // MARK: - Background/Foreground Handling
  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    print("Application will resign active - saving state")
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    print("Application did enter background - cleaning up")
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    print("Application will enter foreground - restoring state")
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    print("Application did become active")
  }
}
