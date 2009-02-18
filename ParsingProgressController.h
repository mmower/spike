//
//  ParsingProgressController.h
//  Spike
//
//  Created by Matt Mower on 18/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ParsingProgressController : NSWindowController {
  IBOutlet  NSPanel                   *panel;
  IBOutlet  NSTextField               *statusField;
  IBOutlet  NSProgressIndicator       *indicator;
}

@property NSTextField *statusField;
@property NSPanel *panel;
@property NSProgressIndicator *indicator;

- (void)setMin:(double)min max:(double)max;
- (void)update:(double)value;
- (void)setStatus:(NSString *)status;
- (void)setAnimated:(BOOL)animated;

@end
