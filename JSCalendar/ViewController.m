//
//  ViewController.m
//  SACalendar
//
//  Created by Nop Shusang on 7/12/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License
//
//  Extended By John Setting on 11/07/14

#import "ViewController.h"
#import "SACalendar.h"
#import "DateUtil.h"
#import "JSLogWorkoutController.h"

@interface ViewController () <SACalendarDelegate, SACalendarDataSource, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDateFormatter *monthFormatter;
@property (nonatomic) NSDateFormatter *dayFormatter;
@property (nonatomic) NSDateFormatter *timeFormatter;
@property (nonatomic) SACalendar *calendarView;
@property (nonatomic) UITableView *table;
@property (nonatomic) NSMutableArray *dates;
@property (nonatomic) NSMutableArray *objects;
@property (nonatomic) NSDate *selectedDate;
@property (nonatomic) UILabel *navTitleView;
@property int previousDateRange;
@property int futureDateRange;
@property NSString *currentSelectedTitle;
@end

@implementation ViewController

- (id)init
{
    if (!(self = [super init])) return nil;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    self.dayFormatter = [[NSDateFormatter alloc] init];
    [self.dayFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
    
    self.monthFormatter = [[NSDateFormatter alloc] init];
    [self.monthFormatter setDateFormat:@"MM/yyyy"];

    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"hh:mm a"];

    /*
    self.navTitleView =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 120, 40)];
    [self.navTitleView setTextAlignment:NSTextAlignmentCenter];
    [self.navTitleView setUserInteractionEnabled:YES];
    [self.navTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(selectCurrentDay)]];
    self.navigationItem.titleView = self.navTitleView;
    */
     
     
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createWorkout:)];
    
    
    self.previousDateRange = -60;

    self.futureDateRange = 60;
    
    [self.view addSubview:self.calendarView];
    [self.view addSubview:self.table];

    self.selectedDate = [NSDate date];
    
    self.objects = [NSMutableArray arrayWithObjects:
                        @{@"name":@"Linda", @"date":[NSDate date]},
                        @{@"name":@"Grace", @"date":[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*-20)]},
                        @{@"name":@"Tabatha", @"date":[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*20 + 100)]},
                        @{@"name":@"Tabatha", @"date":[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*20)]},
                        @{@"name":@"Tabatha", @"date":[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*100)]},
                    nil];

    self.dates = [NSMutableArray array];
    
    for (int i = -60; i < 60; i++) {
        if (i == 0) [self.dates addObject:[self.dayFormatter stringFromDate:[NSDate date]]];
        else [self.dates addObject:[self.dayFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*i)]]];
    }
    
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:60] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)createWorkout:(UIBarButtonItem *)item
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[JSLogWorkoutController alloc] init]] animated:YES completion:nil];
}

- (NSArray *)objectsInDict:(NSString *)sectionTitle
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in self.objects) {
        if ([[self.dayFormatter stringFromDate:[dict objectForKey:@"date"]] isEqual:sectionTitle]) {
            [array addObject:dict];
        }
    }
    
    NSArray *narray = [NSArray arrayWithArray:array];
    
    narray = [narray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [[obj1 objectForKey:@"date"] compare:[obj2 objectForKey:@"date"]];
    }];
    
    return narray;
}

#pragma mark - Tableview Delegate/Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    int i = 0;
    for (NSDictionary *dict in self.objects)
        if ([[self.dayFormatter stringFromDate:[dict objectForKey:@"date"]] isEqual:sectionTitle])
            i++;
    if (i == 0)
        return 1;
    return i;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dates count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dates objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSIndexPath *firstVisibleIndexPath = [[self.table indexPathsForVisibleRows] objectAtIndex:0];
    NSString *secTitle = [self tableView:tableView titleForHeaderInSection:firstVisibleIndexPath.section];
    self.currentSelectedTitle = secTitle;
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    
    NSArray *array = [NSArray arrayWithArray:[self objectsInDict:sectionTitle]];
    if ([array count] == 0) {
        [[cell textLabel] setText:@"No Workouts"];
        [[cell detailTextLabel] setText:@""];
    } else {
        NSDictionary *dict = [array objectAtIndex:indexPath.row];
        [[cell textLabel] setText:[dict objectForKey:@"name"]];
        [[cell detailTextLabel] setText:[self.timeFormatter stringFromDate:[dict objectForKey:@"date"]]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSArray *array = [NSArray arrayWithArray:[self objectsInDict:sectionTitle]];
    if ([array count] > 0) {
        NSLog(@"%@", [array objectAtIndex:indexPath.row]);        
    }
}


#pragma mark - Scroller Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat currentOffsetX = scrollView_.contentOffset.x;
    CGFloat currentOffSetY = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height;
    
    if (currentOffSetY < (contentHeight / 8.0)) {
        [self addPastDatesToDataSource];
        scrollView_.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY + (contentHeight/2)));
    }
    if (currentOffSetY > ((contentHeight * 6)/ 8.0)) {
        [self addNextDatesToDataSource];
    }

    
    NSIndexPath *firstVisibleIndexPath = [[self.table indexPathsForVisibleRows] objectAtIndex:0];
    NSString *secTitle = [self tableView:self.table titleForHeaderInSection:firstVisibleIndexPath.section];
    
    if (![secTitle isEqualToString:self.currentSelectedTitle] && self.currentSelectedTitle) {
        self.currentSelectedTitle = secTitle;
        [self.calendarView selectDay:secTitle];
    }
    
}


#pragma mark - Calendar View Delegate
- (BOOL)SACalendar:(SACalendar *)calendar doesCellHaveEvent:(int)day month:(int)month year:(int)year
{
    for (NSDictionary *dict in self.objects) {
        if ([[self.dateFormatter stringFromDate:[dict objectForKey:@"date"]] isEqual:[NSString stringWithFormat:@"%02i/%02i/%04i", month, day, year]]) {
            return NO;
        }
    }    
    return YES;
}

- (void)SACalendar:(SACalendar *)calendar didScrollLeft:(UICollectionView *)collectionView day:(int)day month:(int)month year:(int)year
{
    /*
    NSDate *date = [self.monthFormatter dateFromString:[NSString stringWithFormat:@"%02i/%04i", month, year]];
    if ([self.dates indexOfObject:[self.dayFormatter stringFromDate:date]] == NSNotFound) 
        [self addPastDatesToDataSource];
    */
    
    /*
    if (self.scrolling) {
        NSLog(@"didScrollLeft Using Table");
    } else {
        NSLog(@"didScrollLeft Using Finger");
        NSDate *selectedDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%02i/%02i/%04i", month, day, year]];
        NSInteger index = [self.dates indexOfObject:[self.dayFormatter stringFromDate:selectedDate]];
        if (index != NSNotFound)
            [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    self.scrolling = NO;
    */

    //[self.calendarView collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    //[self.calendarView selectDay:[self.dayFormatter stringFromDate:date]];
}

- (void)SACalendar:(SACalendar *)calendar didScrollRight:(UICollectionView *)collectionView day:(int)day month:(int)month year:(int)year
{
    /*
    NSDate *curDate = [self.monthFormatter dateFromString:[NSString stringWithFormat:@"%02i/%04i", month, year]];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday fromDate:curDate];
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    NSDate *tDateMonth = [cal dateFromComponents:comps];
    if ([self.dates indexOfObject:[self.dayFormatter stringFromDate:tDateMonth]] == NSNotFound)
        [self addFutureDatesToDataSource];
    */
    
    /*
    if (self.scrolling) {
        NSLog(@"didScrollRight Using Table");
    } else {
        NSLog(@"didScrollRight Using Finger");
        NSDate *selectedDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%02i/%02i/%04i", month, day, year]];
        NSInteger index = [self.dates indexOfObject:[self.dayFormatter stringFromDate:selectedDate]];
        if (index != NSNotFound)
            [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    self.scrolling = NO;
    */
    
    
    //[self.calendarView collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    //[self.calendarView selectDay:[self.dayFormatter stringFromDate:tDateMonth]];
}

- (void)SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    self.selectedDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%02i/%02i/%04i", month, day, year]];
    NSString *ndate = [self.dayFormatter stringFromDate:self.selectedDate];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.dates indexOfObject:ndate]] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
    self.title = [NSString stringWithFormat:@"%@ %i", [DateUtil getMonthString:month],year];

    int numberOfWeeks = (int)[DateUtil getNumberOfWeeksInMonth:[self.monthFormatter dateFromString:[NSString stringWithFormat:@"%i/%i", month, year]]];

    [UIView animateWithDuration:0.5f animations:^{
        
    if (numberOfWeeks == 6) {
        [self.calendarView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 280)];
        [self.table setFrame:CGRectMake(0,
                                    self.calendarView.frame.origin.y + self.calendarView.frame.size.height,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height - (self.calendarView.frame.origin.y + self.calendarView.frame.size.height))];
    } else if (numberOfWeeks == 5) {
        [self.calendarView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
        [self.table setFrame:CGRectMake(0,
                                        self.calendarView.frame.origin.y + self.calendarView.frame.size.height,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height - (self.calendarView.frame.origin.y + self.calendarView.frame.size.height))];
        
    } else if (numberOfWeeks == 4) {
        [self.calendarView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 220)];
        [self.table setFrame:CGRectMake(0,
                                        self.calendarView.frame.origin.y + self.calendarView.frame.size.height,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height - (self.calendarView.frame.origin.y + self.calendarView.frame.size.height))];
    }
        
    }];
}


#pragma mark - Helper Methods
- (void)addPastDatesToDataSource
{
    NSMutableArray *array = [NSMutableArray array];
    self.previousDateRange -= 60;
    for (int i = self.previousDateRange + 59; i >= self.previousDateRange; i--) {
        [array insertObject:[self.dayFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*i)]] atIndex:0];
    }
    [self.dates insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [array count])]];
}

- (void)addNextDatesToDataSource
{
    NSMutableArray *array = [NSMutableArray array];
    self.futureDateRange += 60;
    for (int i = self.futureDateRange - 60; i < self.futureDateRange; i++) {
        [array addObject:[self.dayFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*i)]]];
    }
    [self.dates addObjectsFromArray:array];
    [self.table reloadData];
}

#pragma mark - Initializers
- (SACalendar *)calendarView
{
    if (!_calendarView) {
        _calendarView = [[SACalendar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 280)
                                          scrollDirection:ScrollDirectionHorizontal
                                            pagingEnabled:YES];
        [_calendarView setDelegate:self];
        [_calendarView setDataSource:self];
    }
    return _calendarView;
}

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, self.calendarView.frame.origin.y + self.calendarView.frame.size.height,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height -
                                                               (self.calendarView.frame.origin.y + self.calendarView.frame.size.height))
                                              style:UITableViewStylePlain];
        [_table setDataSource:self];
        [_table setBounces:NO];
        [_table setDelegate:self];
        [_table setShowsVerticalScrollIndicator:NO];
    }
    return _table;
}

@end
