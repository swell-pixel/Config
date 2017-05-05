//
//  Config-Obj-C
//
//  Created by Alexey Yakovlev on 04/08/2017.
//

#import <UIKit/UIKit.h>

//C array size
#ifndef N
 #define N(n)  (sizeof(n)/sizeof(n[0]))
#endif

//logging
#ifdef DEBUG
 #define LOG(...) NSLog(__VA_ARGS__)
#else
 #define LOG(...) (void)0
#endif
#define ERR(...) NSLog(__VA_ARGS__)

static BOOL isTablet()
{   return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;  }

static BOOL isLandscape()
{   return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);  }

static UIColor *uiColor(NSInteger rgb)
{   return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0
                           green:((float)((rgb & 0xFF00) >> 8))/255.0
                            blue:((float) (rgb & 0xFF))/255.0
                           alpha:1.0];
}

@interface Preferences : NSObject
 + (id)obj:(NSString *)key :(id)dflt;
 + (NSString *)str:(NSString *)key;
 + (void)set:(NSString *)key :(id)obj;
 + (BOOL)save:(NSString *)key :(id)obj;
 + (BOOL)sync;
@end

@interface App : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate>
 @property (nonatomic) UIWindow *window;
 + (App *)delegate;
 + (UISplitViewController *)rootViewController;
 + (NSString *)nameVersionBuild;
@end
