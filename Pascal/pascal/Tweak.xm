#import <AVFoundation/AVAudioSession.h>
#import "Bits.h"


#define kNoctisAppID 			CFSTR("com.laughingquoll.noctis")
#define kNoctisEnabledKey 		CFSTR("LQDDarkModeEnabled")
static BOOL isNoctisOn();
static BOOL isNoctisOn() {
    BOOL on = NO;
    CFPreferencesAppSynchronize(kNoctisAppID);
    Boolean valid = NO;
    BOOL value = CFPreferencesGetAppBooleanValue(kNoctisEnabledKey, kNoctisAppID, &valid);

    if(valid) {
        on = value;
    } return on;
}


UIBlurEffect *blurEffect;
CGFloat volume;
%hook SBHUDView
-(void) layoutSubviews {
    %orig;
   for(UIView *subviews in self.subviews) {
        [subviews removeFromSuperview];
    }
    [self setUserInteractionEnabled:NO];

    volume = [[AVAudioSession sharedInstance] outputVolume];


        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [progressView setFrame:CGRectMake(12, (self.bounds.size.height / 2) - 1, self.bounds.size.width - 24, 2)];
     [progressView setProgress:self.progress animated:NO];
    [progressView setClipsToBounds:YES];
    [progressView.layer setCornerRadius:1];
    [progressView setTransform: CGAffineTransformMakeScale(1.0, 1.2)];
    [self addSubview:progressView];


    if(isNoctisOn()) {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

        [progressView setProgressTintColor:[UIColor whiteColor]];
        [progressView setTrackTintColor:[UIColor colorWithWhite:1.0 alpha:0.16]];
    } else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

        [progressView setProgressTintColor:[UIColor blackColor]];
        [progressView setTrackTintColor:[UIColor colorWithWhite:0.0 alpha:0.16]];
    }


    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.bounds];
    [self createMaskForView:blurEffectView byRoundingCorners:UIRectCornerAllCorners cornerRadii:5];
    [self addSubview:blurEffectView];
    [self sendSubviewToBack:blurEffectView];
}


%new
-(void) createMaskForView:(UIView *)view byRoundingCorners:(UIRectCorner)corners cornerRadii:(double)radius {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];

    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setPath:path.CGPath];
    [view.layer setMask:mask];
}
%end


%hook SBHUDController
-(void)_recenterHUDView {
    %orig;
    SBHUDView *hudView = [self valueForKey:@"_hudView"];

    CGRect oldFrame = hudView.frame;
    oldFrame.origin.x = ([[UIScreen mainScreen] bounds].size.width / 2) - 64;
    oldFrame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height + 8;
    oldFrame.size.width = 128;
    oldFrame.size.height = 20;
    [hudView setFrame:oldFrame];
}

-(void) presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2 {
    %orig(arg1, arg2 + 0.025);
}
%end