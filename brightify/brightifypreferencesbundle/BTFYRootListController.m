/*
List controller for BrightifyPreferences
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

#include "BTFYRootListController.h"
#include <Preferences/PSSpecifier.h>

#define kPrefsPlistPath @"/var/mobile/Library/Preferences/com.cyanisaac.brightify.plist"

@implementation BTFYRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	if (!settings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return settings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kPrefsPlistPath]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:kPrefsPlistPath atomically:YES];

	CFStringRef notificationValue = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationValue) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationValue, NULL, NULL, YES);
	}
}

- (id)tableView:(id)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		// add table header
		UIImage *logoImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BrightifyPreferencesBundle.bundle/header.png"];
		UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 120.0)];
		logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		logoView.image = logoImage;
		UIView *headerView = [[UIView alloc] initWithFrame:logoView.frame];
		headerView.backgroundColor = [UIColor whiteColor];
		[headerView addSubview:logoView];
		return headerView;
	} else {
		return [super tableView:tableView viewForHeaderInSection:section];
	}
}

- (CGFloat)tableView:(id)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 120.0;
	} else {
		return [super tableView:tableView heightForHeaderInSection:section];
	}
}

-(void)safariTwitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/cyanisaac"]];
}

-(void)safariRepository {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/cyanisaac/Brightify"]];
}

-(void)safariDonation {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/cyanisaac"]];
}

-(void)killSpotify {
	system("killall -9 Spotify");
}

@end
