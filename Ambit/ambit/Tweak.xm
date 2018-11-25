@interface SBReachabilityManager : NSObject
-(void)_handleReachabilityActivated;
-(void)_handleReachabilityDeactivated; // hmm
@end

@interface UIKeyboard : UIView
+(id) activeKeyboard;
-(void) minimize;
@end


%hook SBReachabilityManager
-(void)_handleReachabilityActivated {
    %orig;
    [[UIKeyboard activeKeyboard] minimize];
}
%end