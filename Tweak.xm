@interface UIDevice(PrivateAPI)
- (void)setOrientation:(UIInterfaceOrientation)interface;
@end

static BOOL isShowingVideo = NO;

%hook UIViewController
- (id)initWithNibName:(id)arg1 bundle:(id)arg2
{
    self = %orig;
    if ([self isKindOfClass:%c(AVFullScreenViewController)]) {
        isShowingVideo = YES;
    }
    return self;
}
- (void)viewDidAppear:(bool)arg1
{
    %orig;
    if (isShowingVideo) {
        [[%c(UIDevice) currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
    }
}
- (void)dealloc
{
    if (isShowingVideo) {
        isShowingVideo = NO;
        // NOTE: Use dispatch_after to workaround mobilesafari inset bug.
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[%c(UIDevice) currentDevice] setOrientation:UIInterfaceOrientationPortrait];
            //[%c(UIViewController) attemptRotationToDeviceOrientation];
        });
    }
    %orig;
}
%end
