//
//  ParamParser.m
//  Spike
//
//  Created by Matt Mower on 17/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "ParamParser.h"

#import <TDParseKit/TDParseKit.h>
#import "NSString+TDParseKitAdditions.h"

#import "Parameter.h"

@interface ParamParser (PrivateMethods)

- (NSString *)grammarPath;

- (void)workOnStringAssembly:(TDAssembly *)assembly;
- (void)workOnNullAssembly:(TDAssembly *)assembly;
- (void)workOnBooleanAssembly:(TDAssembly *)assembly;
- (void)workOnNumberAssembly:(TDAssembly *)assembly;
- (void)workOnArrayAssembly:(TDAssembly *)assembly;
- (void)workOnObjectAssembly:(TDAssembly *)assembly;
- (void)workOnPropertyAssembly:(TDAssembly *)assembly;

@end

static TDToken *arrayStartToken;
static TDToken *objectStartToken;

@implementation ParamParser

+ (void)initialize {
  if( objectStartToken == nil ) {
    objectStartToken = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"{" floatValue:0.0];
  }
  if( arrayStartToken == nil ) {
    arrayStartToken = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"[" floatValue:0.0];
  }
}

- (id)init {
  if( ( self = [super init] ) ) {
	  NSString *rubyHashGrammar = [NSString stringWithContentsOfFile:[self grammarPath]
															encoding:NSUTF8StringEncoding
															   error:nil];
//	  NSString *rubyHashGrammar = [NSString stringWithContentsOfFile:[self grammarPath]
//															encoding:NSUnicodeStringEncoding
//															   error:nil];
	  parser = [[TDParserFactory factory] parserFromGrammar:rubyHashGrammar
                                                assembler:self
                                             getTokenizer:&tokenizer];

  }

  return self;
}


@synthesize parser;
@synthesize tokenizer;


- (NSString *)grammarPath {
  return [[NSBundle bundleForClass:[self class]] pathForResource:@"rubyhash"
                                                          ofType:@"grammar"];
}


- (NSArray *)parseParams:(NSString *)unparsedParams {
  [[self tokenizer] setString:unparsedParams];

  TDTokenAssembly *assembly = [TDTokenAssembly assemblyWithTokenizer:tokenizer];
  TDAssembly *result = [[self parser] bestMatchFor:assembly];

  return [result pop];
}


- (void)workOnStringAssembly:(TDAssembly *)assembly {
  TDToken *tok = [assembly pop];
  [assembly push:[[tok stringValue] stringByTrimmingQuotes]];
}


- (void)workOnNumberAssembly:(TDAssembly *)assembly {
  TDToken *tok = [assembly pop];
  [assembly push:[NSNumber numberWithFloat:[tok floatValue]]];
}


- (void)workOnNullAssembly:(TDAssembly *)assembly {
  [assembly push:[NSNull null]];
}


- (void)workOnBooleanAssembly:(TDAssembly *)assembly {
  TDToken *token = [assembly pop];
  [assembly push:[NSNumber numberWithBool:[[token stringValue] isEqualToString:@"true"] ? YES : NO]];
}


- (void)workOnPropertyAssembly:(TDAssembly *)assembly {
  id value = [assembly pop];
  [assembly pop]; // discard =>
  TDToken *tok = [assembly pop];
  NSString *key = [[tok stringValue] stringByTrimmingQuotes];

  Parameter *param = [[Parameter alloc] initWithName:key];
  if( [value isKindOfClass:[NSArray class]] ) {
    [param setGroupedParams:value];
  } else {
    [param setValue:value];
  }

  [assembly push:param];
}


- (void)workOnArrayAssembly:(TDAssembly *)assembly {
  NSArray *elements = [assembly objectsAbove:arrayStartToken];

  NSMutableString *product = [[NSMutableString alloc] init];
  for( id element in [elements reverseObjectEnumerator] ) {
    if( [element isKindOfClass:[TDToken class]] ) {
      continue;
    }
    [product appendFormat:@"%@%@", [product length] > 0 ? @"," : @"", element];
  }

  [assembly pop]; // pop the [
  [assembly push:product];
}


- (void)workOnObjectAssembly:(TDAssembly *)assembly {
  NSArray *elements = [assembly objectsAbove:objectStartToken];

  NSMutableArray *params = [NSMutableArray arrayWithCapacity:[elements count]];

  for( id element in elements ) {
    if( [element isKindOfClass:[Parameter class]] ) {
      [params addObject:element];
    }
  }

  [assembly pop]; // pop the {
  [assembly push:params];
}


@end
