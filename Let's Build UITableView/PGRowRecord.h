//
//  PGRowRecord.h
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import <Foundation/Foundation.h>
@class PGTableViewCell;

@interface PGRowRecord : NSObject

@property (nonatomic) CGFloat startPositionY;
@property (nonatomic) CGFloat height;
@property (nonatomic, retain) PGTableViewCell* cachedCell;

@end
