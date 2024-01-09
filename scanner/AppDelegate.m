//  AppDelegate.m
//  scanner
//
//  Created by David Phillip Oster on 1/6/24.
//

#import "AppDelegate.h"

#import "ScannerBoss.h"

@interface AppDelegate ()

@property IBOutlet NSWindow *window;
@property IBOutlet NSImageView *imageView;
@property ScannerBoss *scannerBoss;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.scannerBoss = [[ScannerBoss alloc] init];
  [self.scannerBoss start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self.scannerBoss stop];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
  return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  return YES;
}

- (IBAction)overViewScan:(id)sender {
  [self.scannerBoss requestOverviewScanTo:self.imageView];
}

- (IBAction)scan:(id)sender {
  [self.scannerBoss scan];
}

@end
