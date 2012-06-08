#import <Preferences/Preferences.h>
@interface DontForgetListController: PSListController{}
@end
@implementation DontForgetListController
-(id)specifiers{
    if(_specifiers==nil){
	_specifiers=[[self loadSpecifiersFromPlistName:@"DontForget" target:self]retain];
    }
    return _specifiers;
}
-(void)viewDidAppear{
    if(![[[UIDevice currentDevice]model]isEqualToString:@"iPhone"]){
	[self removeSpecifier:[[self specifiers]objectAtIndex:5]animated:NO];
    }
}
-(void)dftwitter:(id)param{
    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"tweetbot:"]]){
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tweetbot://user_profile/thekirbylover"]];
    }else if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"tweetings:"]]){
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=thekirbylover"]];
    }else if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"twitter:"]]){
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"twitter://user?screen_name=thekirbylover"]];
    }else{
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://twitter.com/thekirbylover"]];
    }	   
}
-(void)dfglyphish:(id)param{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://glyphish.com"]];
}
@end
