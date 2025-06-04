import Flutter
import UIKit
import GoogleMobileAds // GoogleMobileAds SDK のインポート
import FirebaseCore // Firebase Core SDK のインポート

@main
@objc class AppDelegate: FlutterAppDelegate {
  // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // この行は通常不要、または既存のテンプレートに依存します。
                                                           // もしXcodeでエラーが出るなら削除してください。
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ★★★ 修正点: Firebase の初期化を追加 ★★★
    FirebaseApp.configure()

    // ★★★ 修正点: GoogleMobileAds SDK の初期化を追加 ★★★
    // AdMob SDK の初期化
    GADMobileAds.sharedInstance().start(completionHandler: nil)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}