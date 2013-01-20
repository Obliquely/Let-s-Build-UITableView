//
//  PGViewController.m
//  Let's Build UITableView
//
//  Created by Maxwell Edison on 19/01/2013.
//  Copyright (c) 2013 Matthew Elton. All rights reserved.
//

#import "PGViewController.h"

@interface PGViewController ()

@property (nonatomic, retain) NSArray* tableRows;

@property (nonatomic, retain) PGTableView* pgTableView;

@end

@implementation PGViewController

- (void) dealloc;
{
    [_tableRows release];
    [_pgTableView release];
    [super dealloc];
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle: @"PGTableView Demo"];
    
    [self setupToolbar];
    [self populateTableFromFile: @"Documentation"];
    
    [self setPgTableView: (PGTableView*)[self view]];
        
    [[self pgTableView] setBackgroundColor: [UIColor lightGrayColor]];
    [[self pgTableView] reloadData];
}


#pragma mark - PGTableView dataSource and delegate methods

- (NSInteger) numberOfRowsInPgTableView:(PGTableView *)tableView;
{
    return [[self tableRows] count];
}

- (CGFloat) pgTableView:(PGTableView *)pgTableView heightForRow:(NSInteger)row;
{
    NSString* rowString = [[self tableRows] objectAtIndex: row];

    UIFont* font = [UIFont systemFontOfSize: 13.0];
    if ([rowString hasPrefix: @"#"])
    {
        font = [UIFont boldSystemFontOfSize: 15.0];
        rowString = [rowString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" #"]];
    }

    CGFloat height = [rowString sizeWithFont: font constrainedToSize: CGSizeMake([[self pgTableView] bounds].size.width - 16.0, MAXFLOAT) lineBreakMode: NSLineBreakByWordWrapping].height;
    
    return height + 16.0;
}


//  The two different types of row are somewhat contrived here, but illustrate the pool mechanism.

- (PGTableViewCell*) pgTableView:(PGTableView*) pgTableView cellForRow:(NSInteger)row;
{
    static NSString* pgStandardRowReuseIdentifier = @"Text";
    static NSString* pgBoldRowReuseIdentifier = @"Heading";
    
    NSString* rowString = [[self tableRows] objectAtIndex: row];
    
    NSString* reuseIdentifier = pgStandardRowReuseIdentifier;
    UIFont* font = [UIFont systemFontOfSize: 13.0];

    
    if ([rowString hasPrefix: @"#"])
    {
        reuseIdentifier = pgBoldRowReuseIdentifier;
        font = [UIFont boldSystemFontOfSize: 15.0];
        rowString = [rowString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" #"]];
    }

    PGTableViewCell* cell = [pgTableView  dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (!cell)
    {
        cell = [[PGTableViewCell alloc] initWithReuseIdentifier: reuseIdentifier];
        [cell autorelease];
        
        UITextView* textView = [[UITextView alloc] initWithFrame: CGRectZero];
    
        [textView setFont: font];
        [cell setClipsToBounds: YES];
        
        [textView setTag: 101];
        [textView setScrollEnabled: NO];
        [textView setEditable: NO];
        [cell addSubview: textView];
        [textView release];
    }
    
    UITextView* textView = (UITextView*) [cell viewWithTag: 101];
    [textView setText: rowString];
    [textView setFrame: CGRectMake(0.0, 0.0, [[self pgTableView] bounds].size.width, [self pgTableView: nil heightForRow: row] + 50.0)];    // + 50.0 is a hack to make growing rows look nice
    
    return cell;
}



#pragma mark - tool bar button actions

- (void) refresh;
{
    [self populateTableFromFile: @"Documentation"];
    [[self pgTableView] reloadData];
}

- (void) gotoFoot;
{
    CGFloat targetOffset = [[self pgTableView] contentSize].height - [[self pgTableView] bounds].size.height;
    [[self pgTableView] setContentOffset: CGPointMake(0.0, targetOffset) animated: YES];
}


- (void) growRow;
{
    NSIndexSet* visibleRows = [[self pgTableView] indexSetOfVisibleRows];
    NSInteger row = [visibleRows firstIndex];
    
    if ([visibleRows indexGreaterThanIndex: row] != NSNotFound && [[self pgTableView] contentOffset].y > 10.0)
    {
        row = row + 1;
    }
    
    CGFloat newHeight = [self pgTableView: [self pgTableView] heightForRow: row] + 50;
    
    [[self pgTableView] row: row changedHeight: newHeight];
}


- (void) runTest;
{
    NSDate* startDate = [NSDate date];
    NSInteger rows = [self numberOfRowsInPgTableView: [self pgTableView]];
    
    for (NSInteger index = 0; index < 1000; index++)
    {
        CGFloat yPosition = (CGFloat)(random() % (NSInteger) [[self pgTableView] contentSize].height);
        [[self pgTableView] findRowForOffsetY: yPosition inRange: NSMakeRange(0, rows)];
    }
    
    NSTimeInterval efficientTime = - [startDate timeIntervalSinceNow];
    
    startDate = [NSDate date];
    
    for (NSInteger index = 0; index < 1000; index++)
    {
        CGFloat yPosition = (CGFloat)(random() % (NSInteger) [[self pgTableView] contentSize].height);
        [[self pgTableView] inefficientFindRowForOffsetY: yPosition inRange: NSMakeRange(0, rows)];
    }
    
    NSTimeInterval inEfficientTime = - [startDate timeIntervalSinceNow];
    
    NSLog(@"For %d rows. Efficient: %.8f; Inefficient: %.8f; Inefficent/Efficient: %.1f", rows, efficientTime/1000, inEfficientTime/1000, inEfficientTime/efficientTime);
    
    // now double the length of the table
    
    NSArray* biggerTable = [[self tableRows] arrayByAddingObjectsFromArray: [self tableRows]];
    [self setTableRows: biggerTable];
    
    startDate = [NSDate date];
    [[self pgTableView] reloadData];
    NSTimeInterval reloadTime = - [startDate timeIntervalSinceNow];

    NSLog(@"Table now has: %d rows. reloadData took: %.4f", rows, reloadTime);
}





#pragma mark - service methods

- (void) populateTableFromFile: (NSString*) filename;
{
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource: filename withExtension: @"txt"];
    NSString* superString = [[NSString alloc] initWithContentsOfURL: fileURL encoding: NSUTF8StringEncoding error:nil];
    
    NSArray* sampleRows = [superString componentsSeparatedByString:@"\n\n"];
    [self setTableRows: sampleRows];

}


- (void) setupToolbar;
{
    UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(refresh)];
    
    UIBarButtonItem* test = [[UIBarButtonItem alloc] initWithTitle: @"Run Test" style: UIBarButtonItemStyleBordered target: self action:@selector(runTest)];
    
    UIBarButtonItem* foot = [[UIBarButtonItem alloc] initWithTitle: @"⬇" style: UIBarButtonItemStylePlain target: self action:@selector(gotoFoot)];
    
    UIBarButtonItem* heightTweak = [[UIBarButtonItem alloc] initWithTitle: @"Grow Row" style: UIBarButtonItemStyleBordered target:  self action:@selector(growRow)];
    
    UIBarButtonItem* flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems: [NSArray arrayWithObjects: refresh, heightTweak, flexibleSpace1, foot, flexibleSpace2, test, nil]];
    
    [foot release];
    [heightTweak release];
    [test release];
    [flexibleSpace1 release];
    [flexibleSpace2 release];
    
    [[self navigationController] setToolbarHidden: NO];
}

@end
