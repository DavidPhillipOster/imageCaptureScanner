//  ScannerBoss.m
//  scanner
//
//  Created by david on 1/6/24.

/*
browser finds scanner. Sets the dest dir, filename, file type,
starts the motor in the scanner, but doesn't actually scan.

Compared to the built in app, there's no way to set the scan rectangle, resolution, mode.
 */

#import "ScannerBoss.h"

#import <ImageCaptureCore/ImageCaptureCore.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ScannerBoss () <ICDeviceBrowserDelegate, ICDeviceDelegate>
@property ICDeviceBrowser *browser;
@property ICScannerDevice *scanner;
@property(weak) NSImageView *imageView;
@property ICScannerFunctionalUnitFlatbed *fu;
@property(nonatomic) Boolean scannerIsReady;
@property Boolean overviewScanPending;
@end

@implementation ScannerBoss

- (instancetype)init {
  self = [super init];
  if (self) {
    self.browser = [[ICDeviceBrowser alloc] init];
    self.browser.browsedDeviceTypeMask = ICDeviceTypeMaskScanner | ICDeviceLocationTypeMaskLocal;
    self.browser.delegate = self;
  }
  return self;
}

- (void)start {
  [self.browser start];
}

- (void)stop {
  [self.scanner requestCloseSession];
  self.scanner = nil;
  [self.browser stop];
}

- (void)setScannerIsReady:(Boolean)isReady {
  _scannerIsReady = isReady;
  if (isReady && self.overviewScanPending) {
    self.overviewScanPending = NO;
    [self.scanner requestSelectFunctionalUnit:ICScannerFunctionalUnitTypeFlatbed];
  }
}

- (void)requestOverviewScanTo:(NSImageView *)imageView {
  self.imageView = imageView;
  [self requestOverviewScan];
}

- (void)requestOverviewScan {
  if (self.scannerIsReady) {
    NSURL *downloads = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    self.scanner.downloadsDirectory = downloads;
    self.scanner.documentUTI = UTTypeTIFF.identifier;
    self.scanner.documentName = @"Scan1.tiff";
    [self.scanner requestOverviewScan];
    NSLog(@"%@", self.scanner);
  } else {
    self.overviewScanPending = YES;
  }
}

- (void)deviceBrowser:(nonnull ICDeviceBrowser *)browser didAddDevice:(nonnull ICDevice *)device moreComing:(BOOL)moreComing {
  if (nil == self.scanner) {
    self.scanner = (ICScannerDevice *)device;
    self.scanner.delegate = self;
    [self.scanner requestOpenSession];
  }
}

- (void)deviceBrowser:(nonnull ICDeviceBrowser *)browser didRemoveDevice:(nonnull ICDevice *)device moreGoing:(BOOL)moreGoing {
  if (device == self.scanner) {
    self.scanner = nil;
  }
}

- (void)device:(ICDevice*)device didReceiveStatusInformation:(NSDictionary<ICDeviceStatus,id>*)status {
  NSLog(@"%@", status);
 }

- (void)device:(ICDevice*)device didCloseSessionWithError:(NSError* _Nullable)error {
}

- (void)device:(ICDevice*)device didEncounterError:(NSError* _Nullable)error {
  NSLog(@"%@", error);
}

- (void)scannerDevice:(ICScannerDevice*)scanner didSelectFunctionalUnit:(ICScannerFunctionalUnit*)functionalUnit error:(NSError* _Nullable)error {
  self.fu = (ICScannerFunctionalUnitFlatbed *)functionalUnit;
  if (self.fu) {
    NSLog(@"%@", self.fu);
//TODO: set more parameters of the scan here. Start a timer to update the overview scan CGImage
    [scanner requestOverviewScan];
  }
}

- (void)scannerDevice:(ICScannerDevice*)scanner didScanToBandData:(ICScannerBandData*)data {
  NSLog(@"%@", scanner);
}

- (void)deviceDidBecomeReady:(ICDevice*)device {
  if (device == self.scanner) {
    self.scannerIsReady = YES;
  }
}

- (void)didRemoveDevice:(ICDevice*)device {
}

- (void)device:(ICDevice*)device didOpenSessionWithError:(NSError* _Nullable) error {
  if (nil == error) {
    [self requestOverviewScan];
  } else {
    // handle error
  }
}

- (void)scannerDevice:(ICScannerDevice *)scanner didCompleteOverviewScanWithError:(NSError *)error {
  if (nil == error) {
    if (self.fu.overviewImage && self.imageView) {
      CGSize siz = CGSizeMake(CGImageGetWidth(self.fu.overviewImage), CGImageGetHeight(self.fu.overviewImage));
      NSImage *image  = [[NSImage alloc] initWithCGImage:self.fu.overviewImage size:siz];
      if (image) {
        self.imageView.image = image;
      }
    }
    NSLog(@"%@", scanner);
  } else {
    // handle error
  }
}

- (void)scannerDevice:(ICScannerDevice *)scanner didScanToURL:(NSURL *)url {
  NSLog(@"%@ %@", scanner, url);
}

- (void)scannerDeviceDidBecomeAvailable:(ICScannerDevice *)scanner {
  if (scanner == self.scanner) {
    [self.scanner requestOpenSession];
  }
}


@end
