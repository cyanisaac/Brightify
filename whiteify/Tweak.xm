/*
Tweak file for Whiteify, containing recolouring logic.
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

@interface SPTTheme
- resolveColorForKey:(NSString*)arg1;
@end

#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.cyantycdev.whiteify.bundle"

static NSDictionary* colorOverrideDictionary;
static NSDictionary* defaultColorsDictionary;
static float currentColorAlpha;

%ctor {
  NSBundle* tweakBundle = [[NSBundle alloc] initWithPath:kBundlePath];
  colorOverrideDictionary = [[NSDictionary alloc] initWithContentsOfFile:[tweakBundle pathForResource:@"ColorOverrides" ofType:@"plist"]];
}

%hook SPTTheme

-(UIColor*)resolveColorForKey:(NSString*)arg1 {

  if(defaultColorsDictionary == nil) {
    NSBundle* spotifyBundle = [NSBundle mainBundle];
    NSString* pathForResource = [spotifyBundle pathForResource:@"Theme" ofType:@"plist"];
    NSDictionary* spotifyThemeDict = [NSDictionary dictionaryWithContentsOfFile:pathForResource];
    NSDictionary* spotifyColorsDict = [NSDictionary dictionaryWithDictionary:[spotifyThemeDict objectForKey:@"colors"]];
    defaultColorsDictionary = spotifyColorsDict;
  }

  // Thanks Spotify for the fucking awful plist with tons of different ways of
  // storing color values, now I have to go complicate my tweak to deal with it.
  NSString* possibleColorString = [colorOverrideDictionary objectForKey:arg1];
  if(possibleColorString != nil) {
    float foundAlpha = currentColorAlpha;
    currentColorAlpha = 1.0;
    return [UIColor glue_colorFromHexString:possibleColorString alpha:foundAlpha]; // Fix alpha issue later.
  } else {
    // Later iPad colors should be supported, for now, we only use iPhone colors.
    // Apologies to iPad users, I don't have a device for testing and don't care
    // to implement it but if someone else wants to they can go ahead.

    NSDictionary* possibleRecursiveColorDict = [defaultColorsDictionary objectForKey:arg1];
    if(possibleRecursiveColorDict != nil) {
      NSString* foundColorString;

      id recursiveColorValue = [possibleRecursiveColorDict objectForKey:@""];
      if ([recursiveColorValue isKindOfClass:[NSString class]]) {
        foundColorString = [[NSString alloc] initWithString:recursiveColorValue];
      } else if ([recursiveColorValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary* colorWithAlphaDict = [NSDictionary dictionaryWithDictionary:recursiveColorValue];
        NSNumber* foundAlphaInDictionary = [colorWithAlphaDict objectForKey:@"alpha"];
        if(foundAlphaInDictionary == nil) {
          currentColorAlpha = 1.0;
        } else {
          currentColorAlpha = [foundAlphaInDictionary floatValue];
          
        }
        if ([colorWithAlphaDict objectForKey:@"rgb"] != nil) {
          float foundAlpha = currentColorAlpha;
          currentColorAlpha = 1.0;
          return [UIColor glue_colorFromHexString:possibleColorString alpha:foundAlpha]; // Fix alpha later.
        } else if ([colorWithAlphaDict objectForKey:@"base"] != nil) {
          foundColorString = [[NSString alloc] initWithString:[colorWithAlphaDict objectForKey:@"base"]];
        } else {
          return %orig;
        }
      } else {
        return %orig;
      }

      if([defaultColorsDictionary objectForKey:foundColorString] != nil) {
        UIColor* resolvedColor = [self resolveColorForKey:foundColorString];
        // this next line causes the problem
        if(resolvedColor == nil) {
          return %orig;
        }
        return resolvedColor;
      } else {
        return %orig;
      }
    } else {
      return %orig;
    }
    return %orig;
  }
}

%end
