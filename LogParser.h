//
//  LogParser.h
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RailsRequest;
@class LogDocument;
@class ParamParser;
@class ParsingProgressController;

@interface LogParser : NSObject {
  LogDocument                 *document;
  NSDateFormatter             *dateParser;
  ParamParser                 *paramParser;

  NSUInteger                  highWaterMark;

  ParsingProgressController   *progressController;
}

- (id)initWithDocument:(LogDocument *)theDocument;

- (void)parseLogData:(NSData *)data;

@end
