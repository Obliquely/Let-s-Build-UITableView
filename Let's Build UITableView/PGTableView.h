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

@property (nonatomic) CGFloat rowHeight; // default to 40.0 - ignored if delegate responds to pgTableView:heightForRow:
@property (nonatomic) CGFloat rowMargin; // default to 2.0

- (PGTableViewCell*) dequeueReusableCellWithIdentifier: (NSString*) reuseIdentifier;
- (void) reloadData;

- (void) row: (NSInteger) row changedHeight: (CGFloat) height;  // change height of one row w/o triggering request for row heights

- (NSIndexSet*) indexSetOfVisibleRows;

// exposed here so we can run test measurements - but not part of public interface
- (NSInteger) findRowForOffsetY: (CGFloat) yPosition inRange: (NSRange) range;
- (NSInteger) inefficientFindRowForOffsetY: (CGFloat) yPosition inRange: (NSRange) range;
@property (nonatomic) BOOL disablePool;


@end


@protocol PGTableViewDataSource<NSObject>

@required
- (NSInteger) numberOfRowsInPgTableView: (PGTableView*) tableView;
- (PGTableViewCell*) pgTableView:(PGTableView *)pgTableView cellForRow: (NSInteger) row;

@end



