//
//  LogParser.h
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RailsRequest;
@class AppController;

@interface LogParser : NSObject {
  AppController   *appController;
  NSDateFormatter *dateParser;
}

- (id)initWithAppController:(AppController *)theAppController;

- (NSArray *)parseLogFile:(NSString *)logFileName;
- (NSArray *)parseLogLines:(NSArray *)lines;
- (RailsRequest *)parseRequest:(NSArray *)lines;

@end
