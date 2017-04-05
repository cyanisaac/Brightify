/*
Tweak file for Brightify, containing recolouring logic and minor UI hooks/fixes.
Copyright (c) 2017 Isaac Trimble-Pederson, All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

@interface UIColor (GLUEHex)
+ (UIColor*)glue_colorFromHexString:(NSString*)arg1 alpha:(double)arg2;

@end

@interface SPDarkNavigationBar : UINavigationBar
@end

@interface SPTTheme
- resolveColorForKey:(NSString*)arg1;
@end

@interface SPTPopupWindow: UIWindow
+ (instancetype)new;
@end

@interface SPTPopupManager: NSObject
@property(retain, nonatomic) SPTPopupWindow *window;
@end

@interface MessageBarController: UIViewController
@end

@interface SPTCeramicCompactGridCollectionViewCell: UIView
@property(readonly, nonatomic) UILabel *titleLabel;
@end

@interface GLUEHeaderView
@property(readonly, nonatomic) CAGradientLayer *collapsedShadowLayer;
@end

#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.cyanisaac.brightify.bundle"
#define kNoctisAppID CFSTR("com.laughingquoll.noctis")
#define kNoctisEnabledKey CFSTR("LQDDarkModeEnabled")

static NSDictionary* colorOverrideDictionary;
static NSDictionary* defaultColorsDictionary;
static BOOL killswitch = NO;
static BOOL listenToNoctis = YES;
static BOOL isNoctisInstalled = NO;
static BOOL isNoctisActive = NO;

@interface BTFYReturnValuePair: NSObject
@property(nonatomic) NSString* hexColorString;
@property(nonatomic) NSNumber* alpha;
-(id)initWithColorString:(NSString*)hexColorString alpha:(NSNumber*)alpha;
@end

@implementation BTFYReturnValuePair
-(id)initWithColorString:(NSString*)hexColorString alpha:(NSNumber*)alpha {
  self = [super init];
  self.hexColorString = hexColorString;
  self.alpha = alpha;

  return self;
}
@end

@interface BTFYMethods: NSObject
+(BTFYReturnValuePair*)getValuesForKey:(NSString*)colorKey;
+(void)updateNoctis;
+(void)updateKillswitch;
+(BOOL)doColorSpotify;
@end

@implementation BTFYMethods

+(BTFYReturnValuePair*)getValuesForKey:(NSString*)colorKey {
  NSString* foundHexColor;
  NSString* workingColorKey = colorKey;
  NSMutableArray* foundAlphaValues = [[NSMutableArray alloc] init];
  while(foundHexColor == nil) {
    if([colorOverrideDictionary objectForKey:workingColorKey]) {
      foundHexColor = [colorOverrideDictionary objectForKey:workingColorKey];
    }
    NSDictionary* dictForColor = [defaultColorsDictionary objectForKey:workingColorKey];
    if(dictForColor != nil) {
      id foundColorValue;
      if([dictForColor objectForKey:@"ipad"] != nil && [BTFYMethods isiPad]) {
        /*
        Obligatory: iPad is NOT tested - this *should* make it work on iPad, but
        I have no iPad (let alone jailbroken) to test.
        */
        foundColorValue = [dictForColor objectForKey:@"ipad"];
      } else {
        foundColorValue = [dictForColor objectForKey:@""];
      }
      if ([foundColorValue isKindOfClass:[NSString class]]) {
        NSString* foundColorString = foundColorValue;
        if([defaultColorsDictionary objectForKey:foundColorString] != nil) {
          workingColorKey = foundColorString;
        } else {
          if(foundHexColor == nil) {
            foundHexColor = foundColorString;
          }
        }
      } else if([foundColorValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary* foundColorDictionary = foundColorValue;
        if([foundColorDictionary objectForKey:@"rgb"] != nil) {
          if(foundHexColor == nil) {
            foundHexColor = [foundColorDictionary objectForKey:@"rgb"];
          }
        } else if([foundColorDictionary objectForKey:@"base"] != nil) {
          workingColorKey = [foundColorDictionary objectForKey:@"base"];
        }
        if([foundColorDictionary objectForKey:@"alpha"] != nil) {
          [foundAlphaValues addObject:[foundColorDictionary objectForKey:@"alpha"]];
        }
      } else {
        // fuck you iPad
        break;
      }
    } else {
      // Spotify looking for nonexistent colors, maybe?
      break;
    }
  }

  // Handle eight character hex color shit
  // Why didn't Spotify keep this in Android?
  NSNumber* finalAlpha;
  if([foundHexColor length] == 8) {
    float maybeAlpha;
    NSString* foundAlphaHexString = [foundHexColor substringToIndex:2];
    foundHexColor = [foundHexColor substringFromIndex:2];

    NSScanner* alphaHexScanner = [NSScanner scannerWithString:foundAlphaHexString];
    BOOL didSuccessfullyScan = [alphaHexScanner scanHexFloat:&maybeAlpha];
    if(didSuccessfullyScan) {
      finalAlpha = [NSNumber numberWithFloat:maybeAlpha];
    } else {
      finalAlpha = [NSNumber numberWithFloat:1.0]; // Fix if something goes wrong.
    }
  } else {
    if([foundAlphaValues lastObject] != nil) {
      finalAlpha = [foundAlphaValues lastObject];
    } else {
      finalAlpha = [NSNumber numberWithFloat:1.0];
    }
  }

  BTFYReturnValuePair* valuePair = [[BTFYReturnValuePair alloc] initWithColorString:foundHexColor alpha:finalAlpha];
  if(valuePair.hexColorString != nil && valuePair.alpha != nil) {
    return valuePair;
  } else {
    return nil;
  }
}

+(void)updateNoctis {
  if(isNoctisInstalled) {
    NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.cyanisaac.brightify.plist"];
    if(prefs != nil) {
      if([prefs objectForKey:@"listenToNoctis"] != nil) {
        listenToNoctis = [[prefs objectForKey:@"listenToNoctis"] boolValue];
      } else {
        listenToNoctis = YES;
      }
    } else {
      listenToNoctis = YES;
    }

    if(listenToNoctis) {
      CFPreferencesAppSynchronize(kNoctisAppID);
      Boolean valid = NO;
      BOOL noctisEnabled = CFPreferencesGetAppBooleanValue(kNoctisEnabledKey, kNoctisAppID, &valid);
      if (valid) {
        isNoctisActive = noctisEnabled;
      }
    } else {
      isNoctisActive = NO;
    }
  } else {
    isNoctisActive = NO;
  }
}

+(void)updateKillswitch {
   NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.cyanisaac.brightify.plist"];
   if(prefs != nil) {
     if([prefs objectForKey:@"enabled"] != nil) {
       killswitch = ![[prefs objectForKey:@"enabled"] boolValue];
     } else {
       killswitch = NO;
     }
   } else {
     killswitch = NO;
   }
}

+(BOOL)doColorSpotify {
  if(killswitch == NO && isNoctisActive == NO) {
    return YES;
  } else {
    return NO;
  }
}

// iPad is NOT supported; I cannot test if this code will work.
// This might work and might not. No way to test. I don't have an iPad.
// -isaac
+(BOOL)isiPad {
  if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
    return YES;
  } else {
    return NO;
  }
}

@end

static void killSpotify() {
	exit(0);
}

static void killSpotifyForNoctis() {
  if(listenToNoctis) {
    exit(0);
  }
}

%ctor {
  NSBundle* tweakBundle = [[NSBundle alloc] initWithPath:kBundlePath];
  colorOverrideDictionary = [[NSDictionary alloc] initWithContentsOfFile:[tweakBundle pathForResource:@"ColorOverrides" ofType:@"plist"]];

  // Noctis support, thanks to Sticktron's DarkMessages for giving an example on
  // how to do this :).
  if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis.dylib"]) {
    isNoctisInstalled = YES;

    [[NSNotificationCenter defaultCenter]
      addObserverForName:@"com.laughingquoll.noctis.enablenotification"
      object:nil
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *note) {
        killSpotifyForNoctis();
      }];

    [[NSNotificationCenter defaultCenter]
      addObserverForName:@"com.laughingquoll.noctis.disablenotification"
      object:nil
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *note) {
        killSpotifyForNoctis();
      }];
  }

  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)killSpotify, CFSTR("com.cyanisaac.brightify.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

  [BTFYMethods updateNoctis];
  [BTFYMethods updateKillswitch];
}

%hook SPTTheme

-(UIColor*)resolveColorForKey:(NSString*)arg1 {
  if([BTFYMethods doColorSpotify]) {
    if(defaultColorsDictionary == nil) {
      NSBundle* spotifyBundle = [NSBundle mainBundle];
      NSString* pathForResource = [spotifyBundle pathForResource:@"Theme" ofType:@"plist"];
      NSDictionary* spotifyThemeDict = [NSDictionary dictionaryWithContentsOfFile:pathForResource];
      NSDictionary* spotifyColorsDict = [NSDictionary dictionaryWithDictionary:[spotifyThemeDict objectForKey:@"colors"]];
      defaultColorsDictionary = spotifyColorsDict;
    }

    BTFYReturnValuePair* values = [BTFYMethods getValuesForKey:arg1];
    if(values != nil) {
      return [UIColor glue_colorFromHexString:values.hexColorString alpha:[values.alpha floatValue]];
    }
  }

  return %orig;
}

%end

%hook UIBlurEffect

+(id)effectWithStyle:(long long)arg1 {
  if([BTFYMethods doColorSpotify]) {
    return %orig(UIBlurEffectStyleLight);
  } else {
    return %orig;
  }
}

%end

%hook UIApplication

-(void)setStatusBarStyle:(long long)arg1 {
  if([BTFYMethods doColorSpotify]) {
    %orig(UIStatusBarStyleDefault);
  } else {
    %orig;
  }
}

%end

%hook SpotifyAppDelegate

-(BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
  [BTFYMethods updateKillswitch];
  if(isNoctisInstalled) {
    [BTFYMethods updateNoctis];
  }

  return %orig;
}

%end

%hook SPTPopupManager
// Hacky fix for blue window, since I can't figure out what's causing it.
// I'll also add a nice blur view to complement it :).

- (void)loadWindow {
  if([BTFYMethods doColorSpotify]) {
    // Get original
    SPTPopupWindow* originalWindow = [%c(SPTPopupWindow) new];
    [originalWindow setBackgroundColor:[UIColor clearColor]];

    // Add blur view.
    UIVisualEffectView* backgroundBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]; // Dark blurs will be overridden in light mode, so this works.
    [backgroundBlurView setFrame:CGRectMake(originalWindow.frame.origin.x, originalWindow.frame.origin.y, originalWindow.frame.size.width, originalWindow.frame.size.height)];
    [originalWindow addSubview: backgroundBlurView];

    self.window = originalWindow;
  } else {
    return %orig;
  }
}

%end

%hook MessageBarController

-(id)init {
  [BTFYMethods updateNoctis];
  [BTFYMethods updateKillswitch];

  if([BTFYMethods doColorSpotify]) {
    MessageBarController* originalMessageBarController = %orig;
    [originalMessageBarController.view setBackgroundColor:[UIColor whiteColor]];
    return originalMessageBarController;
  } else {
    return %orig;
  }
}

%end

%hook SPTCeramicCompactGridCollectionViewCell

-(id)initWithFrame:(CGRect)arg1 {
  if([BTFYMethods doColorSpotify]) {
    SPTCeramicCompactGridCollectionViewCell* workingCell = %orig(arg1);
    [workingCell.titleLabel setTextColor:[UIColor whiteColor]];
    return workingCell;
  } else {
    return %orig;
  }
}

%end

%hook GLUEHeaderView

/*
+(id)new {
  if([BTFYMethods doColorSpotify]) {
    GLUEHeaderView* workingHeaderView = %orig;
    NSArray* newColors = @[[UIColor whiteColor], [UIColor clearColor]];
    [[workingHeaderView collapsedShadowLayer] setColors:newColors];
    return workingHeaderView;
  } else {
    return %orig;
  }
}
*/

-(CAGradientLayer*)collapsedShadowLayer {
  if([BTFYMethods doColorSpotify]) {
    CAGradientLayer* workingShadowLayer = %orig;
    NSArray* newColors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor]; // This line is shit but it works I guess.
    [workingShadowLayer setColors:newColors];
    return workingShadowLayer;
  } else {
    return %orig;
  }
}

%end
