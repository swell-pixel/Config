//
//  Config-Swift
//
//  Created by Alexey Yakovlev on 04/08/2017.
//

import UIKit

//logging
#if DEBUG
 let LOG = NSLog
#else
 let LOG = {}
#endif

extension UIColor
{
    convenience init(_ rgb: Int)
    {
        let r = (rgb & 0xff0000) >> 16
        let g = (rgb & 0xff00) >> 8
        let b =  rgb & 0xff

        self.init(
            red:   CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue:  CGFloat(b) / 0xff, alpha: 1
        )
    }
}

@UIApplicationMain
class App: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate
{
    class var delegate: App
    {   return (UIApplication.shared.delegate! as? App)!  }

    class var rootViewController: UISplitViewController
    {   return (App.delegate.window?.rootViewController as? UISplitViewController)!  }
    
    class var nameVersionBuild: String
    {
        var nfo: [AnyHashable: Any]? = Bundle.main.infoDictionary
        let app: String? = (nfo?["CFBundleName"] as? String)
        let ver: String? = (nfo?["CFBundleShortVersionString"] as? String)
        let bld: String? = (nfo?["CFBundleVersion"] as? String)
        return String(format:"%@ v%@ (%@)", app ?? "", ver ?? "", bld ?? "")
    }

    var window: UIWindow?

    func application(_ app: UIApplication, didFinishLaunchingWithOptions
                       opt: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        Trace.print(App.nameVersionBuild)
        LOG("App.didFinishLaunchingWithOptions")
        
        UINavigationBar.appearance().barTintColor = UIColor(0xff8a80) //red A100

        let master = UINavigationController(rootViewController: Config());
        let detail = UINavigationController(rootViewController:  Trace());
        detail.navigationBar.isHidden = true;
        detail.edgesForExtendedLayout = [];

        let split = UISplitViewController();
        split.viewControllers = [master, detail];
        split.delegate = self;

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = split;
        window?.makeKeyAndVisible();

        FIRApp.configure()
        return true
    }
    
    func splitViewController(_ split: UISplitViewController,
            collapseSecondary detail: UIViewController,
                         onto master: UIViewController) -> Bool
    {
        let nc: UINavigationController? = (master as? UINavigationController)
        let tc: UITableViewController? = (nc?.visibleViewController as? UITableViewController)
        tc?.tableView?.reloadData()
        return true //hide detail...
    }

    func splitViewController(_ split: UISplitViewController,
                             shouldHide vc: UIViewController,
                             in or: UIInterfaceOrientation) -> Bool
    {   return false  } //...don't hide master
}
