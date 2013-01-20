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

- (NSInteger) numberOfRowsInTableView:(PGTableView *)tableView;
{
    return [[self tableRows] count];
}

- (CGFloat) pgTableView:(PGTableView *)pgTableView heightForRow:(NSInteger)row;
{
    NSString* rowString = [[self tableRows] objectAtIndex: row];
    CGFloat height = [rowString sizeWithFont: [UIFont systemFontOfSize: 13.0] constrainedToSize: CGSizeMake(320.0 - 16.0, MAXFLOAT) lineBreakMode: NSLineBreakByWordWrapping].height;
    return height + 16.0;
}


- (PGTableViewCell*) pgTableView:(PGTableView*) pgTableView cellForRow:(NSInteger)row;
{
    static NSString* pgStandardRowReuseIdentifier = @"standard row";
    
    PGTableViewCell* cell = [pgTableView  dequeueReusableCellWithIdentifier: pgStandardRowReuseIdentifier];
    if (!cell)
    {
        cell = [[PGTableViewCell alloc] initWithReuseIdentifier: pgStandardRowReuseIdentifier];
        [cell autorelease];
        
        UITextView* textView = [[UITextView alloc] initWithFrame: CGRectZero];
        [textView setFont: [UIFont systemFontOfSize: 13.0]];
        [textView setTag: 101];
        [textView setScrollEnabled: NO];
        [textView setEditable: NO];
        [cell addSubview: textView];
        [textView release];
    }
    
    UITextView* textView = (UITextView*) [cell viewWithTag: 101];
    [textView setText: [[self tableRows] objectAtIndex: row]];
    [textView setFrame: CGRectMake(0.0, 0.0, 320.0, [self pgTableView: nil heightForRow: row])];
    
    return cell;
}


- (void) refresh;
{
    [[self pgTableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle: @"PGTableView Demo"];
    
    UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(refresh)];
    
    [self setToolbarItems: [NSArray arrayWithObjects: refresh, nil]];
    
    [[self navigationController] setToolbarHidden: NO];
    
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource: @"Documentation" withExtension: @"txt"];
    NSString* superString = [[NSString alloc] initWithContentsOfURL: fileURL encoding: NSUTF8StringEncoding error:nil];
    
    NSArray* sampleRows = [superString componentsSeparatedByString:@"\n\n"];
    [self setTableRows: sampleRows];
    
    [self setPgTableView: (PGTableView*)[self view]];
    
    [[self pgTableView] setRowHeight: 40.0];  // default value for row height
    [[self pgTableView] setContentSize: CGSizeMake(640.0, 2048.0)];
    [[self pgTableView] setScrollEnabled: YES];
    
    [[self pgTableView] setBackgroundColor: [UIColor lightGrayColor]];
    
    [[self pgTableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
