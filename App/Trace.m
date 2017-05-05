//
//  Trace.m
//
//  Created by Alexey Yakovlev on 11/30/2016.
//

#import "App.h"
#import "Trace.h"

static NSString *_trace = @"";
static UITextView *_view;

@implementation Trace

+ (NSString *)now
{
    static NSDateFormatter *ldf;
    if (!ldf)
    {
        ldf = [[NSDateFormatter alloc] init];
        [ldf setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //24h
    }
    return [ldf stringFromDate:[NSDate date]];
}

+ (NSString *)gmt
{
    static NSDateFormatter *gdf;
    if (!gdf)
    {
        gdf = [[NSDateFormatter alloc] init];
        [gdf setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //24h
        [gdf setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    return [gdf stringFromDate:[NSDate date]];
}

+ (void)print:(NSString *)str
{
    LOG(@"%@", str);
    _trace = [_trace stringByAppendingFormat:@"%@  %@\n", [Trace now], str];
    [Trace show];
}

+ (void)show
{
    if (_view)
    {
        dispatch_async(dispatch_get_main_queue(), //ensure UI code is on main thread
        ^{
            [_view setText:_trace];
            [_view scrollRangeToVisible:NSMakeRange(_trace.length, 0)];
            [_view setScrollEnabled:NO];
            [_view setScrollEnabled:YES];
        });
    }
}

+ (void)clear
{
    [_view setText:nil];
    [Trace show];
}

- (void)viewDidLoad
{
    //LOG(@"Trace.viewDidlLoad");
    [super viewDidLoad];
    
    _view = [[UITextView alloc] initWithFrame:self.view.bounds];
    _view.editable = NO;
    _view.scrollEnabled = YES;
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _view.font = [UIFont systemFontOfSize:12];
    _view.backgroundColor = uiColor(traceBackgroundColor);
    self.view = _view;
    
    [Trace show];
}

- (void)viewDidUnload
{
    //LOG(@"Trace.viewDidUnload");
    [super viewDidUnload];

    _view = nil;
}

- (void)didReceiveMemoryWarning
{
    //LOG(@"Trace.didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    
    [Trace clear];
}

@end

static UIAlertView *_alert;

@implementation Alert

+ (UIAlertView *)show:(NSString *)title :(NSString *)message :(NSString *)cancel
{
    [Trace print:[NSString stringWithFormat:@"alert(%@, %@, %@)", title, message, cancel]];
    [self hide];
    _alert = [[UIAlertView alloc] initWithTitle:title
                                         message:message
                                        delegate:self
                               cancelButtonTitle:cancel
                               otherButtonTitles:nil];
    [_alert show];
    return _alert;
}

+ (void)hide
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    _alert = nil;
}

@end
