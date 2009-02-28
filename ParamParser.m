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

@implementation ParamParser

- (id)init {
  if( ( self = [super init] ) ) {
    NSString *rubyHashGrammar = [NSString stringWithContentsOfFile:[self grammarPath]
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
    parser = [[TDParserFactory factory] parserFromGrammar:rubyHashGrammar
                                                assembler:self
                                             getTokenizer:&tokenizer];
    TDReleaseSubparserTree( parser );
    NSLog( @"Built parser = %@", parser );
  }
  
  return self;
}


- (BOOL)respondsToSelector:(SEL)selector {
  BOOL doesRespond = [super respondsToSelector:selector];
  NSLog( @"respondsToSelector:%@ -> %@", NSStringFromSelector(selector), doesRespond ? @"YES" : @"NO" );
  return doesRespond;
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
  NSLog( @"workOnPropertyAssembly: %@", assembly );
  // id value = [assembly pop];
  // TDToken *tok = [assembly pop];
  // NSString *key = [[tok stringValue] stringByTrimmingQuotes];
  // 
  // [assembly push:key];
  // [assembly push:value];
}


- (void)workOnValueAssembly:(TDAssembly *)assembly {
  NSLog( @"workOnValueAssembly: %@", assembly );
}


- (void)workOnArrayAssembly:(TDAssembly *)assembly {
  NSLog( @"workOnArrayAssembly: %@", assembly );
  // NSArray *elements = [assembly objectsAbove:[self bracket]];
  // NSMutableArray *array = [NSMutableArray arrayWithCapacity:elements.count];
  // 
  // for( id element in [elements reverseObjectEnumerator] ) {
  //   if( element ) {
  //       [array addObject:element];
  //   }
  // }
  // [assembly pop]; // pop the [
  // [assembly push:array];
}


- (void)workOnObjectAssembly:(TDAssembly *)assembly {
  NSLog( @"workOnObjectAssebly: %@", assembly );
  // NSArray *elements = [assembly objectsAbove:[self brace]];
  // 
  // NSMutableArray *params = [NSMutableArray arrayWithCapacity:[elements count]/2];
  // 
  // int i = 0;
  // while( i < [elements count] ) {
  //   id value = [elements objectAtIndex:i];
  //   NSString *name = [elements objectAtIndex:i+1];
  // 
  //   if( name && value ) {
  //     Parameter *param = [[Parameter alloc] initWithName:name];
  //     if( [value isKindOfClass:[NSArray class]] ) {
  //       [param setGroupedParams:value];
  //     } else {
  //       [param setValue:value];
  //     }
  //     [params addObject:param];
  //   }
  //   
  //   i += 2;
  // }
  // 
  // [assembly pop]; // pop the {
  // [assembly push:params];
}


@end
