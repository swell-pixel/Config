//
//  Config-Obj-C
//
//  Created by Alexey Yakovlev on 04/08/2017.
//

#import "App.h"
#import "Config.h"
#import "Trace.h"

@implementation App

+ (App *)delegate
{   return (App *)[[UIApplication sharedApplication] delegate];  }

+ (UIInterfaceOrientation)orientation
{   return [[UIApplication sharedApplication] statusBarOrientation];  }

+ (UISplitViewController *)rootViewController
{   return (UISplitViewController *)App.delegate.window.rootViewController;  }

+ (NSString *)nameVersionBuild
{
    NSDictionary *nfo = [[NSBundle mainBundle] infoDictionary];
    NSString *app = [nfo objectForKey:@"CFBundleName"];
    NSString *ver = [nfo objectForKey:@"CFBundleShortVersionString"];
    NSString *bld = [nfo objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ v%@ (%@)", app, ver, bld];
}

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)opt
{
    [Trace print:App.nameVersionBuild];
    LOG(@"App.didFinishLaunchingWithOptions");
    
    //https://material.io/guidelines/style/color.html#color-color-palette
    [[UINavigationBar appearance] setBarTintColor:uiColor(0xff8a80)]; //red A100
    
    //http://blog.jaredsinclair.com/post/61507315630/wrestling-with-status-bars-and-navigation-bars-on
    UINavigationController *master = [[UINavigationController alloc]
                                   initWithRootViewController:[[Config alloc] init]];
    UINavigationController *detail = [[UINavigationController alloc]
                                   initWithRootViewController:[[Trace alloc] init]];
    detail.navigationBar.hidden = YES;
    detail.edgesForExtendedLayout = UIRectEdgeNone;
    //detail.automaticallyAdjustsScrollViewInsets = NO;
    
    UISplitViewController *split = [[UISplitViewController alloc] init];
    split.viewControllers = @[master, detail];
    split.delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = split;
    [self.window makeKeyAndVisible];
    
    [FIRApp configure];
    return YES;
}

- (BOOL)splitViewController:(UISplitViewController *)split
 collapseSecondaryViewController:(UIViewController *)detail
       ontoPrimaryViewController:(UIViewController *)master
{
    UINavigationController *nc = (UINavigationController *)master;
    UITableViewController *tc = (UITableViewController *)nc.visibleViewController;
    LOG(@"App.collapseSecondaryViewController %@ onto %@ %ld", tc, nc, split.displayMode);
    return YES; //hide detail...
}

- (BOOL)splitViewController:(UISplitViewController *)split
        shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)or
{
    //LOG(@"App.shouldHideViewController %@ %ld %ld", vc, or, split.displayMode);
    return NO; //...don't hide master
}

@end

@implementation Preferences

+ (id)obj:(NSString *)key :(id)dflt
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj ? obj : dflt;
}

+ (NSString *)str:(NSString *)key
{   return [self obj:key :@""];  }

+ (void)set:(NSString *)key :(id)obj
{   [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];   }

+ (BOOL)save:(NSString *)key :(id)obj
{   [self set:key :obj]; return [self sync];   }

+ (BOOL)sync
{   return [[NSUserDefaults standardUserDefaults] synchronize];   }

@end

int main(int argc, char * argv[])
{
    @autoreleasepool
    {   return UIApplicationMain(argc, argv, nil, NSStringFromClass([App class]));  }
}

//EOF
