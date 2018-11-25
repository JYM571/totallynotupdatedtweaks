@interface SBHUDView : UIView
@property(nonatomic) float progress;

-(void) createMaskForView:(UIView *)view byRoundingCorners:(UIRectCorner)corners cornerRadii:(double)radius;
@end

@interface SBHUDController : UIViewController
@end

@interface _UIBackdropView : UIView
@end