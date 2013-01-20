//
//  PGTableViewCell.m
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import "PGTableViewCell.h"

@implementation PGTableViewCell

- (id) initWithReuseIdentifier: (NSString*) reuseIdentifier;
{
    self = [super initWithFrame: CGRectZero];
    if (self)
    {
        [self setReuseIdentifier: reuseIdentifier];
        [self setBackgroundColor: [UIColor lightGrayColor]];
    }
    return self;
}

//- (void) setFrame:(CGRect)frame;
//{
//    [super setFrame: frame];
//    
//    [[self viewWithTag: 101] setFrame: frame];
//}

@end
