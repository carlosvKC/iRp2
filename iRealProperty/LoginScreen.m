#import "LoginScreen.h"
#import "RealPropertyApp.h"
#import "Helper.h"
#import "Keychain.h"
#import "Crittercism.h"


#define TIMESWITCHTOBACKGROUND  (5*60.0)


@implementation LoginScreen

    @synthesize btnTestDrawing;
    @synthesize labelVersion;
    @synthesize descriptionText;
    @synthesize backgroundPict;
    @synthesize comments;
    @synthesize errorMessage;
    @synthesize btnLogin;

    @synthesize loginName;
    @synthesize loginPassword;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    // _currentOrientation = 0;
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];
        }


#pragma mark - Button login has been clicked



    - (void)performLogin:(id)sender
        {

            [Helper findAndResignFirstResponder:self.view];
            /* 8/21/13 HNN remove logic for Mobise users to login with test account
           if([loginName.text caseInsensitiveCompare:@"irene"]==NSOrderedSame &&
               [loginPassword.text caseInsensitiveCompare:@"price"]==NSOrderedSame)
            {
                NSMutableDictionary *loginDict = [[NSMutableDictionary alloc]init];
                [loginDict setValue:@"TOKEN" forKey:@"token"];
                [loginDict setValue:@"ADOR" forKey:@"code"];
                [loginDict setValue:@"2" forKey:@"level"];
                [loginDict setValue:@"2013" forKey:@"taxYear"];
                [loginDict setValue:@"9/1/2011" forKey:@"startYear"];

                [self requestLoginDone:nil loginInfo:loginDict];
                return;
            }
             */
            // ---
            // 8/21/13 HNN allow user to log into test environment when login name prefix with test
            NSRange range = [loginName.text rangeOfString:@"test\\" options:NSCaseInsensitiveSearch];
            NSString *name = loginName.text;
            /* 8/21/13 HNN remove logic for Mobise users to login with test account
            if(range.length==0)
            {
                range = [loginName.text rangeOfString:@"harris\\" options:NSCaseInsensitiveSearch];
                name = loginName.text;
            }
             */
            if (range.length > 0)
                {
                    name = [name stringByReplacingCharactersInRange:range withString:@""];
                    [RealPropertyApp loginAsTester:YES];
                }
            else
                [RealPropertyApp loginAsTester:NO];


            if (![RealPropertyApp reachNetworkStatus])
                {
                    // There is no network on this device
                    // Check if the password already exists
                    NSString *storedPassword = [Keychain getStringForKey:@"PASSWORD"];
                    NSString *userName       = [Keychain getStringForKey:@"USERNAME"];

                    if ([storedPassword isEqualToString:loginPassword.text] &&
                            [userName caseInsensitiveCompare:loginName.text] == NSOrderedSame)
                        {
                            NSString *userCode      = [Keychain getStringForKey:@"CODE"];
                            NSString *userLevel     = [Keychain getStringForKey:@"LEVEL"];
                            NSString *userTaxYear   = [Keychain getStringForKey:@"TAXYEAR"];
                            NSString *userStartYear = [Keychain getStringForKey:@"CYCLESTARTDATE"];
                            NSString *userSaleYear  = [Keychain getStringForKey:@"SALESTARTDATE"];
                            NSString *userToken     = [Keychain getStringForKey:@"TOKEN"];

                            NSMutableDictionary *loginDict = [[NSMutableDictionary alloc] init];
                            [loginDict setValue:userToken forKey:@"token"];
                            [loginDict setValue:userCode forKey:@"code"];
                            [loginDict setValue:userLevel forKey:@"level"];
                            [loginDict setValue:userTaxYear forKey:@"taxYear"];
                            [loginDict setValue:userStartYear forKey:@"cyleStartDate"];
                            [loginDict setValue:userSaleYear forKey:@"saleStartDate"];

                            [self requestLoginDone:nil loginInfo:loginDict];

                            return;
                        }
                }
            ATActivityIndicator *indicator = [ATActivityIndicator currentIndicator];
            [indicator displayActivity:@"Login"];

            // Try to log-on
            Requester *requester = [[Requester alloc] init:[RealPropertyApp getDataUrl]];
            requester.delegate = self;
            loginPassword.text =@"Highway99!";

            [requester executeLogin:name withPassword:loginPassword.text];

        }



    - (void)requestDidFail:(Requester *)r
                 withError:(NSError *)error
        {
            [[ATActivityIndicator currentIndicator] hide];

            if (error.code == 401)
                {
                    loginName.text     = @"";
                    loginPassword.text = @"";
                    errorMessage.text  = @"Incorrect Login";
                    return;
                }

            // Something more serious happened
            NSString *msg = [NSString stringWithFormat:@"Network Error (code=%d)", error.code];
            [Helper alertWithOk:msg message:@"Verify that you have a valid connection to Internet and try again."];

        }



    - (void)requestLoginDone:(Requester *)r
                   loginInfo:(NSDictionary *)loginInfo
        {
            [[ATActivityIndicator currentIndicator] hide];

            if (loginInfo == nil)
                return;

            [Helper findAndResignFirstResponder:loginName];

            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            // Requester should return the user name as well as the level.
            [self loadOrCreateConfiguration:loginInfo];

            [self updateKeychainWithLoginInfo:loginInfo andUserName:loginName.text];

            // set up the tax year
            [RealPropertyApp setTaxYear:[[loginInfo valueForKey:@"taxYear"] intValue]];
            [RealPropertyApp setCycleStartDate:[loginInfo valueForKey:@"cyleStartDate"]];
            [RealPropertyApp setSaleStartDate:[loginInfo valueForKey:@"saleStartDate"]];

            [Crittercism setUsername:loginName.text];

            [appDelegate resumeApplication];
        }



//
// Load the preferences based on the current user name
//
    - (void)loadOrCreateConfiguration:(NSDictionary *)loginInfo
        {
            NSManagedObjectContext *context = [AxDataManager configContext];
            Configuration          *config;

            config = [AxDataManager getEntityObject:@"Configuration" andPredicate:[NSPredicate predicateWithFormat:@"1==1"] andContext:context];

            // New configuration file
            if (config == nil)
                {
                    config = [AxDataManager getNewEntityObject:@"Configuration" andContext:context];

                    config.menuAtBottom  = YES;
                    config.currentArea   = [Helper findFirstValidDirectory:@"Area"];
                    config.lockingCode   = @"0000"; // default code
                    config.requiredAfter = 1;   // 2nd choice
                    config.useEffects    = YES;
                }
            else if (![Helper checkValidDirectory:config.currentArea])
                {
                    // Need to check that the area does exist
                    config.currentArea = [Helper findFirstValidDirectory:@"Area"];
                }

            config.userLevel   = [[loginInfo valueForKey:@"level"] intValue];
            config.simpleToken = [loginInfo valueForKey:@"token"];
            config.userName    = [loginInfo valueForKey:@"code"];
            
            // DBaun - Wed, Nov 5, 2014.  Set these to NO because Hoang doesn't want sync over 3G per email.
            //cv - Mon Aug 2 2015 . Set these to yes do we can test AnyConnect
            config.syncImageOver3G = YES;
            config.syncOver3G = YES;
            
            [context save:nil];

            [RealPropertyApp setConfiguration:config];
        }



    - (void)updateKeychainWithLoginInfo:(NSDictionary *)loginInfo
                            andUserName:(NSString *)userName
        {
            // Update the keychain for next time
            [Keychain saveString:loginPassword.text forKey:@"PASSWORD"];
            [Keychain saveString:userName forKey:@"USERNAME"];
            [Keychain saveString:[loginInfo valueForKey:@"code"] forKey:@"CODE"];
            [Keychain saveString:[loginInfo valueForKey:@"level"] forKey:@"LEVEL"];
            [Keychain saveString:[loginInfo valueForKey:@"taxYear"] forKey:@"TAXYEAR"];
            [Keychain saveString:[loginInfo valueForKey:@"cyleStartDate"] forKey:@"CYCLESTARTDATE"];
            [Keychain saveString:[loginInfo valueForKey:@"saleStartDate"] forKey:@"SALESTARTDATE"];
            [Keychain saveString:[loginInfo valueForKey:@"token"] forKey:@"TOKEN"];
        }


#pragma mark - View lifecycle

    - (void)createButtonInView:(UIView *)inView
        {
            UIView *view = [inView viewWithTag:12];
            [view removeFromSuperview];

            UIImage *blueButtonImage = [UIImage imageNamed:@"btnBlue38.png"];
            btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
            btnLogin.frame = view.frame;
            UIImage *strechable = [blueButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            [btnLogin setBackgroundImage:strechable forState:UIControlStateNormal];
            [btnLogin setTitle:@"Login" forState:UIControlStateNormal];

            btnLogin.titleLabel.textColor = [UIColor whiteColor];

            [btnLogin addTarget:self action:@selector(performLogin:) forControlEvents:UIControlEventTouchUpInside];
            [inView addSubview:btnLogin];

        }



    - (void)viewDidLoad
        {

            [super viewDidLoad];
            [self registerForKeyboardNotifications:self withDelta:150];
            // Create and add the login button
            [self createButtonInView:self.view];

            NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
            NSString     *build      = [dictionary objectForKey:@"CFBundleVersion"];

            labelVersion.text = [NSString stringWithFormat:@"%@", build];

            loginPassword.delegate = self;
            loginName.delegate     = self;

            NSString *userName = [Keychain getStringForKey:@"USERNAME"];
            loginName.text = userName;


            errorMessage.text = @"";

            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];

            btnTestDrawing.hidden = YES;
#if TARGET_IPHONE_SIMULATOR
    btnTestDrawing.hidden = NO;
#endif
        }



    - (void)viewDidUnload
        {
            [self deregisterFromKeyboardNotifications];
            [[NSNotificationCenter defaultCenter] removeObserver:self];

            [self setLabelVersion:nil];
            [self setErrorMessage:nil];
            [self setLoginName:nil];
            [self setLoginPassword:nil];
            [self setLoginName:nil];
            [self setLoginPassword:nil];
            [self setErrorMessage:nil];
            [self setBtnLogin:nil];

            [self setLabelVersion:nil];
            [self setDescriptionText:nil];
            [self setBackgroundPict:nil];
            [self setComments:nil];
            [self setBtnTestDrawing:nil];
            [super viewDidUnload];
        }



    - (void)textFieldDidBeginEditing:(UITextField *)textField
        {
            [super textFieldDidBeginEditing:textField];
            errorMessage.text = @"";
        }



    - (BOOL)textFieldShouldReturn:(UITextField *)textField
        {
            [self performLogin:textField];
            return YES;
        }


#pragma mark - rotate the interface


    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
                {
                    backgroundPict.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
                    backgroundPict.frame = CGRectMake(0, 0, 1024, 748);
                    labelVersion.center  = CGPointMake(512, 382);
                    loginName.center     = CGPointMake(512, 416);
                    loginPassword.center = CGPointMake(512, 462);
                    errorMessage.center  = CGPointMake(512, 506);
                    btnLogin.center      = CGPointMake(512, 545);
                    comments.center      = CGPointMake(518, 618);
                }
            else
                {
                    backgroundPict.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
                    backgroundPict.frame = CGRectMake(0, 0, 768, 1004);
                    labelVersion.center  = CGPointMake(384, 466);
                    loginName.center     = CGPointMake(384, 500);
                    loginPassword.center = CGPointMake(384, 546);
                    errorMessage.center  = CGPointMake(384, 590);
                    btnLogin.center      = CGPointMake(384, 630);
                    comments.center      = CGPointMake(384, 718);
                }
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
        {
            return YES;
        }
@end
