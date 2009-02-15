//
//  HashParser.h
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDToken;
@class TDParser;
@class TDCollectionParser;

@interface HashParser : NSObject {
  TDToken             *bracket;
  TDToken             *brace;
  TDCollectionParser  *hashParser;
  TDParser            *stringParser;
  TDParser            *numberParser;
  TDParser            *nullParser;
  TDCollectionParser  *booleanParser;
  TDCollectionParser  *commaValueParser;
  TDCollectionParser  *propertyParser;
  TDCollectionParser  *valueParser;
  TDCollectionParser  *arrayParser;
  TDCollectionParser  *commaPropertyParser;
}

@property (readonly)  TDToken             *bracket;
@property (readonly)  TDToken             *brace;
@property (readonly)  TDCollectionParser  *hashParser;
@property (readonly)  TDParser            *stringParser;
@property (readonly)  TDParser            *numberParser;
@property (readonly)  TDParser            *nullParser;
@property (readonly)  TDCollectionParser  *booleanParser;
@property (readonly)  TDCollectionParser  *commaValueParser;
@property (readonly)  TDCollectionParser  *propertyParser;
@property (readonly)  TDCollectionParser  *valueParser;
@property (readonly)  TDCollectionParser  *arrayParser;
@property (readonly)  TDCollectionParser  *commaPropertyParser;

- (NSDictionary *)parseHash:(NSString *)hash;

@end
