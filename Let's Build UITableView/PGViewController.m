//
//  PGViewController.m
//  Let's Build UITableView
//
//  Created by Matthew Elton on 19/01/2013.
//  www.obliquely.org.uk
//

#import "PGViewController.h"

@interface PGViewController ()

@property (nonatomic, retain) NSArray* tableRows;

@property (nonatomic, retain) PGTableView* pgTableView;
@property (nonatomic, retain) UIBarButtonItem* poolBarButtonItem;

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
    else if ([rowString hasPrefix: @"    "])
    {
        font = [UIFont fontWithName: @"CourierNewPSMT" size: 12.0];
        rowString = [self codeStringFromRowString: rowString];
    }

    CGFloat height = [rowString sizeWithFont: font constrainedToSize: CGSizeMake([[self pgTableView] bounds].size.width - 16.0, MAXFLOAT) lineBreakMode: NSLineBreakByWordWrapping].height;
    
    return height + 16.0;
}


- (NSString*) codeStringFromRowString: rowString;
{
    NSArray* codeBlock = [rowString componentsSeparatedByString:@"\n"];
    NSMutableString* codeString = [[[NSMutableString alloc] init] autorelease];
    for (NSString* string in codeBlock)
    {
        [codeString appendFormat:@"%@\n", ([string length] > 4) ? [string substringFromIndex:4] : string];
    }
    
    return [[codeString copy] autorelease];
}

//  The two different types of row are somewhat contrived here, but illustrate the pool mechanism.

- (PGTableViewCell*) pgTableView:(PGTableView*) pgTableView cellForRow:(NSInteger)row;
{
    static NSString* pgStandardRowReuseIdentifier = @"Text";
    static NSString* pgBoldRowReuseIdentifier = @"Heading";
    static NSString* pgCodeRowReuseIdentifier = @"Code";
    
    NSString* rowString = [[self tableRows] objectAtIndex: row];
    
    NSString* reuseIdentifier = pgStandardRowReuseIdentifier;
    UIFont* font = [UIFont systemFontOfSize: 13.0];

    
    if ([rowString hasPrefix: @"#"])
    {
        reuseIdentifier = pgBoldRowReuseIdentifier;
        font = [UIFont boldSystemFontOfSize: 15.0];
        rowString = [rowString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" #"]];
    }
    else if  ([rowString hasPrefix: @"    "])
    {
        reuseIdentifier = pgCodeRowReuseIdentifier;
        font = [UIFont fontWithName: @"CourierNewPSMT" size: 12.0];
        rowString = [self codeStringFromRowString: rowString];
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
    
    
    startDate = [NSDate date];
    [[self pgTableView] reloadData];
    NSTimeInterval reloadTime = - [startDate timeIntervalSinceNow];
    
    NSLog(@"Table has: %d rows. reloadData took: %.4f", rows, reloadTime);
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Test Results"
                                                    message: [NSString stringWithFormat: @"%d rows\n reloadData took: %.4fs\nFast FindRow is %.2f x better", rows, reloadTime, inEfficientTime/efficientTime]
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Double Rows", nil];
    [alert show];
    [alert release];
}


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) return;
    
    NSArray* biggerTable = [[self tableRows] arrayByAddingObjectsFromArray: [self tableRows]];
    [self setTableRows: biggerTable];
    [[self pgTableView] reloadData];
    [self runTest];
}

- (void) poolToggle;
{
    if ([[[self poolBarButtonItem] title] isEqualToString: @"Pool ✗"])
    {
        [[self poolBarButtonItem] setTitle: @"Pool ✓"];
        [[self pgTableView] setDisablePool: NO];
        return;
    }
    
    [[self poolBarButtonItem] setTitle: @"Pool ✗"];
    [[self pgTableView] setDisablePool: YES];
}

#pragma mark - rotation

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[self pgTableView] reloadData];
}


#pragma mark - service methods

- (void) populateTableFromFile: (NSString*) filename;
{
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource: filename withExtension: @"txt"];
    NSString* superString = [[NSString alloc] initWithContentsOfURL: fileURL encoding: NSUTF8StringEncoding error:nil];
    
    NSArray* sampleRows = [superString componentsSeparatedByString:@"\n\n"];
    [self setTableRows: sampleRows];
    [superString release];
}


- (void) setupToolbar;
{
    UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(refresh)];
    
    UIBarButtonItem* test = [[UIBarButtonItem alloc] initWithTitle: @"Test" style: UIBarButtonItemStyleBordered target: self action:@selector(runTest)];
    
    UIBarButtonItem* foot = [[UIBarButtonItem alloc] initWithTitle: @"⬇" style: UIBarButtonItemStylePlain target: self action:@selector(gotoFoot)];
    
    UIBarButtonItem* pool = [[UIBarButtonItem alloc] initWithTitle: @"Pool ✓" style: UIBarButtonItemStyleBordered target: self action:@selector(poolToggle)];
    [self setPoolBarButtonItem: pool];
    
    
    
    UIBarButtonItem* heightTweak = [[UIBarButtonItem alloc] initWithTitle: @"Grow" style: UIBarButtonItemStyleBordered target:  self action:@selector(growRow)];
    
    UIBarButtonItem* flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems: [NSArray arrayWithObjects: refresh, pool, flexibleSpace1, foot, flexibleSpace2, heightTweak, test, nil]];
    
    [foot release];
    [heightTweak release];
    [test release];
    [refresh release];
    [flexibleSpace1 release];
    [flexibleSpace2 release];
    [pool release];
    
    [[self navigationController] setToolbarHidden: NO];
}

@end
