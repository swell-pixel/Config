//
//  Trace.h
//
//  Created by Alexey Yakovlev on 11/30/2016.
//

static NSInteger traceBackgroundColor = 0xfffde7; //yellow 50

@interface Trace : UIViewController

 + (NSString *)now;
 + (NSString *)gmt;

 + (void)print:(NSString *)str;
 + (void)show;
 + (void)clear;

@end

@interface Alert : NSObject
 + (UIAlertView *)show:(NSString *)title :(NSString *)message :(NSString *)cancel;
 + (void)hide;
@end
