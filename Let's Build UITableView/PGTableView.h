//
//  PGTableView.h
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import <UIKit/UIKit.h>

#import "PGTableViewCell.h"

@class PGTableView;

@protocol PGTableViewDelegate<NSObject, UIScrollViewDelegate>

@optional
- (CGFloat)pgTableView:(PGTableView*) pgTableView heightForRow: (NSInteger) row;

@end

@protocol PGTableViewDataSource;

@interface PGTableView : UIScrollView

@property (nonatomic, assign) IBOutlet id<PGTableViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<PGTableViewDelegate> delegate;

@property (nonatomic) CGFloat rowHeight; // will return the default value if unset

- (PGTableViewCell*) dequeueReusableCellWithIdentifier: (NSString*) reuseIdentifier;
- (void) reloadData;

@end


@protocol PGTableViewDataSource<NSObject>

@required
- (NSInteger) numberOfRowsInTableView: (PGTableView*) tableView;
- (PGTableViewCell*) pgTableView:(PGTableView *)pgTableView cellForRow: (NSInteger) row;

@end



