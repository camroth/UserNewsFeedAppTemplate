//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//

#import <QuartzCore/QuartzCore.h>
#import "GPSidePanelController.h"

static char gp_kvoContext;

@interface GPSidePanelController()
{
    CGRect _centerPanelRestingFrame;		
    CGPoint _locationBeforePan;
}

@property (nonatomic, readwrite) GPSidePanelState state;
@property (nonatomic, weak) UIViewController *visiblePanel;
@property (nonatomic, strong) UIView *tapView;

// panel containers
@property (nonatomic, strong) UIView *leftPanelContainer;
@property (nonatomic, strong) UIView *centerPanelContainer;

@end

@implementation GPSidePanelController

@synthesize leftPanelContainer = _leftPanelContainer;
@synthesize centerPanelContainer = _centerPanelContainer;
@synthesize tapView = _tapView;
@synthesize style = _style;
@synthesize state = _state;
@synthesize leftPanel = _leftPanel;
@synthesize centerPanel = _centerPanel;
@synthesize leftGapPercentage = _leftGapPercentage;
@synthesize leftFixedWidth = _leftFixedWidth;
@synthesize rightGapPercentage = _rightGapPercentage;
@synthesize rightFixedWidth = _rightFixedWidth;
@synthesize minimumMovePercentage = _minimumMovePercentage;
@synthesize maximumAnimationDuration = _maximumAnimationDuration;
@synthesize bounceDuration = _bounceDuration;
@synthesize bouncePercentage = _bouncePercentage;
@synthesize panningLimitedToTopViewController = _panningLimitedToTopViewController;
@synthesize recognizesPanGesture = _recognizesPanGesture;
@synthesize canUnloadLeftPanel = _canUnloadLeftPanel;
@synthesize shouldResizeLeftPanel = _shouldResizeLeftPanel;
@synthesize allowLeftOverpan = _allowLeftOverpan;
@synthesize allowRightOverpan = _allowRightOverpan;
@synthesize bounceOnSidePanelOpen = _bounceOnSidePanelOpen;
@synthesize bounceOnSidePanelClose = _bounceOnSidePanelClose;
@synthesize bounceOnCenterPanelChange = _bounceOnCenterPanelChange;
@synthesize visiblePanel = _visiblePanel;
@synthesize shouldDelegateAutorotateToVisiblePanel = _shouldDelegateAutorotateToVisiblePanel;
@synthesize centerPanelHidden = _centerPanelHidden;
@synthesize allowLeftSwipe = _allowLeftSwipe;
@synthesize allowRightSwipe = _allowRightSwipe;
@synthesize pushesSidePanels = _pushesSidePanels;

#pragma mark - Icon

+ (UIImage *)defaultImage
{
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
		
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
		
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];   
		
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

	});
    return defaultImage;
}

#pragma mark - NSObject

- (void)dealloc
{
    if (_centerPanel)
    {
        [_centerPanel removeObserver:self forKeyPath:@"view"];
        [_centerPanel removeObserver:self forKeyPath:@"viewControllers"];
    }
}

//Support creating from Storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self _baseInit];
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        [self _baseInit];
    }
    return self;
}

- (void)_baseInit
{
    self.style = GPSidePanelSingleActive;
    self.leftGapPercentage = 0.8f;
    self.rightGapPercentage = 0.8f;
    self.minimumMovePercentage = 0.15f;
    self.maximumAnimationDuration = 0.2f;
    self.bounceDuration = 0.1f;
    self.bouncePercentage = 0.075f;
    self.panningLimitedToTopViewController = YES;
    self.recognizesPanGesture = YES;
    self.allowLeftOverpan = YES;
    self.allowRightOverpan = YES;
    self.bounceOnSidePanelOpen = YES;
    self.bounceOnSidePanelClose = NO;
    self.bounceOnCenterPanelChange = YES;
    self.shouldDelegateAutorotateToVisiblePanel = YES;
    self.allowRightSwipe = YES;
    self.allowLeftSwipe = YES;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.centerPanelContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _centerPanelRestingFrame = self.centerPanelContainer.frame;
    _centerPanelHidden = NO;
    
    self.leftPanelContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.leftPanelContainer.hidden = YES;
    
    [self _configureContainers];
    
    [self.view addSubview:self.centerPanelContainer];
    [self.view addSubview:self.leftPanelContainer];
    
    self.state = GPSidePanelCenterVisible;
    
    [self _swapCenter:nil previousState:0 with:_centerPanel];
    [self.view bringSubviewToFront:self.centerPanelContainer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // ensure correct view dimensions
    [self _layoutSideContainers:NO duration:0.0f];
    [self _layoutSidePanels];
    self.centerPanelContainer.frame = [self _adjustCenterFrame];
    [self styleContainer:self.centerPanelContainer animate:NO duration:0.0f];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self _adjustCenterFrame]; //Account for possible rotation while view appearing
}

#if !defined(__IPHONE_6_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tapView = nil;
    self.centerPanelContainer = nil;
    self.leftPanelContainer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    __strong UIViewController *visiblePanel = self.visiblePanel;

    if (self.shouldDelegateAutorotateToVisiblePanel) {
        return [visiblePanel shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    } else {
        return YES;
    }
}

#else

- (BOOL)shouldAutorotate {
    __strong UIViewController *visiblePanel = self.visiblePanel;

    if (self.shouldDelegateAutorotateToVisiblePanel && [visiblePanel respondsToSelector:@selector(shouldAutorotate)]) {
        return [visiblePanel shouldAutorotate];
    } else {
        return YES;
    }
}


#endif

- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.centerPanelContainer.frame = [self _adjustCenterFrame];	
    [self _layoutSideContainers:YES duration:duration];
    [self _layoutSidePanels];
    [self styleContainer:self.centerPanelContainer animate:YES duration:duration];
    if (self.centerPanelHidden) {
        CGRect frame = self.centerPanelContainer.frame;
        frame.origin.x = self.state == GPSidePanelLeftVisible ? self.centerPanelContainer.frame.size.width : -self.centerPanelContainer.frame.size.width;
        self.centerPanelContainer.frame = frame;
    }
}

#pragma mark - State

- (void)setState:(GPSidePanelState)state {
    if (state != _state) {
        _state = state;
        switch (_state) {
            case GPSidePanelCenterVisible:
            {
                self.visiblePanel = self.centerPanel;
                self.leftPanelContainer.userInteractionEnabled = NO;
                break;
			}
            case GPSidePanelLeftVisible:
            {
                self.visiblePanel = self.leftPanel;
                self.leftPanelContainer.userInteractionEnabled = YES;
                break;
			}
        }
    }
}

#pragma mark - Style

- (void)setStyle:(GPSidePanelStyle)style {
    if (style != _style) {
        _style = style;
        if (self.isViewLoaded) {
            [self _configureContainers];
            [self _layoutSideContainers:NO duration:0.0f];
        }
    }
}

- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:0.0f];
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        animation.fromValue = (id)container.layer.shadowPath;
        animation.toValue = (id)shadowPath.CGPath;
        animation.duration = duration;
        [container.layer addAnimation:animation forKey:@"shadowPath"];
    }
    container.layer.shadowPath = shadowPath.CGPath;	
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 10.0f;
    container.layer.shadowOpacity = 0.75f;
    container.clipsToBounds = NO;
}

- (void)stylePanel:(UIView *)panel
{
    panel.layer.cornerRadius = 6.0f;
    panel.clipsToBounds = YES;
}

- (void)_configureContainers
{
    self.leftPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.centerPanelContainer.frame =  self.view.bounds;
    self.centerPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_layoutSideContainers:(BOOL)animate duration:(NSTimeInterval)duration
{
    CGRect leftFrame = self.view.bounds;
    CGRect rightFrame = self.view.bounds;
    if (self.style == GPSidePanelMultipleActive)
    {
        // left panel container
        leftFrame.size.width = self.leftVisibleWidth;
        leftFrame.origin.x = self.centerPanelContainer.frame.origin.x - leftFrame.size.width;
        
        // right panel container
        rightFrame.origin.x = self.centerPanelContainer.frame.origin.x + self.centerPanelContainer.frame.size.width;
    }
    else if (self.pushesSidePanels && !self.centerPanelHidden)
    {
        leftFrame.origin.x = self.centerPanelContainer.frame.origin.x - self.leftVisibleWidth;
        rightFrame.origin.x = self.centerPanelContainer.frame.origin.x + self.centerPanelContainer.frame.size.width;
    }
    self.leftPanelContainer.frame = leftFrame;
    [self styleContainer:self.leftPanelContainer animate:animate duration:duration];
}

- (void)_layoutSidePanels
{
    if (self.leftPanel.isViewLoaded) {
        CGRect frame = self.leftPanelContainer.bounds;
        if (self.shouldResizeLeftPanel) {
            frame.size.width = self.leftVisibleWidth;
        }
        self.leftPanel.view.frame = frame;
    }
}

#pragma mark - Panels

- (void)setCenterPanel:(UIViewController *)centerPanel {
    UIViewController *previous = _centerPanel;
    if (centerPanel != _centerPanel) {
        [_centerPanel removeObserver:self forKeyPath:@"view"];
        [_centerPanel removeObserver:self forKeyPath:@"viewControllers"];
        _centerPanel = centerPanel;
        [_centerPanel addObserver:self forKeyPath:@"viewControllers" options:0 context:&gp_kvoContext];
        [_centerPanel addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionInitial context:&gp_kvoContext];
        if (self.state == GPSidePanelCenterVisible) {
            self.visiblePanel = _centerPanel;
        }
    }
    if (self.isViewLoaded && self.state == GPSidePanelCenterVisible) {
        [self _swapCenter:previous previousState:0 with:_centerPanel];
    } else if (self.isViewLoaded) {
        // update the state immediately to prevent user interaction on the side panels while animating
        GPSidePanelState previousState = self.state;
        self.state = GPSidePanelCenterVisible;
        [UIView animateWithDuration:0.2f animations:^{
            if (self.bounceOnCenterPanelChange) {
                // first move the centerPanel offscreen
                CGFloat x = (previousState == GPSidePanelLeftVisible) ? self.view.bounds.size.width : -self.view.bounds.size.width;
                _centerPanelRestingFrame.origin.x = x;
            }
            self.centerPanelContainer.frame = _centerPanelRestingFrame;
        } completion:^(__unused BOOL finished) {
            [self _swapCenter:previous previousState:previousState with:_centerPanel];
            [self _showCenterPanel:YES bounce:NO];
        }];
    }
}

- (void)_swapCenter:(UIViewController *)previous previousState:(GPSidePanelState)previousState with:(UIViewController *)next {
    if (previous != next) {
        [previous willMoveToParentViewController:nil];
        [previous.view removeFromSuperview];
        [previous removeFromParentViewController];
        
        if (next) {
            [self _loadCenterPanelWithPreviousState:previousState];
            [self addChildViewController:next];
            [self.centerPanelContainer addSubview:next.view];
            [next didMoveToParentViewController:self];
        }
    }
}

- (void)setLeftPanel:(UIViewController *)leftPanel {
    if (leftPanel != _leftPanel) {
        [_leftPanel willMoveToParentViewController:nil];
        [_leftPanel.view removeFromSuperview];
        [_leftPanel removeFromParentViewController];
        _leftPanel = leftPanel;
        if (_leftPanel) {
            [self addChildViewController:_leftPanel];
            [_leftPanel didMoveToParentViewController:self];
            [self _placeButtonForLeftPanel];
        }
        if (self.state == GPSidePanelLeftVisible) {
            self.visiblePanel = _leftPanel;
        }
    }
}

#pragma mark - Panel Buttons

- (void)_placeButtonForLeftPanel {
    if (self.leftPanel) {
        UIViewController *buttonController = self.centerPanel;
        if ([buttonController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)buttonController;
            if ([nav.viewControllers count] > 0) {
                buttonController = [nav.viewControllers objectAtIndex:0];
            }
        }
        if (!buttonController.navigationItem.leftBarButtonItem) {   
            buttonController.navigationItem.leftBarButtonItem = [self leftButtonForCenterPanel];
        }
    }	
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view == self.tapView) {
        return YES;
    } else if (self.panningLimitedToTopViewController && ![self _isOnTopLevelViewController:self.centerPanel]) {
        return NO;
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translate = [pan translationInView:self.centerPanelContainer];
        // determine if right swipe is allowed
        if (translate.x < 0 && ! self.allowRightSwipe) {
            return NO;
        }
        // determine if left swipe is allowed
        if (translate.x > 0 && ! self.allowLeftSwipe) {
            return NO;
        }
        BOOL possible = translate.x != 0 && ((fabsf(translate.y) / fabsf(translate.x)) < 1.0f);
        if (possible && (translate.x > 0 && self.leftPanel))
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Pan Gestures

- (void)_addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [view addGestureRecognizer:panGesture];	
}

- (void)_handlePan:(UIGestureRecognizer *)sender
{
	if (!_recognizesPanGesture)
    {
		return;
	}
	
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
        
        if (pan.state == UIGestureRecognizerStateBegan)
        {
            _locationBeforePan = self.centerPanelContainer.frame.origin;
        }
        
        CGPoint translate = [pan translationInView:self.centerPanelContainer];
        CGRect frame = _centerPanelRestingFrame;
        frame.origin.x += roundf([self _correctMovement:translate.x]);
        
        if (self.style == GPSidePanelMultipleActive)
        {
            frame.size.width = self.view.bounds.size.width - frame.origin.x;
        }
        
        self.centerPanelContainer.frame = frame;
        
        // if center panel has focus, make sure correct side panel is revealed
        if (self.state == GPSidePanelCenterVisible)
        {
            if (frame.origin.x > 0.0f)
            {
                [self _loadLeftPanel];
            }
        }
        
        // adjust side panel locations, if needed
        if (self.style == GPSidePanelMultipleActive || self.pushesSidePanels)
        {
            [self _layoutSideContainers:NO duration:0];
        }
        
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            CGFloat deltaX =  frame.origin.x - _locationBeforePan.x;			
            if ([self _validateThreshold:deltaX])
            {
                [self _completePan:deltaX];
            }
            else
            {
                [self _undoPan];
            }
        }
        else if (sender.state == UIGestureRecognizerStateCancelled)
        {
            [self _undoPan];
        }
    }
}

- (void)_completePan:(CGFloat)deltaX
{
    switch (self.state)
    {
        case GPSidePanelCenterVisible:
        {
            if (deltaX > 0.0f)
            {
                [self _showLeftPanel:YES bounce:self.bounceOnSidePanelOpen];
            }
            break;
		}
        case GPSidePanelLeftVisible:
        {
            [self _showCenterPanel:YES bounce:self.bounceOnSidePanelClose];
            break;
		}
    }
}

- (void)_undoPan
{
    switch (self.state)
    {
        case GPSidePanelCenterVisible:
        {
            [self _showCenterPanel:YES bounce:NO];
            break;
		}
        case GPSidePanelLeftVisible:
        {
            [self _showLeftPanel:YES bounce:NO];
            break;
		}
    }
}

#pragma mark - Tap Gesture

- (void)setTapView:(UIView *)tapView
{
    if (tapView != _tapView)
    {
        [_tapView removeFromSuperview];
        _tapView = tapView;
        
        if (_tapView)
        {
            _tapView.frame = self.centerPanelContainer.bounds;
            _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self _addTapGestureToView:_tapView];
            if (self.recognizesPanGesture)
            {
                [self _addPanGestureToView:_tapView];
            }
            [self.centerPanelContainer addSubview:_tapView];
        }
    }
}

- (void)_addTapGestureToView:(UIView *)view
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_centerPanelTapped:)];
    [view addGestureRecognizer:tapGesture];	
}

- (void)_centerPanelTapped:(__unused UIGestureRecognizer *)gesture
{
    [self _showCenterPanel:YES bounce:NO];
}

#pragma mark - Internal Methods

- (CGFloat)_correctMovement:(CGFloat)movement
{
    CGFloat position = _centerPanelRestingFrame.origin.x + movement;
    if (self.state == GPSidePanelCenterVisible)
    {
        if ((position > 0.0f && !self.leftPanel))
        {
            return 0.0f;
        }
        else if (!self.allowLeftOverpan && position > self.leftVisibleWidth)
        {
            return self.leftVisibleWidth;
        }
    }
    else if (self.state == GPSidePanelLeftVisible  && !self.allowLeftOverpan)
    {
        if (position > self.leftVisibleWidth)
        {
            return 0.0f;
        }
        else if ((self.style == GPSidePanelMultipleActive || self.pushesSidePanels) && position < 0.0f)
        {
            return -_centerPanelRestingFrame.origin.x;
        }
        else if (position < self.leftPanelContainer.frame.origin.x)
        {
            return self.leftPanelContainer.frame.origin.x - _centerPanelRestingFrame.origin.x;
        }
    }
    return movement;
}

- (BOOL)_validateThreshold:(CGFloat)movement
{
    CGFloat minimum = floorf(self.view.bounds.size.width * self.minimumMovePercentage);
    switch (self.state)
    {
        case GPSidePanelLeftVisible:
        {
            return movement <= -minimum;
		}
        case GPSidePanelCenterVisible:
        {
            return fabsf(movement) >= minimum;
		}
    }
    return NO;
}

- (BOOL)_isOnTopLevelViewController:(UIViewController *)root
{
    if ([root isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController *)root;
        return [nav.viewControllers count] == 1;
    }
    else if ([root isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tab = (UITabBarController *)root;
        return [self _isOnTopLevelViewController:tab.selectedViewController];
    }
    return root != nil;
}

#pragma mark - Loading Panels

- (void)_loadCenterPanelWithPreviousState:(GPSidePanelState)previousState
{
    [self _placeButtonForLeftPanel];
    
    // for the multi-active style, it looks better if the new center starts out in it's fullsize and slides in
    if (self.style == GPSidePanelMultipleActive)
    {
        switch (previousState)
        {
            case GPSidePanelLeftVisible:
            {
                CGRect frame = self.centerPanelContainer.frame;
                frame.size.width = self.view.bounds.size.width;
                self.centerPanelContainer.frame = frame;
                break;
            }
            default:
                break;
        }
    }
    
    _centerPanel.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _centerPanel.view.frame = self.centerPanelContainer.bounds;
    [self stylePanel:_centerPanel.view];
}

- (void)_loadLeftPanel
{

    if (self.leftPanelContainer.hidden && self.leftPanel)
    {
        if (!_leftPanel.view.superview)
        {
            [self _layoutSidePanels];
            _leftPanel.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self stylePanel:_leftPanel.view];
            [self.leftPanelContainer addSubview:_leftPanel.view];
        }
        
        self.leftPanelContainer.hidden = NO;
    }
}

- (void)_unloadPanels
{
    if (self.canUnloadLeftPanel && self.leftPanel.isViewLoaded)
    {
        [self.leftPanel.view removeFromSuperview];
    }
}

#pragma mark - Animation

- (CGFloat)_calculatedDuration
{
    CGFloat remaining = fabsf(self.centerPanelContainer.frame.origin.x - _centerPanelRestingFrame.origin.x);	
    CGFloat max = _locationBeforePan.x == _centerPanelRestingFrame.origin.x ? remaining : fabsf(_locationBeforePan.x - _centerPanelRestingFrame.origin.x);
    return max > 0.0f ? self.maximumAnimationDuration * (remaining / max) : self.maximumAnimationDuration;
}

- (void)_animateCenterPanel:(BOOL)shouldBounce completion:(void (^)(BOOL finished))completion
{
    CGFloat bounceDistance = (_centerPanelRestingFrame.origin.x - self.centerPanelContainer.frame.origin.x) * self.bouncePercentage;
    
    // looks bad if we bounce when the center panel grows
    if (_centerPanelRestingFrame.size.width > self.centerPanelContainer.frame.size.width)
    {
        shouldBounce = NO;
    }
    
    CGFloat duration = [self _calculatedDuration];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionLayoutSubviews animations:^{
        self.centerPanelContainer.frame = _centerPanelRestingFrame;
        [self styleContainer:self.centerPanelContainer animate:YES duration:duration];
        if (self.style == GPSidePanelMultipleActive || self.pushesSidePanels)
        {
            [self _layoutSideContainers:NO duration:0.0f];
        }
    } completion:^(BOOL finished) {
        if (shouldBounce)
        {
            // make sure correct panel is displayed under the bounce
            if (self.state == GPSidePanelCenterVisible)
            {
                if (bounceDistance > 0.0f)
                {
                    [self _loadLeftPanel];
                }
            }
            // animate the bounce
            [UIView animateWithDuration:self.bounceDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRect bounceFrame = _centerPanelRestingFrame;
                bounceFrame.origin.x += bounceDistance;
                self.centerPanelContainer.frame = bounceFrame;
            } completion:^(__unused BOOL finished2) {
                [UIView animateWithDuration:self.bounceDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.centerPanelContainer.frame = _centerPanelRestingFrame;				
                } completion:completion];
            }];
        }
        else if (completion)
        {
            completion(finished);
        }
    }];
}

#pragma mark - Panel Sizing

- (CGRect)_adjustCenterFrame
{
    CGRect frame = self.view.bounds;
    switch (self.state)
    {
        case GPSidePanelCenterVisible:
        {
            frame.origin.x = 0.0f;
            if (self.style == GPSidePanelMultipleActive)
            {
                frame.size.width = self.view.bounds.size.width;	
            }
            break;
		}
        case GPSidePanelLeftVisible:
        {
            frame.origin.x = self.leftVisibleWidth;
            if (self.style == GPSidePanelMultipleActive)
            {
                frame.size.width = self.view.bounds.size.width - self.leftVisibleWidth;
            }
            break;
		}
    }
    _centerPanelRestingFrame = frame;
    return _centerPanelRestingFrame;
}

- (CGFloat)leftVisibleWidth
{
    if (self.centerPanelHidden && self.shouldResizeLeftPanel)
    {
        return self.view.bounds.size.width;
    }
    else
    {
        return self.leftFixedWidth ? self.leftFixedWidth : floorf(self.view.bounds.size.width * self.leftGapPercentage);
    }
}

#pragma mark - Showing Panels

- (void)_showLeftPanel:(BOOL)animated bounce:(BOOL)shouldBounce
{
    self.state = GPSidePanelLeftVisible;
    [self _loadLeftPanel];
    
    [self _adjustCenterFrame];
    
    if (animated)
    {
        [self _animateCenterPanel:shouldBounce completion:nil];
    }
    else
    {
        self.centerPanelContainer.frame = _centerPanelRestingFrame;	
        [self styleContainer:self.centerPanelContainer animate:NO duration:0.0f];
        if (self.style == GPSidePanelMultipleActive || self.pushesSidePanels)
        {
            [self _layoutSideContainers:NO duration:0.0f];
        }
    }
    
    if (self.style == GPSidePanelSingleActive)
    {
        self.tapView = [[UIView alloc] init];
    }
    [self _toggleScrollsToTopForCenter:NO left:YES right:NO];
}

- (void)_showCenterPanel:(BOOL)animated bounce:(BOOL)shouldBounce {
    self.state = GPSidePanelCenterVisible;
    
    [self _adjustCenterFrame];
    
    if (animated)
    {
        [self _animateCenterPanel:shouldBounce completion:^(__unused BOOL finished) {
            self.leftPanelContainer.hidden = YES;
            [self _unloadPanels];
        }];
    }
    else
    {
        self.centerPanelContainer.frame = _centerPanelRestingFrame;	
        [self styleContainer:self.centerPanelContainer animate:NO duration:0.0f];
        
        if (self.style == GPSidePanelMultipleActive || self.pushesSidePanels)
        {
            [self _layoutSideContainers:NO duration:0.0f];
        }
        
        self.leftPanelContainer.hidden = YES;
        [self _unloadPanels];
    }
    
    self.tapView = nil;
    [self _toggleScrollsToTopForCenter:YES left:NO right:NO];
}

- (void)_hideCenterPanel
{
    self.centerPanelContainer.hidden = YES;
    if (self.centerPanel.isViewLoaded)
    {
        [self.centerPanel.view removeFromSuperview];
    }
}

- (void)_unhideCenterPanel
{
    self.centerPanelContainer.hidden = NO;
    if (!self.centerPanel.view.superview)
    {
        self.centerPanel.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerPanel.view.frame = self.centerPanelContainer.bounds;
        [self stylePanel:self.centerPanel.view];
        [self.centerPanelContainer addSubview:self.centerPanel.view];
    }
}

- (void)_toggleScrollsToTopForCenter:(BOOL)center left:(BOOL)left right:(BOOL)right
{
    // iPhone only supports 1 active UIScrollViewController at a time
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self _toggleScrollsToTop:center forView:self.centerPanelContainer];
        [self _toggleScrollsToTop:left forView:self.leftPanelContainer];
    }
}

- (BOOL)_toggleScrollsToTop:(BOOL)enabled forView:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView *)view;
        scrollView.scrollsToTop = enabled;
        return YES;
    }
    else
    {
        for (UIView *subview in view.subviews)
        {
            if([self _toggleScrollsToTop:enabled forView:subview])
            {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(__unused NSDictionary *)change context:(void *)context
{
    if (context == &gp_kvoContext)
    {
        if ([keyPath isEqualToString:@"view"])
        {
            if (self.centerPanel.isViewLoaded && self.recognizesPanGesture)
            {
                [self _addPanGestureToView:self.centerPanel.view];
            }
        }
        else if ([keyPath isEqualToString:@"viewControllers"] && object == self.centerPanel)
        {
            // view controllers have changed, need to replace the button
            [self _placeButtonForLeftPanel];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Public Methods

- (UIBarButtonItem *)leftButtonForCenterPanel
{
    return [[UIBarButtonItem alloc] initWithImage:[[self class] defaultImage] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
}

- (void)showLeftPanel:(BOOL)animated
{
    [self showLeftPanelAnimated:animated];
}

- (void)showCenterPanel:(BOOL)animated
{
    [self showCenterPanelAnimated:animated];
}

- (void)showLeftPanelAnimated:(BOOL)animated
{
    [self _showLeftPanel:animated bounce:NO];
}

- (void)showCenterPanelAnimated:(BOOL)animated
{
    // make sure center panel isn't hidden
    if (_centerPanelHidden)
    {
        _centerPanelHidden = NO;
        [self _unhideCenterPanel];
    }
    [self _showCenterPanel:animated bounce:NO];
}

- (void)toggleLeftPanel:(__unused id)sender
{
    if (self.state == GPSidePanelLeftVisible)
    {
        [self _showCenterPanel:YES bounce:NO];
    }
    else if (self.state == GPSidePanelCenterVisible)
    {
        [self _showLeftPanel:YES bounce:NO];
    }
}

- (void)setCenterPanelHidden:(BOOL)centerPanelHidden
{
    [self setCenterPanelHidden:centerPanelHidden animated:NO duration:0.0];
}

- (void)setCenterPanelHidden:(BOOL)centerPanelHidden animated:(BOOL)animated duration:(NSTimeInterval) duration
{
    if (centerPanelHidden != _centerPanelHidden && self.state != GPSidePanelCenterVisible)
    {
        _centerPanelHidden = centerPanelHidden;
        duration = animated ? duration : 0.0f;
        if (centerPanelHidden)
        {
            [UIView animateWithDuration:duration animations:^{
                CGRect frame = self.centerPanelContainer.frame;
                frame.origin.x = self.state == GPSidePanelLeftVisible ? self.centerPanelContainer.frame.size.width : -self.centerPanelContainer.frame.size.width;
                self.centerPanelContainer.frame = frame;
                [self _layoutSideContainers:NO duration:0];
                if (self.shouldResizeLeftPanel)
                {
                    [self _layoutSidePanels];
                }
            } completion:^(__unused BOOL finished) {
                // need to double check in case the user tapped really fast
                if (_centerPanelHidden) {
                    [self _hideCenterPanel];
                }
            }];
        } else {
            [self _unhideCenterPanel];
            [UIView animateWithDuration:duration animations:^{
                if (self.state == GPSidePanelLeftVisible)
                {
                    [self showLeftPanelAnimated:NO];
                }
                if (self.shouldResizeLeftPanel) {
                    
                    [self _layoutSidePanels];
                }
            }];
        }
    }
}

@end
