//
//  ViewController.m
//  SACalendar
//
//  Created by Nop Shusang on 7/12/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

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
@property int currentDateRange;
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

    self.navTitleView =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 120, 40)];
    [self.navTitleView setTextAlignment:NSTextAlignmentCenter];
    [self.navTitleView setUserInteractionEnabled:YES];
    [self.navTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.calendarView action:@selector(selectCurrentDay)]];
    self.navigationItem.titleView = self.navTitleView;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createWorkout:)];
    
    
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

}

- (void)createWorkout:(UIBarButtonItem *)item
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[JSLogWorkoutController alloc] init]] animated:YES completion:nil];
}

- (void)didFinishLoading
{
    [self.calendarView selectCurrentDay];
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dayFormatter stringFromDate:self.selectedDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
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

- (void)SACalendar:(SACalendar *)calendar didScrollLeft:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)indexPath month:(int)month year:(int)year
{
    [self.calendarView collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)SACalendar:(SACalendar *)calendar didScrollRight:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)indexPath month:(int)month year:(int)year
{
    [self.calendarView collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    self.selectedDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%02i/%02i/%04i", month, day, year]];
    [self.table reloadData];
}

-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
    self.navTitleView.text = [NSString stringWithFormat:@"%@ %i", [DateUtil getMonthString:month],year];

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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat currentOffsetX = scrollView_.contentOffset.x;
    CGFloat currentOffSetY = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height;
    
    NSLog(@"%f", currentOffSetY);
    
    if (currentOffSetY < (contentHeight / 8.0)) {
        //scrollView_.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY + (contentHeight/2)));
        self.currentDateRange -= 15;
        int j = 0;
        for (int i = self.currentDateRange - 15; i < self.currentDateRange + 15; i++) {
            if(i == 0) {
                //[self.dates removeObjectAtIndex:0];
                //[self.dates insertObject:[NSDate date] atIndex:0];
                [self.dates addObject:[NSDate date]];
            } else {
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*i)];
                //[self.dates removeObjectAtIndex:j];
                //[self.dates insertObject:date atIndex:j];
                [self.dates addObject:date];
                
            }
            j++;
        }
        [self.table reloadData];
        
    } else if (currentOffSetY > ((contentHeight * 6)/ 8.0)) {
        //self.dates = [NSMutableArray array];
        
        self.currentDateRange += 15;
        int j = 0;
        for (int i = self.currentDateRange - 15; i < self.currentDateRange + 15; i++) {
            if(i == 0) {
                //[self.dates removeObjectAtIndex:0];
                //[self.dates insertObject:[NSDate date] atIndex:0];
                [self.dates addObject:[NSDate date]];
            } else {
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(60.0f*60.0f*24.0f*i)];
                //[self.dates removeObjectAtIndex:j];
                //[self.dates insertObject:date atIndex:j];
                [self.dates addObject:date];
                
            }
            j++;
        }
        [self.table reloadData];
        //scrollView_.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY - (contentHeight/2)));
    }
    
}


@end
