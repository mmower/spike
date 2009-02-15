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
  NSString            *controller;
  NSString            *action;
  NSString            *session;
  int                 rps;
  float               realTime;
  float               renderTime;
  float               dbTime;
  NSArray             *params;
  NSMutableArray      *renders;
  NSAttributedString  *sourceLog;
}

@property           int                 status;
@property (assign)  NSString            *method;
@property (assign)  NSDate              *when;
@property (assign)  NSHost              *client;
@property (assign)  NSString            *url;
@property (assign)  NSString            *controller;
@property (assign)  NSString            *action;
@property (assign)  NSString            *session;
@property           int                 rps;
@property           float               realTime;
@property           float               renderTime;
@property           float               dbTime;
@property (assign)  NSArray             *params;
@property (assign)  NSMutableArray      *renders;
@property (assign)  NSAttributedString  *sourceLog;

@end
