//
//  Config.h
//
//  Created by Alexey Yakovlev on 04/16/2017.
//

typedef NS_OPTIONS(NSInteger, Operation)
{
    OF_NOSERVICE  = 1,
};
typedef NS_OPTIONS(NSInteger, Features)
{
    FF_TRACK      = 1,
    FF_FEES       = 2,
    FF_LOCATIONS  = 4,
    FF_MENU       = 8,
    FF_SEND       = 16,
    FF_PAY        = 32,
    FF_RECEIVE    = 64,
};
typedef NS_OPTIONS(NSInteger, Menu1)
{
    M1_LOGIN      = 1,
    M1_CONTACT    = 2,
    M1_FAQ        = 4,
    M1_SERVICES   = 8,
    M1_LEGAL      = 16,
};
typedef NS_OPTIONS(NSInteger, Menu2)
{
    M2_LOGOUT     = 1,
    M2_ACCOUNT    = 2,
    M2_CONTACT    = 4,
    M2_FAQ        = 8,
    M2_SERVICES   = 16,
    M2_LEGAL      = 32,
};

static NSInteger loginBackgroundColor  = 0xe8f5e9; //green 50
static NSInteger configBackgroundColor = 0xffebee; //red 50
static NSInteger buttonTextColor       = 0x007aff; //Apple blue button

@interface Config : FXFormViewController <UIAlertViewDelegate>
@end
