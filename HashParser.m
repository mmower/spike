//
//  HashParser.m
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "HashParser.h"

#import <TDParseKit/TDParseKit.h>

#import "NSString+TDParseKitAdditions.h"

// Hash structure

// { "key" => "value", "key" => { hash }, ... }


@interface HashParser ()

- (void)workOnStringAssembly:(TDAssembly *)assembly;
- (void)workOnNullAssembly:(TDAssembly *)assembly;
- (void)workOnBooleanAssembly:(TDAssembly *)assembly;
- (void)workOnNumberAssembly:(TDAssembly *)assembly;
- (void)workOnArrayAssembly:(TDAssembly *)assembly;
- (void)workOnHashAssembly:(TDAssembly *)assembly;
- (void)workOnPropertyAssembly:(TDAssembly *)assembly;

@end


@implementation HashParser


- (id)init {
  if( ( self = [super init] ) ) {
  }
  
  return self;
}


@synthesize brace;

- (TDToken *)brace {
  if( !brace ) {
    brace = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"{" floatValue:0.0];
  }
  
  return brace;
}


@synthesize bracket;

- (TDToken *)bracket {
  if( !bracket ) {
    bracket = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"[" floatValue:0.0];
  }
  
  return bracket;
}


@synthesize stringParser;

- (TDParser *)stringParser {
  if( !stringParser ) {
    stringParser = [TDQuotedString quotedString];
    [stringParser setAssembler:self selector:@selector(workOnStringAssembly:)];
  }
  
  return stringParser;
}


- (void)workOnStringAssembly:(TDAssembly *)assembly {
  TDToken *tok = [assembly pop];
  [assembly push:[[tok stringValue] stringByTrimmingQuotes]];
}


@synthesize numberParser;

- (TDParser *)numberParser {
  if( !numberParser ) {
    numberParser = [TDNum num];
    [numberParser setAssembler:self selector:@selector(workOnNumberAssembly:)];
  }
  
  return numberParser;
}


- (void)workOnNumberAssembly:(TDAssembly *)assembly {
  TDToken *tok = [assembly pop];
  [assembly push:[NSNumber numberWithFloat:[tok floatValue]]];
}


@synthesize nullParser;

- (TDParser *)nullParser {
  if (!nullParser) {
    nullParser = [[TDLiteral literalWithString:@"null"] discard];
    [nullParser setAssembler:self selector:@selector(workOnNullAssembly:)];
  }
  
  return nullParser;
}


- (void)workOnNullAssembly:(TDAssembly *)assembly {
  [assembly push:[NSNull null]];
}


@synthesize booleanParser;

- (TDCollectionParser *)booleanParser {
  if (!booleanParser) {
    booleanParser = [TDAlternation alternation];
    [booleanParser add:[TDLiteral literalWithString:@"true"]];
    [booleanParser add:[TDLiteral literalWithString:@"false"]];
    [booleanParser setAssembler:self selector:@selector(workOnBooleanAssembly:)];
  }
  
  return booleanParser;
}


- (void)workOnBooleanAssembly:(TDAssembly *)assembly {
  TDToken *tok = [assembly pop];
  [assembly push:[NSNumber numberWithBool:[[tok stringValue] isEqualToString:@"true"] ? YES : NO]];
}


@synthesize commaValueParser;

- (TDCollectionParser *)commaValueParser {
  if( !commaValueParser ) {
    commaValueParser = [TDTrack sequence];
    [commaValueParser add:[[TDSymbol symbolWithString:@","] discard]];
    [commaValueParser add:[self valueParser]];
  }
  
  return commaValueParser;
}


@synthesize propertyParser;

- (TDCollectionParser *)propertyParser {
  if( !propertyParser ) {
    propertyParser = [TDSequence sequence];
    [propertyParser add:[TDQuotedString quotedString]];
    [propertyParser add:[[TDSymbol symbolWithString:@"=>"] discard]];
    [propertyParser add:[self valueParser]];
    [propertyParser setAssembler:self selector:@selector(workOnPropertyAssembly:)];
  }
  
  return propertyParser;
}


- (void)workOnPropertyAssembly:(TDAssembly *)assembly {
  id value = [assembly pop];
  TDToken *tok = [assembly pop];
  NSString *key = [[tok stringValue] stringByTrimmingQuotes];
  
  [assembly push:key];
  [assembly push:value];
}


@synthesize valueParser;

- (TDCollectionParser *)valueParser {
  if( !valueParser ) {
    valueParser = [TDAlternation alternation];
    [valueParser add:[self stringParser]];
    [valueParser add:[self numberParser]];
    [valueParser add:[self nullParser]];
    [valueParser add:[self booleanParser]];
    [valueParser add:[self arrayParser]];
    [valueParser add:[self hashParser]];
  }
  
  return valueParser;
}


@synthesize commaPropertyParser;

- (TDCollectionParser *)commaPropertyParser {
  if( !commaPropertyParser ) {
    commaPropertyParser = [TDTrack sequence];
    [commaPropertyParser add:[[TDSymbol symbolWithString:@","] discard]];
    [commaPropertyParser add:[self propertyParser]];
  }
  
  return commaPropertyParser;
}


@synthesize arrayParser;

- (TDCollectionParser *)arrayParser {
  if (!arrayParser) {
    
    // array = '[' content ']'
    // content = Empty | actualArray
    // actualArray = value commaValue*
    
    TDTrack *actualArray = [TDTrack sequence];
    [actualArray add:[self valueParser]];
    [actualArray add:[TDRepetition repetitionWithSubparser:[self commaValueParser]]];
    
    TDAlternation *content = [TDAlternation alternation];
    [content add:[TDEmpty empty]];
    [content add:actualArray];
    
    arrayParser = [TDSequence sequence];
    [arrayParser add:[TDSymbol symbolWithString:@"["]]; // serves as fence
    [arrayParser add:content];
    [arrayParser add:[[TDSymbol symbolWithString:@"]"] discard]];
    
    [arrayParser setAssembler:self selector:@selector(workOnArrayAssembly:)];
  }
  
  return arrayParser;
}


- (void)workOnArrayAssembly:(TDAssembly *)assembly {
  NSArray *elements = [assembly objectsAbove:[self bracket]];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:elements.count];
  
  for( id element in [elements reverseObjectEnumerator] ) {
    if( element ) {
        [array addObject:element];
    }
  }
  [assembly pop]; // pop the [
  [assembly push:array];
}


// object = '{' content '}'
// content = Empty | actualObject
// actualObject = property commaProperty*
// property = QuotedString ':' value
// commaProperty = ',' property
@synthesize hashParser;

- (TDCollectionParser *)hashParser {
  if( !hashParser ) {
    TDTrack *actualObject = [TDTrack sequence];
    [actualObject add:[self propertyParser]];
    [actualObject add:[TDRepetition repetitionWithSubparser:[self commaPropertyParser]]];
    
    TDAlternation *content = [TDAlternation alternation];
    [content add:[TDEmpty empty]];
    [content add:actualObject];
    
    hashParser = [TDSequence sequence];
    [hashParser add:[TDSymbol symbolWithString:@"{"]]; // serves as fence
    [hashParser add:content];
    [hashParser add:[[TDSymbol symbolWithString:@"}"] discard]];
    
    [hashParser setAssembler:self selector:@selector(workOnHashAssembly:)];
  }
  
  return hashParser;
}


- (void)workOnHashAssembly:(TDAssembly *)assembly {
  NSArray *elements = [assembly objectsAbove:[self brace]];
  NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:[elements count]/2];
  
  int i = 0;
  while( i < [elements count] ) {
    id value = [elements objectAtIndex:i];
    NSString *key = [elements objectAtIndex:i+1];
    if( key && value ) {
      [d setObject:value forKey:key];
    }
    i += 2;
  }
  
  [assembly pop]; // pop the {
  [assembly push:d];
}


- (NSDictionary *)parseHash:(NSString *)hash {
  TDTokenizer *tokenizer = [[TDTokenizer alloc] init];
  [tokenizer setString:hash];
  [tokenizer.symbolState add:@"=>"];
  
  TDTokenAssembly *assembly = [TDTokenAssembly assemblyWithTokenizer:tokenizer];
  
  TDAssembly *result = [[self hashParser] completeMatchFor:assembly];
  
  return [result pop];
}


@end
