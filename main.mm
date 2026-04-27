#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#include <stdio.h>

@interface MystrixMenu : UIView <WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation MystrixMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Configure Web Context
        WKUserContentController *contentController = [[WKUserContentController alloc] init];
        [contentController addScriptMessageHandler:self name:@"execProtocol"];

        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController = contentController;
        config.allowsInlineMediaPlayback = YES;

        self.webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.opaque = NO;
        
        // Load your HTML Design (Assuming it's hosted or injected as a string)
        NSString *htmlPath = @"https://amadbarwary.github.io/Mystrix/index.html"; // Update to your site
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:htmlPath]]];
        
        [self addSubview:self.webView];
        
        // Make Draggable
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

// Handle messages sent from the "Execute" button in HTML
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"execProtocol"]) {
        NSString *luaCode = (NSString *)message.body;
        [self runLua:luaCode];
    }
}

- (void)runLua:(NSString *)code {
    printf("Mystrix Executing: %s\n", [code UTF8String]);
    // PROTOCOL 99: This is where you call the game's loadstring
    // Example: get_lua_state()->loadstring(code);
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}
@end

static void __attribute__((constructor)) initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        MystrixMenu *menu = [[MystrixMenu alloc] initWithFrame:CGRectMake(50, 50, 850, 500)];
        [keyWindow addSubview:menu];
    });
}
