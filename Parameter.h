//
//  Parameter.h
//  Spike
//
//  Created by Matt Mower on 14/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Parameter : NSObject {
  NSString *name;
  NSString *value;
  
  BOOL    leaf;
  NSArray *groupedParams;
}

@property (assign)  NSString    *name;
@property (assign)  NSString    *value;
@property (assign)  NSArray     *groupedParams;
@property           BOOL        leaf;

- (id)initWithName:(NSString *)aName;

@end
