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
  IBOutlet  NSProgressIndicator       *indicator;
}

@property NSPanel *panel;
@property NSProgressIndicator *indicator;

- (void)setMin:(double)min max:(double)max;
- (void)update:(double)value;

@end
