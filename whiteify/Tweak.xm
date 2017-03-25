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
