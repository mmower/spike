//
//  LogParser.m
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LogParser.h"

#import <TDParseKit/TDParseKit.h>

#import "LogDocument.h"
#import "RailsRequest.h"
#import "ParamParser.h"
#import "Parameter.h"
#import "ParsingProgressController.h"

@interface LogParser (PrivateMethods)
- (RailsRequest *)parseRequest:(NSArray *)lines;
- (NSArray *)parseLogLines:(NSArray *)lines;
- (void)scanProcessing:(NSString *)line intoRequest:(RailsRequest *)request;
- (void)scanParameters:(NSString *)line intoRequest:(RailsRequest *)request;
- (void)scanSession:(NSString *)line intoRequest:(RailsRequest *)request;
- (void)scanCompleted:(NSString *)line intoRequest:(RailsRequest *)request;
- (void)scanRender:(NSString *)line intoRequest:(RailsRequest *)request;
- (void)scanFilter:(NSString *)line intoRequest:(RailsRequest *)request;
@end

@implementation LogParser


- (id)initWithDocument:(LogDocument *)theDocument {
  if( ( self = [super init] ) ) {
    document = theDocument;
    dateParser = [[NSDateFormatter alloc] init];
    [dateParser setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    paramParser = [[ParamParser alloc] init];
  }
  
  return self;
}


- (NSArray *)parseLogData:(NSData *)data {
  progressController = [[ParsingProgressController alloc] init];
  [progressController showWindow:self];
  
  NSString *content = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  
  NSArray *lines = [content componentsSeparatedByString:@"\n"];
  NSLog( @"%d lines to parse.", [lines count] );
  [progressController setMin:0 max:[lines count]];
  
  NSArray *requests = [self parseLogLines:lines];
  NSLog( @"%d requests parsed.", [requests count] );
  [progressController close];
  
  return requests;
}


- (NSArray *)parseLogLines:(NSArray *)lines {
  NSMutableArray *requests = [[NSMutableArray alloc] init];
  
  double  linesProcessed = 0.0;
  BOOL    hitFirstValidEntry = NO;
  
  
  NSMutableArray *lineGroup = [[NSMutableArray alloc] init];
  for( NSString *line in lines ) {
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if( ![line isEqualToString:@""] ) {
      if( [line hasPrefix:@"Processing"] ) {
        if( [lineGroup count] > 0 ) {
          [requests addObject:[self parseRequest:lineGroup]];
          [lineGroup removeAllObjects];
          // break;
        }
        
        hitFirstValidEntry = YES;
      }
      
      if( hitFirstValidEntry ) {
        [lineGroup addObject:line];
      }
    }
    
    linesProcessed += 1;
    [progressController update:linesProcessed];
  }
  
  
  return requests;
}


- (RailsRequest *)parseRequest:(NSArray *)lines {
  RailsRequest *request = [[RailsRequest alloc] init];
  
  for( NSString *line in lines ) {
    if( [line hasPrefix:@"Processing"] ) {
      [self scanProcessing:line intoRequest:request];
    } else if( [line hasPrefix:@"Parameters"] ) {
      [self scanParameters:line intoRequest:request];
    } else if( [line hasPrefix:@"Session ID:"] ) {
      [self scanSession:line intoRequest:request];
    } else if( [line hasPrefix:@"Completed in"] ) {
      [self scanCompleted:line intoRequest:request];
    } else if( [line hasPrefix:@"Rendering"] ) {
      [self scanRender:line intoRequest:request];
    } else if( [line hasPrefix:@"Filter"] ) {
      [self scanFilter:line intoRequest:request];
    }
  }
  
  [request setSourceLog:[[NSAttributedString alloc] initWithString:[lines description]]];
  
  return request;
}


- (void)scanProcessing:(NSString *)line intoRequest:(RailsRequest *)request {
  NSScanner *scanner = [NSScanner scannerWithString:line];
  
  NSString *buffer;
  
  [scanner scanString:@"Processing " intoString:nil];
  [scanner scanUpToString:@"#" intoString:&buffer];
  [request setController:buffer];
  
  [scanner scanString:@"#" intoString:nil];
  [scanner scanUpToString:@" " intoString:&buffer];
  [request setAction:buffer];
  
  [scanner scanString:@"(for " intoString:nil];
  [scanner scanUpToString:@" " intoString:&buffer];
  [request setClient:[NSHost hostWithAddress:buffer]];
  
  [scanner scanString:@"at " intoString:nil];
  [scanner scanUpToString:@")" intoString:&buffer];
  [request setWhen:[dateParser dateFromString:buffer]];
  
  [scanner scanString:@") [" intoString:nil];
  [scanner scanUpToString:@"]" intoString:&buffer];
  [request setMethod:buffer];
}


- (void)scanParameters:(NSString *)line intoRequest:(RailsRequest *)request {
  @try {
    [request setParams:[paramParser parseParams:[line substringFromIndex:12]]];
  }
  @catch( TDTrackException *trackException ) {
    NSLog( @"Parameter parser could not finish: %@", [trackException reason] );
    NSLog( @"\t%@", line );
  }
}


- (void)scanSession:(NSString *)line intoRequest:(RailsRequest *)request {
  NSScanner *scanner = [NSScanner scannerWithString:line];
  
  NSString *buffer;
  
  [scanner scanString:@"Session ID: " intoString:nil];
  [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&buffer];
  [request setSession:buffer];
}


- (void)scanCompleted:(NSString *)line intoRequest:(RailsRequest *)request {
  NSScanner *scanner = [NSScanner scannerWithString:line];
  float t;
  int n;
  
  [scanner scanString:@"Completed in " intoString:nil];
  if( ![scanner scanFloat:&t] ) {
    NSLog( @"Bail scanning for realTime!" );
    return;
  }
  [request setRealTime:t];
  
  [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
  [scanner scanString:@"(" intoString:nil];
  if( ![scanner scanInt:&n] ) {
    NSLog( @"Bail scanning for requests!" );
    return;
  }
  [request setRps:n];
  
  [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
  [scanner scanString:@"reqs/sec) |" intoString:nil];
  
  if( [line rangeOfString:@"Rendering" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
    [scanner scanString:@"Rendering: " intoString:nil];
    if( ![scanner scanFloat:&t] ) {
      NSLog( @"Bail scanning for render time! in (%@)", line );
      return;
    }
    [request setRenderTime:t];
    
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    [scanner scanString:@"(" intoString:nil];
    [scanner scanInt:&n];
    [scanner scanString:@"%) | " intoString:nil];
  }
  
  [scanner scanString:@"DB: " intoString:nil];
  if( ![scanner scanFloat:&t] ) {
    NSLog( @"Bail scanning for DB time! [%@]", [line substringFromIndex:[scanner scanLocation]] );
    return;
  }
  [request setDbTime:t];
  [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
  [scanner scanString:@"(" intoString:nil];
  [scanner scanInt:&n];
  [scanner scanString:@"%) | " intoString:nil];
  
  if( ![scanner scanInt:&n] ) {
    NSLog( @"Bail scanning for status! [%@]", [line substringFromIndex:[scanner scanLocation]] );
    return;
  }
  [request setStatus:n];
  
  NSRange r1, r2;
  r1 = [line rangeOfString:@"[" options:NSBackwardsSearch];
  r2 = [line rangeOfString:@"]" options:NSBackwardsSearch];
  if( r1.location != NSNotFound && r2.location != NSNotFound ) {
    [request setUrl:[line substringWithRange:NSMakeRange( r1.location+1, r2.location - r1.location - 1)]];
  }
  
}


- (void)scanRender:(NSString *)line intoRequest:(RailsRequest *)request {
  NSString *render = [line substringFromIndex:10];
  
  if( [render rangeOfString:@"(internal_server_error)"].location != NSNotFound || [render rangeOfString:@"(not_found)"].location != NSNotFound ) {
    request.status = 500;
  } else if( [render rangeOfString:@".html"].location != NSNotFound ) {
    NSRange match = [render rangeOfString:@"public"];
    [[request renders] addObject:[render substringFromIndex:match.location]];
  } else {
    [[request renders] addObject:render];
  }
}


- (void)scanFilter:(NSString *)line intoRequest:(RailsRequest *)request {
  NSScanner *scanner = [NSScanner scannerWithString:line];
  
  NSString *buffer;
  [scanner scanString:@"Filter chain halted as [:" intoString:nil];
  [scanner scanUpToString:@"]" intoString:&buffer];
  
  [request setHalted:YES];
  [request setFilter:buffer];
}


@end
