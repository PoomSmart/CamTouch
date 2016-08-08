#import "../PS.h"
#import <substrate.h>

@interface BSCFBundle : NSBundle
- (NSString *)bundleIdentifier;
@end

// iOS 9
@interface NSDictionary (SBS)
- (id)sbs_safeObjectForKey:(NSString *)key ofType:(Class)type;
@end

@interface NSMutableDictionary (SBS)
- (void)sbs_setSafeObject:(id)object forKey:(NSString *)key;
@end

@interface SBSApplicationShortcutItem : NSObject
@property(nonatomic, copy) NSString *localizedTitle;
@end

@interface SBApplication : NSObject
@property(copy, nonatomic) NSArray *staticShortcutItems;
@end

// iOS 10
@interface NSDictionary (BS)
- (id)bs_safeObjectForKey:(NSString *)key ofType:(Class)type;
@end

@interface NSMutableDictionary (BS)
- (void)bs_setSafeObject:(id)object forKey:(NSString *)key;
@end

NSDictionary *modifyInfo(NSDictionary *info)
{
	NSMutableDictionary *minfo = [info.mutableCopy autorelease];
	NSArray *items = isiOS92Up ? [minfo bs_safeObjectForKey:@"UIApplicationShortcutItems" ofType:[NSArray class]] :
								[minfo sbs_safeObjectForKey:@"UIApplicationShortcutItems" ofType:[NSArray class]];
	NSMutableArray *mitems = [items.mutableCopy autorelease];
	[mitems addObject:@{
		@"UIApplicationShortcutItemIconFile" : @"TakePhoto-OrbHW",
		@"UIApplicationShortcutItemTitle" : @"Take Panorama",
		@"UIApplicationShortcutItemType" : @"com.apple.camera.shortcuts.pano",
		@"UIApplicationShortcutItemUserInfo" : @{
			@"CAMCaptureDevice" : @0,
			@"CAMCaptureMode" : @3
		}
	}];
	[mitems addObject:@{
		@"UIApplicationShortcutItemIconFile" : @"RecordVideo-OrbHW",
		@"UIApplicationShortcutItemTitle" : @"Record Time-Lapse",
		@"UIApplicationShortcutItemType" : @"com.apple.camera.shortcuts.lapse",
		@"UIApplicationShortcutItemUserInfo" : @{
			@"CAMCaptureDevice" : @0,
			@"CAMCaptureMode" : @6
		}
	}];
	isiOS92Up ? [minfo bs_setSafeObject:mitems forKey:@"UIApplicationShortcutItems"] :
		[minfo sbs_setSafeObject:mitems forKey:@"UIApplicationShortcutItems"];
	return minfo;
}

%group iOS10

%hook SBApplicationInfo

- (NSMutableArray *)_parseStaticApplicationShortcutItemsFromInfoDictionary:(NSDictionary *)info bundle:(BSCFBundle *)bundle
{
	return %orig([bundle.bundleIdentifier isEqualToString:@"com.apple.camera"] ? modifyInfo(info) : info, bundle);
}

%end

%end

%group iOS92Up

%hook SBApplicationInfo

- (NSMutableArray <SBSApplicationShortcutItem *> *)_parseStaticShortcutItemsFromInfoDictionary:(NSDictionary *)info bundle:(BSCFBundle *)bundle
{
	if ([bundle.bundleIdentifier isEqualToString:@"com.apple.camera"]) {
		NSMutableArray *array = %orig(modifyInfo(info), bundle);
		for (SBSApplicationShortcutItem *item in array)
			item.localizedTitle = [bundle localizedStringForKey:item.localizedTitle value:nil table:@"InfoPlist-OrbHW2"];
		return array;
	}
	return %orig;
}

%end

%end

%group preiOS92

%hook SBApplication

- (void)loadStaticShortcutItemsFromInfoDictionary:(NSDictionary *)info bundle:(BSCFBundle *)bundle
{
	if ([bundle.bundleIdentifier isEqualToString:@"com.apple.camera"]) {
		%orig(modifyInfo(info), bundle);
		for (SBSApplicationShortcutItem *item in self.staticShortcutItems)
			item.localizedTitle = [bundle localizedStringForKey:item.localizedTitle value:nil table:@"InfoPlist-OrbHW2"];
	} else
		%orig;
}

%end

%end

%ctor
{
	dlopen("/Library/MobileSubstrate/DynamicLibraries/UnlimShortcut.dylib", RTLD_LAZY);
	if (isiOS92Up) {
		if (isiOS10Up) {
			%init(iOS10);
		}
		%init(iOS92Up);
	} else {
		%init(preiOS92);
	}
}