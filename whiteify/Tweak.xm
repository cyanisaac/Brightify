/*
Tweak file for
*/

@interface UIColor (GLUEHex)
+ (UIColor*)glue_colorFromHexString:(NSString*)arg1 alpha:(double)arg2;
@end

#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.cyantycdev.whiteify.bundle"

static NSDictionary* colorOverrideDictionary;

%ctor {
  NSBundle* tweakBundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];
  colorOverrideDictionary = [[NSDictionary alloc] initWithContentsOfFile:[tweakBundle pathForResource:@"ColorOverrides" ofType:@"plist"]];
}

%hook SPTTheme
-(UIColor*)resolveColorForKey:(NSString*)arg1 {
  NSString* possibleColorString = [colorOverrideDictionary objectForKey:arg1];
  if(possibleColorString != nil) {
    return [UIColor glue_colorFromHexString:possibleColorString alpha:1.0];
  } else {
    return %orig;
  }
}
%end
