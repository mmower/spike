//
//  RailsRequest.h
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RailsRequest : NSObject {
  int                 status;
  NSString            *method;
  NSDate              *when;
  NSHost              *client;
  NSString            *url;
  NSString            *redirect;
  NSString            *controller;
  NSString            *action;
  NSString            *format;
  NSString            *session;
  int                 rps;
  float               realTime;
  float               renderTime;
  float               dbTime;
  NSArray             *params;
  NSMutableArray      *renders;
  NSAttributedString  *sourceLog;
  BOOL                halted;
  NSString            *filter;
}

@property           int                 status;
@property (assign)  NSString            *method;
@property (assign)  NSDate              *when;
@property (assign)  NSHost              *client;
@property (assign)  NSString            *url;
@property (assign)  NSString            *redirect;
@property (assign)  NSString            *controller;
@property (assign)  NSString            *action;
@property (assign)  NSString            *format;
@property (assign)  NSString            *session;
@property           int                 rps;
@property           float               realTime;
@property           float               renderTime;
@property           float               dbTime;
@property (assign)  NSArray             *params;
@property (assign)  NSMutableArray      *renders;
@property (assign)  NSAttributedString  *sourceLog;
@property           BOOL                halted;
@property (assign)  NSString            *filter;

- (void)postProcess;

@end
