#include "BTFYRootListController.h"
#include <Preferences/PSSpecifier.h>

@implementation BTFYRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
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

-(void)killSpotify {
	system("killall -9 Spotify");
}

@end
