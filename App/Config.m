//
//  Config.m
//
//  Created by Alexey Yakovlev on 04/16/2017.
//

#import "App.h"
#import "Config.h"
#import "Trace.h"

static NSString *const textColor = @"textColor";
static NSString *const backgroundColor = @"backgroundColor";

@interface LoginForm : NSObject <FXForm>
 @property (nonatomic) NSString *timestamp;
 @property (nonatomic, copy) NSString *username;
 @property (nonatomic, copy) NSString *password;
 @property (nonatomic, assign) BOOL remember;
@end

@implementation LoginForm

- (NSArray *)fields
{
    UIColor *b = uiColor(loginBackgroundColor);
    return
    @[
        @{
            FXFormFieldHeader: _timestamp.length ? _timestamp : @"",
            FXFormFieldKey: @"username",
            FXFormFieldPlaceholder: @"name@example.com",
            FXFormFieldType: FXFormFieldTypeEmail,
            backgroundColor: b,
        },
        @{
            FXFormFieldKey: @"password",
            FXFormFieldPlaceholder: @"password",
            backgroundColor: b,
        },
        @{
            FXFormFieldKey: @"remember",
            FXFormFieldAction: @"login:",
            backgroundColor: b,
        },
        @{
            FXFormFieldTitle: @"Login",
            FXFormFieldAction: @"login:",
            textColor: uiColor(buttonTextColor),
            backgroundColor: b,
        },
    ];
}

@end

@interface ConfigForm : NSObject <FXForm>
 @property (nonatomic) NSString *country;
 @property (nonatomic, assign) Operation operation;
 @property (nonatomic, assign) Features features;
 @property (nonatomic, assign) Menu1 menu1;
 @property (nonatomic, assign) Menu2 menu2;
 @property (nonatomic) LoginForm *login;
 @property (nonatomic) Trace *trace;
@end

@implementation ConfigForm

- (NSArray *)fields
{
    UIColor *b = uiColor(configBackgroundColor);
    return
    @[
        @{
            FXFormFieldKey: @"login",
            backgroundColor: uiColor(loginBackgroundColor),
        },
        @{
            FXFormFieldHeader: @"",
            FXFormFieldKey: @"country",
            FXFormFieldOptions: @[@"US", @"BR", @"CA", @"GB", @"IN", @"MX"],
            FXFormFieldAction: @"country:",
            backgroundColor: b,
        },
        @{
            FXFormFieldKey: @"operation",
            FXFormFieldType: FXFormFieldTypeBitfield,
            FXFormFieldOptions: @[@"No Service"],
            backgroundColor: b,
        },
        @{
            FXFormFieldKey: @"features",
            FXFormFieldType: FXFormFieldTypeBitfield,
            FXFormFieldOptions: @[@"Track", @"Estimate", @"Locate", @"Menu", @"Send", @"Pay", @"Receive"],
            backgroundColor: b,
        },
        @{
            FXFormFieldKey: @"menu1",
            FXFormFieldType: FXFormFieldTypeBitfield,
            FXFormFieldOptions: @[@"Log In", @"Contact Us", @"FAQ", @"Our Services", @"Legal"],
            backgroundColor: b,
        },
        @{
            FXFormFieldKey: @"menu2",
            FXFormFieldType: FXFormFieldTypeBitfield,
            FXFormFieldOptions: @[@"Log Out", @"My Account", @"Contact Us", @"FAQ", @"Our Services", @"Legal"],
            backgroundColor: b,
        },
        @{
            FXFormFieldTitle: @"Save",
            FXFormFieldAction: @"save:",
            textColor: uiColor(buttonTextColor),
            backgroundColor: b,
        },
    ];
}

- (NSArray *)extraFields
{
    UISplitViewController *split = App.rootViewController;
    if (split.collapsed) //trace not visible? TODO: fix UISplitViewController issues
    {   return
        @[
            @{
                FXFormFieldHeader: @"Debug",
                FXFormFieldKey: @"trace",
                FXFormFieldViewController: Trace.class,
                FXFormFieldInline: @YES,
                backgroundColor: uiColor(traceBackgroundColor),
            }
        ];
    }
    return nil;
}

- (NSString *)loginFieldDescription
{   return _login.timestamp.length ? _login.timestamp : @"";  }

- (NSString *)countryFieldDescription
{   return _country.length ?
        [NSString stringWithFormat:@"%@(%ld, %ld, %ld, %ld)",
            _country,
            (long)_operation,
            (long)_features,
            (long)_menu1,
            (long)_menu2] :
        @"";
}

@end

@implementation Config

- (void)viewDidLoad
{
    LOG(@"Config.viewDidlLoad");
    [super viewDidLoad];

    ConfigForm *c = [[ConfigForm alloc] init];
    LoginForm  *l = [[LoginForm  alloc] init];
    NSDictionary *d = (c.login = l).fields[2]; //remember
    if (d)
    {
        l.remember = [[Preferences obj:d[@"key"] :@"0"] characterAtIndex:0] > '0';
    }
    self.title = @"Configuration";
    self.formController.form = c;
    
    FIRAuth *a = [FIRAuth auth];
    if (a.currentUser) //authenticated?
    {
        [self load];
    }
    else //no, open login form
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
        FXFormField *ff = [self.formController fieldForIndexPath: ip];
        FXFormViewController *vc = [[FXFormViewController class] alloc];
        vc.field = ff;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)login:(UITableViewCell<FXFormFieldCell> *)fc
{
    LoginForm *l = fc.field.form;
    NSString *k = fc.field.key;
    if ([k characterAtIndex:0] == 'r') //remember?
    {
        [Preferences save:k :@(l.remember ? "1":"0")];
        [Trace print:[NSString stringWithFormat:@"%@ %@",
            k, l.remember ? @"YES" : @"NO"]];
    }
    else if (!l.username.length ||
             !l.password.length) //empty?
    {
        [Alert show:self.title :@"Please enter username and password." :@"OK"];
    }
    else //perform login
    {
        [[FIRAuth auth] signInWithEmail:l.username
                               password:l.password
                              completion:^(FIRUser *usr, NSError *err)
        {
            if (!err)
            {
                l.username = l.password = nil; //clear
                [Preferences save:@"login.timestamp" :l.timestamp = [Trace now]];
                [Trace print:@"login successful"];
                [self.tableView reloadData];
                [self load];
            }
            else
            {
                [Alert show:self.title :err.localizedDescription :@"OK"]; //.delegate = self;
            }
        }];
    }
}

- (void)country:(UITableViewCell<FXFormFieldCell> *)fc
{
    ConfigForm *c = fc.field.form;
    [Preferences save:@"country" :c.country];
    [self load];
}

- (void)load
{
    ConfigForm *c = self.formController.form;
    c.country = [Preferences obj:@"country" :@"US"];
    c.login.timestamp = [Preferences str:@"login.timestamp"];
    
    NSString *path = [NSString stringWithFormat:@"config/%@", c.country];
    FIRDatabaseReference *r = [[FIRDatabase database] referenceWithPath:path];
    [r observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *s)
    {
        if (s.value &&
          ![s.value isKindOfClass:[NSNull class]])
        {
            c.operation = [s.value[@"of"] integerValue];
            c.features  = [s.value[@"ff"] integerValue];
            c.menu1     = [s.value[@"m1"] integerValue];
            c.menu2     = [s.value[@"m2"] integerValue];
        }
        else
        {
            c.operation = 0;
            c.features  = 0;
            c.menu1     = 0;
            c.menu2     = 0;
        }

        [Trace print:[NSString stringWithFormat:@"load %@", c.countryFieldDescription]];
        [self.tableView reloadData];
    }
    withCancelBlock:^(NSError * _Nonnull err)
    {
        [Alert show:self.title :err.localizedDescription :@"OK"];
    }];
}

- (void)save:(UITableViewCell<FXFormFieldCell> *)fc
{
    ConfigForm *c = fc.field.form;
    NSString *path = [NSString stringWithFormat:@"config/%@", c.country];
    FIRDatabaseReference *r = [[FIRDatabase database] referenceWithPath:path];
    [[r child:@"of"] setValue:@(c.operation)];
    [[r child:@"ff"] setValue:@(c.features)];
    [[r child:@"m1"] setValue:@(c.menu1)];
    [[r child:@"m2"] setValue:@(c.menu2)];

    [Trace print:[NSString stringWithFormat:@"save %@", c.countryFieldDescription]];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button
{
    LOG(@"Alert.clickedButtonAtIndex %ld", (long)button);
}

@end
