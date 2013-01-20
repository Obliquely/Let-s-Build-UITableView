//
//  PGRowRecord.m
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import "PGRowRecord.h"

@implementation PGRowRecord

- (void) dealloc;
{
    [_cachedCell release];
    [super dealloc];
}

- (NSString*) description;
{
    UITextView* textView = (UITextView*)[[self cachedCell] viewWithTag: 101];
    NSString* text = [textView text];
    if ([text length] > 20)
    {
        text = [text substringToIndex: 20];
    }

    return [NSString stringWithFormat: @"PGRowRecord: cachedCell %@ ('%@'); start %.2f height: %.2f", [self cachedCell], text, [self startPositionY], [self height]];

}
@end
