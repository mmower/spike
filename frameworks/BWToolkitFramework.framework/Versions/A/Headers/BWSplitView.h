//
//  BWSplitView.h
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@interface BWSplitView : NSSplitView 
{
	NSColor *color;
	BOOL colorIsEnabled, checkboxIsEnabled;
}

// The split view divider color
@property (copy) NSColor *color;

// Flag for whether a custom divider color is enabled. If not, the standard divider color is used.
@property BOOL colorIsEnabled;

@end
