//
//  ScannerBoss.h
//  scanner
//
//  Created by david on 1/6/24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScannerBoss : NSObject

- (void)start;

- (void)stop;

- (void)requestOverviewScanTo:(NSImageView *)imageView;


@end

NS_ASSUME_NONNULL_END
