#import "Bits.h"
#import "Files/ScrollyLabel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MediaRemote/MediaRemote.h>


UIWindow *window;
UISlider *progressView;

NSTimer *timer;
UIImageView *mainImageView, *blurImageView;
MPMusicPlayerController *player;

ScrollyLabel *songTitle, *artistName, *remainingLabel;
UIButton *playPauseButton, *minimizeButton;
CGFloat windowHeight = 144;
int newY;

%hook SpringBoard
-(void) applicationDidFinishLaunching:(id)arg1 {
    %orig;
    player = [MPMusicPlayerController systemMusicPlayer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMedia) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMedia) name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];


    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateMedia) userInfo:nil repeats:YES];


    window = [[UIWindow alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 16, [[UIApplication sharedApplication] statusBarFrame].size.height + 16, [[UIScreen mainScreen] bounds].size.width - 32, 144)];
    [window setBackgroundColor:[UIColor clearColor]];
    [window setClipsToBounds:YES];
    [self setMaskToView:window byRoundingCorners:UIRectCornerAllCorners cornerRadii:12];
    [window setWindowLevel:UIWindowLevelStatusBar];
    [window makeKeyAndVisible];


    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [window addGestureRecognizer:pan];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [window addGestureRecognizer:tap];


    minimizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [minimizeButton setFrame:CGRectMake(window.bounds.size.width - 45, 16, 29, 29)];
    [minimizeButton addTarget:self action:@selector(minimize:) forControlEvents:UIControlEventTouchUpInside];
    [minimizeButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [minimizeButton setTintColor:[UIColor blackColor]];
    [minimizeButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/minimize.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [window addSubview:minimizeButton];


    _UIBackdropView *blurView = [[_UIBackdropView alloc] initWithStyle:2010];
    [blurView setBlurRadius:30];
    [blurView setBlurQuality:@"default"];
    [blurView setFrame:window.bounds];
    [window addSubview:blurView];
    [window sendSubviewToBack:blurView];


    mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 56, 56)];
    [mainImageView setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/music@2x.png"]];
    [mainImageView setClipsToBounds:YES];
    [self setMaskToView:mainImageView byRoundingCorners:UIRectCornerAllCorners cornerRadii:10];
    [window addSubview:mainImageView];

    blurImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, window.bounds.size.width, windowHeight)];
    [blurImageView setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/music@2x.png"]];
    [blurImageView setClipsToBounds:YES];
    [self setMaskToView:blurImageView byRoundingCorners:UIRectCornerAllCorners cornerRadii:10];
    [window addSubview:blurImageView];
    [window insertSubview:blurImageView belowSubview:blurView];


    songTitle = [[ScrollyLabel alloc] initWithFrame:CGRectMake(88, 16, window.bounds.size.width - 149, 26)];
    [songTitle setText:@"iPhone"];
    [songTitle setTextAlignment:NSTextAlignmentLeft];
    [songTitle setFont:[UIFont systemFontOfSize:21 weight:UIFontWeightHeavy]];
    [songTitle setTextColor:[UIColor blackColor]];
    [songTitle setLabelSpacing:50];
    [songTitle setPauseInterval:2];
    [songTitle setScrollSpeed:10];
    [songTitle setFadeLength:2];
    [songTitle setScrollDirection:ScrollyLabelDirectionLeft];
    [window addSubview:songTitle];

    artistName = [[ScrollyLabel alloc] initWithFrame:CGRectMake(88, 34, window.bounds.size.width - 149, 26)];
    [artistName setText:@"Music"];
    [artistName setTextAlignment:NSTextAlignmentLeft];
    [artistName setFont:[UIFont boldSystemFontOfSize:14]];
    [artistName setTextColor:[UIColor grayColor]];
    [artistName setLabelSpacing:50];
    [artistName setPauseInterval:2];
    [artistName setScrollSpeed:12];
    [artistName setFadeLength:1];
    [artistName setScrollDirection:ScrollyLabelDirectionLeft];
    [window addSubview:artistName];


    progressView = [[UISlider alloc] initWithFrame:CGRectMake(88, 64, window.bounds.size.width - 160, 5)];
    [progressView setMinimumTrackTintColor:[UIColor blackColor]];
    [progressView setMaximumTrackTintColor:[UIColor colorWithWhite:0.0 alpha:0.08]];
    [progressView setThumbImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/thumb.png"] forState:UIControlStateNormal];
    [progressView addTarget:self action:@selector(playback:) forControlEvents:UIControlEventValueChanged];
    [window addSubview:progressView];


    remainingLabel = [[ScrollyLabel alloc] initWithFrame:CGRectMake(window.bounds.size.width - 64, 60, 48, 12)];
    [remainingLabel setText:@"0:00"];
    [remainingLabel setTextAlignment:NSTextAlignmentRight];
    [remainingLabel setLinebreakMode:NSLineBreakByTruncatingTail];
    [remainingLabel setFont:[UIFont systemFontOfSize:11 weight:UIFontWeightSemibold]];
    [remainingLabel setTextColor:[UIColor blackColor]];
    [window addSubview:remainingLabel];


    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(32, window.bounds.size.height - 56, window.bounds.size.width - 64, 40)];
    [stackView setDistribution:UIStackViewDistributionFillEqually];
    [stackView setAxis:UILayoutConstraintAxisHorizontal];
    [stackView setAlignment:UIStackViewAlignmentCenter];
    [window addSubview:stackView];


    UIButton *rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rewindButton addTarget:self action:@selector(prevSong:) forControlEvents:UIControlEventTouchUpInside];
    [rewindButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/rewind.png"] forState:UIControlStateNormal];
    [rewindButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [rewindButton.heightAnchor constraintEqualToConstant:40].active = true;
    [rewindButton.widthAnchor constraintEqualToConstant:40].active = true;
    [stackView addArrangedSubview:rewindButton];

    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playPauseButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [playPauseButton.heightAnchor constraintEqualToConstant:40].active = true;
    [playPauseButton.widthAnchor constraintEqualToConstant:40].active = true;
    [playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/play.png"] forState:UIControlStateNormal];
    [stackView addArrangedSubview:playPauseButton];

    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton addTarget:self action:@selector(nextSong:) forControlEvents:UIControlEventTouchUpInside];
    [skipButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/skip.png"] forState:UIControlStateNormal];
    [skipButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [skipButton.heightAnchor constraintEqualToConstant:40].active = true;
    [skipButton.widthAnchor constraintEqualToConstant:40].active = true;
    [stackView addArrangedSubview:skipButton];


    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
__block UIImage *nowPlayingImage = [UIImage imageWithData:[(__bridge NSDictionary *)result objectForKey:(NSData *)(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]] ? [UIImage imageWithData:[(__bridge NSDictionary *)result objectForKey:(NSData *)(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]] : [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/music@2x.png"];
        [mainImageView setImage:nowPlayingImage];
        [blurImageView setImage:nowPlayingImage];


        [songTitle setText:[(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] : @"iPhone"];

        [artistName setText:[(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] : @"Music"];
    });

    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlay) {
        if(!isPlay) {
            [playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/play@3x.png"] forState:UIControlStateNormal];
        } else {
            [playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/pause@3x.png"] forState:UIControlStateNormal];
        }
    });
}


%new
-(void) updateMedia {
    [window setNeedsLayout];

    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlay) {
        if(!isPlay) {
            [playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/play@3x.png"] forState:UIControlStateNormal];
        } else {
            [playPauseButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/pause@3x.png"] forState:UIControlStateNormal];
        }
    });


    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
__block UIImage *nowPlayingImage = [UIImage imageWithData:[(__bridge NSDictionary *)result objectForKey:(NSData *)(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]] ? [UIImage imageWithData:[(__bridge NSDictionary *)result objectForKey:(NSData *)(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]] : [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/music@2x.png"];
[mainImageView setImage:nowPlayingImage];
[blurImageView setImage:nowPlayingImage];
[artistName setTextColor:[self averageColorForImage:nowPlayingImage]];


        [songTitle setText:[(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] : @"iPhone"];

        [artistName setText:[(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] : @"Music"];
    });


    double max = [[player.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    [progressView setValue:player.currentPlaybackTime];
    [progressView setMinimumValue:0];
    [progressView setMaximumValue:max];


    double currentTime = (double)[player currentPlaybackTime];
    double remainingTime = max - currentTime;

    NSString *timeElapsed;
    NSString *timeRemaining;

    if(max >= 3600.0) {
        timeElapsed = [NSString stringWithFormat: @"%02d:%02d:%02d", (int)currentTime / 3600, (int)(currentTime / 60) % 60, (int)currentTime % 60];

        timeRemaining = [NSString stringWithFormat:@"-%02d:%02d:%02d", (int)remainingTime / 3600, (int)(remainingTime / 60) % 60, (int)remainingTime % 60];

    } else {
        timeElapsed = [NSString stringWithFormat: @"%02d:%02d", (int)currentTime / 60, (int)currentTime % 60];

        timeRemaining = [NSString stringWithFormat:@"-%02d:%02d", (int)remainingTime / 60, (int)remainingTime % 60];
    } [remainingLabel setText:timeRemaining];
}

%new
-(void) resetTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateMedia) userInfo:nil repeats:YES];
}


%new
-(void) playPause:(UIButton *)sender {
    MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);

    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlay) {
        if(!isPlay) {
            [sender setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/play@3x.png"] forState:UIControlStateNormal];
        } else {
            [sender setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Elfin.bundle/pause@3x.png"] forState:UIControlStateNormal];
        }
    });
}

%new
-(void) nextSong:(UIButton *)sender {
    MRMediaRemoteSendCommand(kMRNextTrack, 0);
}

%new
-(void) prevSong:(UIButton *)sender {
    MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
}


%new
-(void) playback:(UISlider *)sender {
    [player setCurrentPlaybackTime:sender.value];
}


%new
-(CGRect) trackRectForBounds:(CGRect)bounds {
    CGRect track = bounds;
    track.size.height += 2;
    return track;
}


%new
-(void) pan:(UIPanGestureRecognizer *)pan {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;

    CGPoint translation = [pan locationInView:keyWindow];

        
    CGPoint newCenter = CGPointMake(pan.view.bounds.origin.x + translation.x, [[UIApplication sharedApplication] statusBarFrame].size.height + 94);

    newCenter.x = MAX(16, newCenter.x);
    newCenter.x = MIN([[UIScreen mainScreen] bounds].size.width - 16, newCenter.x);

   CGPoint newCenter2 = CGPointMake(newCenter.x, pan.view.bounds.origin.y + translation.y);
    newCenter2.y = MAX([[UIApplication sharedApplication] statusBarFrame].size.height + 16, newCenter2.y);
    newCenter2.y = MIN(([[UIScreen mainScreen] bounds].size.height - 16) - windowHeight, newCenter2.y);


    [UIView animateWithDuration:0.001 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        newY = newCenter2.y;
        [pan.view setFrame:CGRectMake(pan.view.bounds.origin.x + newCenter.x, pan.view.bounds.origin.y + newCenter2.y, pan.view.bounds.size.width, pan.view.bounds.size.height)];
    } completion:nil];
    
    [pan setTranslation:CGPointZero inView:keyWindow];
}


%new
-(void) tap:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [tap.view setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 16, newY/*[[UIApplication sharedApplication] statusBarFrame].size.height + 16*/, tap.view.bounds.size.width, tap.view.bounds.size.height)];
    } completion:nil];
}


%new
-(UIColor *) averageColorForImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3]) / 255.0;
        CGFloat multiplier = alpha / 255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0]) * multiplier green:((CGFloat)rgba[1]) * multiplier blue:((CGFloat)rgba[2]) * multiplier alpha:alpha];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0]) / 255.0 green:((CGFloat)rgba[1]) / 255.0 blue:((CGFloat)rgba[2]) / 255.0 alpha:((CGFloat)rgba[3]) / 255.0];
    }
}


%new
-(void) minimize:(UIButton *)sender {
    sender.selected = !sender.selected;

    CGRect oldFrame = window.frame;
    if(sender.selected) {
        oldFrame.size.height = 88;
        windowHeight = 88;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [window setFrame:oldFrame];
        [self setMaskToView:window byRoundingCorners:UIRectCornerAllCorners cornerRadii:12];
        } completion:nil];
    } else {
        oldFrame.size.height = 144;
        windowHeight = 144;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [window setFrame:oldFrame];

        [self setMaskToView:window byRoundingCorners:UIRectCornerAllCorners cornerRadii:12];
        } completion:nil];
    }
}


%new
-(void) setMaskToView:(UIView *)view byRoundingCorners:(UIRectCorner)corners cornerRadii:(double)radius {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];

    CAShapeLayer *shape = [CAShapeLayer layer];
    [shape setPath:path.CGPath];
    [view.layer setMask:shape];
}
%end