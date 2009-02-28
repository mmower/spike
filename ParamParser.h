//
//  ParamParser.h
//  Spike
//
//  Created by Matt Mower on 17/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// @class TDToken;
@class TDParser;
@class TDTokenizer;
// @class TDCollectionParser;

@interface ParamParser : NSObject {
  TDTokenizer         *tokenizer;
  TDParser            *parser;
  // TDToken             *bracket;
  // TDToken             *brace;
  // TDCollectionParser  *hashParser;
  // TDParser            *stringParser;
  // TDParser            *numberParser;
  // TDParser            *nullParser;
  // TDCollectionParser  *booleanParser;
  // TDCollectionParser  *commaValueParser;
  // TDCollectionParser  *propertyParser;
  // TDCollectionParser  *valueParser;
  // TDCollectionParser  *arrayParser;
  // TDCollectionParser  *commaPropertyParser;
}

@property (readonly)  TDTokenizer         *tokenizer;
@property (readonly)  TDParser            *parser;
// @property (readonly)  TDToken             *bracket;
// @property (readonly)  TDToken             *brace;
// @property (readonly)  TDCollectionParser  *hashParser;
// @property (readonly)  TDParser            *stringParser;
// @property (readonly)  TDParser            *numberParser;
// @property (readonly)  TDParser            *nullParser;
// @property (readonly)  TDCollectionParser  *booleanParser;
// @property (readonly)  TDCollectionParser  *commaValueParser;
// @property (readonly)  TDCollectionParser  *propertyParser;
// @property (readonly)  TDCollectionParser  *valueParser;
// @property (readonly)  TDCollectionParser  *arrayParser;
// @property (readonly)  TDCollectionParser  *commaPropertyParser;

- (NSArray *)parseParams:(NSString *)unparsedParams;

@end
