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
@property (nonatomic, retain) NSMutableSet* visibleRows;
@end

@implementation PGTableView

@synthesize reusePool = _pgReusePool;
@synthesize visibleRows = _pgVisibleRows;
@synthesize rowRecords = _pgRowRecords;

#pragma mark - init and dealloc

- (void) dealloc;
{
    [_pgReusePool release];
    [_pgVisibleRows release];
    [_pgRowRecords release];
    [super dealloc];
}


- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        [self setup]; // called if xib created
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];   // called if programmatically created
    }
    return self;
}


#pragma mark - public methods

- (PGTableViewCell*) dequeueReusableCellWithIdentifier: (NSString*) reuseIdentifier;
{
    PGTableViewCell* poolCell = nil;
    
    for (PGTableViewCell* tableViewCell in [self reusePool])
    {
        if ([[tableViewCell reuseIdentifier] isEqualToString: reuseIdentifier])
        {
            poolCell = tableViewCell;
            break;
        }
    }
    
    if (poolCell)
    {
        [poolCell retain];
        [[self reusePool] removeObject: poolCell];
        return [poolCell autorelease];
    }

    return nil;
}


- (void) reloadData;
{
    [self generateHeightAndOffsetData];
    [self layoutTableRows];
}


#pragma mark - scrollView overrides

- (void) setContentOffset:(CGPoint)contentOffset; //  note: this method called frequently - needs to be fast
{
    [super setContentOffset: contentOffset];
    [self layoutTableRows];
}


#pragma mark - layout the table rows

- (void) layoutTableRows;
{
    if ([self layoutTableRowsBailCheck]) return;
    
    CGFloat currentStartY = [self contentOffset].y;
    CGFloat currentEndY = currentStartY + [self frame].size.height;
    
    NSInteger rowToDisplay = [self findRowForOffsetY: currentStartY inRange: NSMakeRange(0, [[self rowRecords] count])];
   
    NSMutableSet* currentVisibleRows = [NSMutableSet set];
    
    CGFloat yOrigin;
    CGFloat rowHeight;
    do
    {
        [currentVisibleRows addObject: [NSNumber numberWithInteger: rowToDisplay]];
        
        PGTableViewCell* cell = [self cachedCellForRow: rowToDisplay];
        
        if (!cell)
        {
            cell = [[self dataSource] pgTableView: self cellForRow: rowToDisplay];
            [self setCachedCell: cell forRow: rowToDisplay];
            
            yOrigin = [self startPositionYForRow: rowToDisplay];
            rowHeight = [self heightForRow: rowToDisplay];
            
            [cell setFrame: CGRectMake(0.0, yOrigin, [self bounds].size.width, rowHeight)];
            [self addSubview: cell];
        }
        
        rowToDisplay++;
    }
    while (yOrigin + rowHeight < currentEndY && rowToDisplay < [[self rowRecords] count]);
    
    NSMutableSet* interimSet = [[self visibleRows] retain];
    [self setVisibleRows: currentVisibleRows];
    
    [interimSet minusSet: currentVisibleRows];  // interimSet now represents the ceased to be visible rows
    
    for (NSNumber* rowNumber in interimSet)
    {
        NSInteger row = [rowNumber integerValue];
        PGTableViewCell* tableViewCell = [self cachedCellForRow: row];
        if (tableViewCell)
        {
            [[self reusePool] addObject: tableViewCell];
            [tableViewCell removeFromSuperview];
            [self setCachedCell: nil forRow: row];
        }
    }
    
    [interimSet release];
}


- (void) generateHeightAndOffsetData;
{
    CGFloat topMargin = 2.0;
    CGFloat bottomMargin = 0.0;
    
    CGFloat currentOffsetY = 0.0;
    
    BOOL checkHeightForEachRow = [[self delegate] respondsToSelector: @selector(pgTableView:heightForRow:)];
    
    NSMutableArray* rowRecords = [NSMutableArray array];
    
    NSInteger numberOfRows = [[self dataSource] numberOfRowsInTableView: self];

    for (NSInteger row = 0; row < numberOfRows; row++)
    {
        PGRowRecord* rowRecord = [[PGRowRecord alloc] init];
        CGFloat rowHeight = checkHeightForEachRow ? [[self delegate] pgTableView: self heightForRow: row] : [self rowHeight];
        
        [rowRecord setHeight: rowHeight + topMargin + bottomMargin];
        [rowRecord setStartPositionY: currentOffsetY + topMargin];
        
        [rowRecords insertObject: rowRecord atIndex: row];
        [rowRecord release];
        
        currentOffsetY = currentOffsetY + rowHeight + topMargin + bottomMargin;
    }
    
    [self setRowRecords: [[rowRecords copy] autorelease]];
    
    [self setContentSize: CGSizeMake([self bounds].size.width,  currentOffsetY)];
}


- (NSInteger) findRowForOffsetY: (CGFloat) yPosition inRange: (NSRange) range;
{
    if (range.length < 2)
    {
        return (range.location<1) ? range.location : range.location - 1;
    }
    
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



#pragma mark - query internal cache of positions and heights

- (CGFloat) startPositionYForRow: (NSInteger) row;
{
    return [(PGRowRecord*)[[self rowRecords] objectAtIndex: row] startPositionY];
}

- (CGFloat) heightForRow: (NSInteger) row;
{
    return [(PGRowRecord*)[[self rowRecords] objectAtIndex: row] height];
}

- (PGTableViewCell*) cachedCellForRow: (NSInteger) row;
{
    return [(PGRowRecord*)[[self rowRecords] objectAtIndex: row] cachedCell];
}

- (void) setCachedCell: (PGTableViewCell*) cell forRow: (NSInteger) row;
{
    [(PGRowRecord*)[[self rowRecords] objectAtIndex: row] setCachedCell: cell];
}


#pragma mark - service methods

- (BOOL) layoutTableRowsBailCheck;
{
    if (![self dataSource]) return YES; // don't attempt layout if no data source
    if (![self rowRecords]) return YES; // don't attempt layout if we have no row records
    
    if (![[self dataSource] respondsToSelector:@selector(pgTableView:cellForRow:)])
    {
        NSLog(@"** WARNING ** PGTableView dataSource, %@, does not response to pgTableView:cellForRow: - table view will not work without a conforming data source", [self dataSource]);
        return YES;
    }
    
    return NO; // safe to proceed
}

- (void) setup;
{
    [self setRowHeight: 40.0];  // default value for row height
}


#pragma mark - lazy instantiation

- (NSMutableSet*) reusePool;
{
    if (!_pgReusePool)
    {
        _pgReusePool = [[NSMutableSet alloc] init];
    }
    
    return _pgReusePool;
}

- (NSMutableSet*) visibleRows;
{
    if (!_pgVisibleRows)
    {
        _pgVisibleRows = [[NSMutableSet alloc] init];
    }
    
    return _pgVisibleRows;
}

@end
