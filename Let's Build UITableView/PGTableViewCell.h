//
//  PGTableViewCell.h
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import <UIKit/UIKit.h>

@interface PGTableViewCell : UIView;

- (id) initWithReuseIdentifier: (NSString*) reuseIdentifier;

@property (nonatomic, retain) NSString* reuseIdentifier;

@end
