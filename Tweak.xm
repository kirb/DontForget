#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreFoundation/CFNotificationCenter.h>

@interface SBTelephonyManager (Airplane)
-(BOOL)isInAirplaneMode;
-(void)setIsInAirplaneMode:(BOOL)state;
@end

#if DEBUG
	#define ADDFLog(...) NSLog(@"[DontForget] %s:%d: %@",__FILE__,__LINE__,[NSString stringWithFormat:__VA_ARGS__]);
#else
	#define ADDFLog(...)
#endif
#define prefpath @"/var/mobile/Library/Preferences/net.thekirbylover.dontforget.plist"
#define warnpath @"/System/Library/Audio/UISounds/low_power.caf"
static BOOL gotAlert=NO;
static unsigned int warnAt=2;
static UIAlertView *plugAlert;
static BOOL pluggedIn=NO;
static BOOL shouldVibe=YES;
static BOOL shouldBeep=YES;
static BOOL shouldPlane=YES;
static BOOL hadPlane=NO;
static void ADDFPrefsLoad();
static BOOL firstRun=NO;
static NSDictionary *prefs;
static BOOL saidHi=NO;

%hook SBLowPowerAlertItem
+(void)setBatteryLevel:(unsigned int)fp8{
	if(fp8<=warnAt&&!pluggedIn&&!gotAlert){
		plugAlert=[[UIAlertView alloc]init];
		[plugAlert setTitle:[[NSBundle mainBundle]localizedStringForKey:@"LOW_BATTERY_TITLE" value:@"Low Battery" table:@"SpringBoard"]];
		[plugAlert setMessage:[NSString stringWithFormat:[[NSBundle mainBundle]localizedStringForKey:@"LOW_BATTERY_MSG_LEVEL" value:@"%@ of battery remaining" table:@"SpringBoard"],[NSString stringWithFormat:@"%u%%",warnAt]]];
		#if DEBUG
		[plugAlert addButtonWithTitle:@"Dismiss"];
		#endif
		[plugAlert show];
		if(shouldBeep){
			SystemSoundID lowSnd;
			AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:warnpath isDirectory:NO],&lowSnd);
			AudioServicesPlaySystemSound(lowSnd);
			lowSnd=NULL;
		}
		if(shouldVibe){
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
		if(shouldPlane){
			hadPlane=[[%c(SBTelephonyManager) sharedTelephonyManager]isInAirplaneMode];
			[[%c(SBTelephonyManager) sharedTelephonyManager]setIsInAirplaneMode:YES];
		}
		gotAlert=YES;
	}
	%orig;
}
%end
%hook SBUIController
-(BOOL)isOnAC{
	pluggedIn=%orig;
	if(pluggedIn&&gotAlert){
		[plugAlert dismissWithClickedButtonIndex:0 animated:YES];
		[plugAlert release];
		if(shouldPlane&&!hadPlane){
			[[%c(SBTelephonyManager) sharedTelephonyManager]setIsInAirplaneMode:NO];
		}
		gotAlert=NO;
	}
	return pluggedIn;
}
%end

static void ADDFPrefsLoad(){
	if([[NSFileManager defaultManager]fileExistsAtPath:prefpath]){
		prefs=[[NSDictionary alloc]initWithContentsOfFile:prefpath];
		warnAt=[[prefs objectForKey:@"Percent"]intValue];
		shouldVibe=[[prefs objectForKey:@"Vibrate"]boolValue];
		shouldBeep=[[prefs objectForKey:@"Sound"]boolValue];
		shouldPlane=[[prefs objectForKey:@"Airplane"]boolValue];
		if(!warnAt) warnAt=2;
		else if(warnAt>10) warnAt=10;
		if(![prefs objectForKey:@"Vibrate"]) shouldVibe=YES;
		if(![prefs objectForKey:@"Sound"]) shouldBeep=YES;
		if(![prefs objectForKey:@"Airplane"]) shouldPlane=YES;
		#if DEBUG
		warnAt=100;
		#endif
	}else{
		firstRun=YES;
		prefs=[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:2],@"Percent",[NSNumber numberWithBool:YES],@"Sound",[NSNumber numberWithBool:YES],@"Vibrate",[NSNumber numberWithBool:YES],@"Airplane",nil];
		[prefs writeToFile:prefpath atomically:YES];
	}
}
static void ADDFPrefsUpdate(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo){
	ADDFPrefsLoad();
}
@interface ADDontForget : NSObject <UIAlertViewDelegate>{
}
+(BOOL)showWelcomeMessageIfNecessary;
@end
@implementation ADDontForget
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Go There!"]){
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"prefs:root=DontForget"]];
	}
}
+(BOOL)showWelcomeMessageIfNecessary{
	#if DEBUG
	if(saidHi){
	#else
	if(!firstRun||saidHi){
	#endif
		return NO;
	}
	saidHi=YES;
	UIAlertView *welcmsg=[[UIAlertView alloc]initWithTitle:@"Thanks for installing DontForget!" message:@"You will now be reminded when your battery reaches 2%.\nYou can change this in the Settings app. Would you like to open the settings?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Go There!"];
	[welcmsg show];
	[welcmsg release];
	return YES;
}
@end

/*disabled for now...
%hook SBIconController
-(void)showInfoAlertIfNeeded{
	if(![ADDontForget showWelcomeMessageIfNecessary]){
		%orig;
	}
}
%end
%hook AAAccountManager
-(void)showMobileMeOfferIfNecessary{
	if(![ADDontForget showWelcomeMessageIfNecessary]){
		%orig;
	}
}
%end*/

%ctor{
	NSAutoreleasePool *p=[[NSAutoreleasePool alloc]init];
	ADDFPrefsLoad();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),NULL,&ADDFPrefsUpdate,CFSTR("net.thekirbylover.dontforget/ReloadPrefs"),NULL,0);
	%init;
	[p drain];
}
