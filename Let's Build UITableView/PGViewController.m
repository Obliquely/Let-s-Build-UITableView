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


- (PGTableViewCell*) pgTableView:(PGTableView*) pgTableView cellForRow:(NSInteger)row;
{
    static NSString* pgStandardRowReuseIdentifier = @"standard row";
    
    PGTableViewCell* cell = [pgTableView  dequeueReusableCellWithIdentifier: pgStandardRowReuseIdentifier];
    if (!cell)
    {
        cell = [[PGTableViewCell alloc] initWithReuseIdentifier: pgStandardRowReuseIdentifier];
        [cell autorelease];
        
        UITextView* textView = [[UITextView alloc] initWithFrame: CGRectZero];
        [textView setTag: 101];
        [cell addSubview: textView];
        [textView release];
    }
    
    UITextView* textView = (UITextView*) [cell viewWithTag: 101];
    [textView setText: [[self tableRows] objectAtIndex: row]];
    [textView sizeToFit];
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource: @"Documentation" withExtension: @"txt"];
    NSString* superString = [[NSString alloc] initWithContentsOfURL: fileURL encoding: NSUTF8StringEncoding error:nil];
    
    NSArray* sampleRows = [superString componentsSeparatedByString:@"\n\n"];
    [self setTableRows: sampleRows];
    
    [self setPgTableView: (PGTableView*)[self view]];
    
    [[self pgTableView] setRowHeight: 40.0];  // default value for row height
    [[self pgTableView] setContentSize: CGSizeMake(640.0, 2048.0)];
    [[self pgTableView] setScrollEnabled: YES];
    
    
    [[self pgTableView] performSelector: @selector(reloadData) withObject:nil afterDelay:2.0];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
