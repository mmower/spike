//
//  TDParseKit.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 1/21/06.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

/*!
    @mainpage   TDParseKit
                TDParseKit is a Mac OS X Framework written by Todd Ditchendorf in Objective-C 2.0 and released under the MIT Open Source License.
				The framework is an Objective-C implementation of the tools described in <a href="http://www.amazon.com/Building-Parsers-Java-Steven-Metsker/dp/0201719622" title="Amazon.com: Building Parsers With Java(TM): Steven John Metsker: Books">"Building Parsers with Java" by Steven John Metsker</a>. 
				TDParseKit includes some significant additions beyond the designs from the book (many of them hinted at in the book itself) in order to enhance the framework's feature set, usefulness and ease-of-use. Other changes have been made to the designs in the book to match common Cocoa/Objective-C design patterns and conventions. 
				However, these changes are relatively superficial, and Metsker's book is the best documentation available for this framework.
                
                Classes in the TDParseKit Framework offer 2 basic services of general use to Cocoa developers:
    @li Tokenization via a tokenizer class
    @li Parsing via a high-level parser-building toolkit
                Learn more on the <a target="_top" href="http://code.google.com/p/todparsekit/">project site</a>
*/
 
#import <Foundation/Foundation.h>

// io
#import <TDParseKit/TDReader.h>

// parse
#import <TDParseKit/TDParser.h>
#import <TDParseKit/TDAssembly.h>
#import <TDParseKit/TDSequence.h>
#import <TDParseKit/TDCollectionParser.h>
#import <TDParseKit/TDAlternation.h>
#import <TDParseKit/TDRepetition.h>
#import <TDParseKit/TDEmpty.h>
#import <TDParseKit/TDTerminal.h>
#import <TDParseKit/TDTrack.h>
#import <TDParseKit/TDTrackException.h>

//chars
#import <TDParseKit/TDCharacterAssembly.h>
#import <TDParseKit/TDChar.h>
#import <TDParseKit/TDSpecificChar.h>
#import <TDParseKit/TDLetter.h>
#import <TDParseKit/TDDigit.h>

// tokens
#import <TDParseKit/TDToken.h>
#import <TDParseKit/TDTokenizer.h>
#import <TDParseKit/TDTokenArraySource.h>
#import <TDParseKit/TDTokenAssembly.h>
#import <TDParseKit/TDTokenizerState.h>
#import <TDParseKit/TDNumberState.h>
#import <TDParseKit/TDQuoteState.h>
#import <TDParseKit/TDCommentState.h>
#import <TDParseKit/TDSingleLineCommentState.h>
#import <TDParseKit/TDMultiLineCommentState.h>
#import <TDParseKit/TDSymbolNode.h>
#import <TDParseKit/TDSymbolRootNode.h>
#import <TDParseKit/TDSymbolState.h>
#import <TDParseKit/TDWordState.h>
#import <TDParseKit/TDWhitespaceState.h>
#import <TDParseKit/TDWord.h>
#import <TDParseKit/TDNum.h>
#import <TDParseKit/TDQuotedString.h>
#import <TDParseKit/TDSymbol.h>
#import <TDParseKit/TDComment.h>
#import <TDParseKit/TDLiteral.h>
#import <TDParseKit/TDCaseInsensitiveLiteral.h>
#import <TDParseKit/TDAny.h>

// ext
#import <TDParseKit/TDScientificNumberState.h>
#import <TDParseKit/TDWordOrReservedState.h>
#import <TDParseKit/TDUppercaseWord.h>
#import <TDParseKit/TDLowercaseWord.h>
#import <TDParseKit/TDReservedWord.h>
#import <TDParseKit/TDNonReservedWord.h>