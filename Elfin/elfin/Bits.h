@interface SpringBoard : UIWindow
-(void) updateMedia;
-(void) updateScrubber;
-(void) resetTimer;

-(UIColor *) averageColorForImage:(UIImage *)image;
-(void) setMaskToView:(UIView *)view byRoundingCorners:(UIRectCorner)corners cornerRadii:(double)radius;
@end


@interface _UIBackdropViewSettings : NSObject
+(id) settingsForStyle:(int)arg1;
@end

@interface _UIBackdropView : UIView
-(id) initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(_UIBackdropViewSettings *)arg3;
-(id) initWithPrivateStyle:(int)arg1;
-(id) initWithSettings:(_UIBackdropViewSettings *)arg1;
-(id) initWithStyle:(int)arg1;
+(NSArray *) allBackdropViews;

-(void) setBlurFilterWithRadius:(float)arg1 blurQuality:(NSString *)arg2 blurHardEdges:(int)arg3;
-(void) setBlurFilterWithRadius:(float)arg1 blurQuality:(NSString *)arg2;
-(void) setBlurHardEdges:(int)arg1;
-(void) setBlurQuality:(NSString *)arg1;
-(void) setBlurRadius:(float)arg1;
-(void) setBlurRadiusSetOnce:(BOOL)arg1;
-(void) setBlursBackground:(BOOL)arg1;
-(void) setBlursWithHardEdges:(BOOL)arg1;
-(void) setStyle:(int)arg1;
@end