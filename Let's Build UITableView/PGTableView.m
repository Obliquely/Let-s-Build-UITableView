//
//  PGTableView.m
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import "PGTableView.h"
#import "PGRowRecord.h"
#import "PGTableViewCell.h"

@interface PGTableView ()

@property (nonatomic, retain) NSArray* rowRecords;
@property (nonatomic, retain) NSMutableSet* reusePool;
@property (nonatomic, retain) NSMutableSet* visibleCells;
@end

@implementation PGTableView

@synthesize reusePool = _pgReusePool;
@synthesize visibleCells = _pgVisibleCells;
@synthesize rowRecords = _pgRowRecords;


- (void) dealloc;
{
    [_pgReusePool release];
    [_pgVisibleCells release];
    [_pgRowRecords release];
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setRowHeight: 40.0];  // default value for row height
    }
    return self;
}

- (id) init;
{
    
    self = [super init];
    if (self)
    {
        [self setRowHeight: 40.0];  // default value for row height
    }
    return self;
}


- (NSInteger) findRowForOffsetY: (CGFloat) yPosition inRange: (NSRange) range;
{
    if (range.length < 2) return range.location;
    
    NSInteger halfwayMark = range.length / 2;
    
    if (yPosition > [self startPositionYForRow: range.location + halfwayMark])
    {
        return [self findRowForOffsetY: yPosition inRange: NSMakeRange(range.location + (halfwayMark + 1), range.length - (halfwayMark +1))];
    }
    else
    {
        return [self findRowForOffsetY: yPosition inRange: NSMakeRange(range.location, range.length - halfwayMark)];
    }
}

- (NSMutableSet*) reusePool;
{
    if (!_pgReusePool)
    {
        _pgReusePool = [[NSMutableSet alloc] init];
    }

    return _pgReusePool;
}

- (NSMutableSet*) visibleCells;
{
    if (_pgVisibleCells)
    {
        _pgVisibleCells = [[NSMutableSet alloc] init];
    }

    return _pgVisibleCells;
}


- (PGTableViewCell*) dequeueReusableCellWithIdentifier: (NSString*) reuseIdentifier;
{
    for (PGTableViewCell* tableViewCell in [self reusePool])
    {
        if ([[tableViewCell reuseIdentifier] isEqualToString: reuseIdentifier])
        {
            return tableViewCell;
        }
    }
    return nil;
}

- (CGFloat) startPositionYForRow: (NSInteger) row;
{
    return [(PGRowRecord*)[[self rowRecords] objectAtIndex: row] startPositionY];
}

- (CGFloat) heightForRow: (NSInteger) row;
{
    return [(PGRowRecord*)[[self rowRecords] objectAtIndex: row] height];
}


- (void) reloadData;
{
    NSInteger numberOfRows = [[self dataSource] numberOfRowsInTableView: self];

    [self getHeightsWithRowCount: numberOfRows];
    
    CGFloat currentStartY = [self contentOffset].y;
    CGFloat currentEndY = currentStartY + [self frame].size.height;
    
    NSInteger rowToDisplay = [self findRowForOffsetY: currentStartY inRange: NSMakeRange(0, numberOfRows)];
    
    PGTableViewCell* currentCell = nil;
    
    [[self reusePool] unionSet: [self visibleCells]];
    [[self visibleCells] removeAllObjects];
    
    NSLog(@"data source: %@; delegate: %@", [self dataSource], [self delegate]);
    
    if (![[self dataSource] respondsToSelector:@selector(pgTableView:cellForRow:)])
    {
        NSAssert(NO, @"datasource must respond to pgTableView:cellForRow:");
    }

    
    do {
        PGTableViewCell* cell = [[self dataSource] pgTableView: self cellForRow: rowToDisplay];

        CGFloat yOrigin = [self startPositionYForRow: rowToDisplay];
        CGFloat rowHeight = [self heightForRow: rowToDisplay];

        [cell setFrame: CGRectMake(0.0, yOrigin, [self bounds].size.width, rowHeight)];
        
        [[self reusePool] removeObject: cell];
        [[self visibleCells] addObject: cell];
        
        [self addSubview: cell];
    } while (currentCell.frame.origin.y + currentCell.frame.size.height < currentEndY);

}


- (void) getHeightsWithRowCount: (NSInteger) numberOfRows;
{
    CGFloat currentOffsetY = 0.0;
    
    BOOL checkHeightForEachRow = [[self delegate] respondsToSelector: @selector(pgTableView:heightForRow:)];
    
    NSMutableArray* rowRecords = [[NSMutableArray alloc] init];
    for (NSInteger row = 0; row < numberOfRows; row++)
    {
        PGRowRecord* rowRecord = [[PGRowRecord alloc] init];
        CGFloat rowHeight = checkHeightForEachRow ? [[self delegate] pgTableView: self heightForRow: row] : [self rowHeight];
        
        [rowRecord setHeight: rowHeight];
        [rowRecord setStartPositionY: currentOffsetY];
        
        [rowRecords insertObject: rowRecord atIndex: row];
        [rowRecord release];
        
        currentOffsetY = currentOffsetY + rowHeight;
    }
    
    [self setRowRecords: [[rowRecords copy] autorelease]];
    [rowRecords release];
    
    CGSize contentSize = CGSizeMake([self bounds].size.width,  currentOffsetY);
    NSLog(@"contentSize: %@", NSStringFromCGSize(contentSize));
    [self setContentSize: contentSize];
}

@end
