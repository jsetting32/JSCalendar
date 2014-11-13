//
//  SACalendar.m
//  SACalendarExample
//
//  Created by Nop Shusang on 7/10/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License
//
//  Extended By John Setting on 11/07/14

#import "SACalendar.h"
#import "SACalendarCell.h"
#import "DateUtil.h"

@interface SACalendar () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, DMLazyScrollViewDelegate>
{
    NSMutableDictionary *controllers;
    NSMutableDictionary *calendars;
    NSMutableDictionary *monthLabels;
    
    int day, year, month;
    int prev_year, prev_month;
    int next_year, next_month;
    int current_date, current_month, current_year;
    
    int state, scroll_state;
    int previousIndex;
    BOOL scrollLeft;
    
    int firstDay;
    NSArray *daysInWeeks;
    CGSize cellSize;
    
    int selectedRow;
    int headerSize;
    
    BOOL firstLoad;
    
    BOOL calendarIsScrollingManually;
}

@property (nonatomic) NSDateFormatter *EEEEMMMMddyyyyFormatter;
@property (nonatomic) NSDateFormatter *MMyyFormatter;
@property (nonatomic) NSDateFormatter *MMMMyyyyFormatter;
@property (nonatomic) NSDateFormatter *ddFormatter;
@property (nonatomic) NSDateFormatter *MMddyyyyFormatter;
@property (nonatomic) NSDateFormatter *MMFormatter;
@end

@implementation SACalendar

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame month:0 year:0 scrollDirection:ScrollDirectionHorizontal pagingEnabled:YES];
}

- (id)initWithFrame:(CGRect)frame month:(int)m year:(int)y
{
    return [self initWithFrame:frame month:m year:y scrollDirection:ScrollDirectionHorizontal pagingEnabled:YES];
}

-(id)initWithFrame:(CGRect)frame
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging
{
    return [self initWithFrame:frame month:0 year:0 scrollDirection:direction pagingEnabled:paging];
}

-(id)initWithFrame:(CGRect)frame
             month:(int)m year:(int)y
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging
{
    self = [super initWithFrame:frame];
    if (self) {
        
        firstLoad = TRUE;
        
        self.MMMMyyyyFormatter = [[NSDateFormatter alloc] init];
        [self.MMMMyyyyFormatter setDateFormat:@"MMMM yyyy"];

        self.MMddyyyyFormatter = [[NSDateFormatter alloc] init];
        [self.MMddyyyyFormatter setDateFormat:@"MM/dd/yyyy"];
        
        self.EEEEMMMMddyyyyFormatter = [[NSDateFormatter alloc] init];
        [self.EEEEMMMMddyyyyFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
        
        self.MMyyFormatter = [[NSDateFormatter alloc] init];
        [self.MMyyFormatter setDateFormat:@"MM yyyy"];

        self.MMFormatter = [[NSDateFormatter alloc] init];
        [self.MMFormatter setDateFormat:@"MM"];
        
        self.ddFormatter = [[NSDateFormatter alloc] init];
        [self.ddFormatter setDateFormat:@"d"];

        controllers = [NSMutableDictionary dictionary];
        calendars = [NSMutableDictionary dictionary];
        monthLabels = [NSMutableDictionary dictionary];
        
        daysInWeeks = [[NSArray alloc]initWithObjects:@"Sunday",@"Monday",@"Tuesday",
                       @"Wednesday",@"Thursday",@"Friday",@"Saturday", nil];
        
        state = LOADSTATESTART;
        scroll_state = SCROLLSTATE_120;
        selectedRow = DESELECT_ROW;
        
        current_date = [[DateUtil getCurrentDate] intValue];
        current_month = [[DateUtil getCurrentMonth] intValue];
        current_year = [[DateUtil getCurrentYear] intValue];
        
        if (m == 0 && y == 0) {
            month = current_month;
            year = current_year;
        } else {
            month = m;
            year = y;
        }
        
        CGRect rect = CGRectMake(0, 94, self.frame.size.width, 200);
        self.scrollView = [[DMLazyScrollView alloc] initWithFrameAndDirection:rect direction:direction circularScroll:YES paging:paging];
        self.scrollView.controlDelegate = self;
        self.backgroundColor = viewBackgroundColor;
        
        UIView *weekdayLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.frame.size.width, 30)];
        [weekdayLabel setBackgroundColor:weekdayBackgroundColor];
        
        for (int i = 0; i < 7; i++) {
            UILabel *weekday = [[UILabel alloc] initWithFrame:CGRectMake(weekdayLabel.frame.size.width / 7.0f * i, 0, weekdayLabel.frame.size.width / 7.0f, 30)];
            [weekday setFont:[UIFont fontWithName:@"Arial" size:10.0f]];
            [weekday setTextAlignment:NSTextAlignmentCenter];
            [weekday setTextColor:[UIColor whiteColor]];
            
            switch (i) {
                case 0:
                    [weekday setText:@"S"];
                    break;
                case 1:
                    [weekday setText:@"M"];
                    break;
                case 2:
                    [weekday setText:@"T"];
                    break;
                case 3:
                    [weekday setText:@"W"];
                    break;
                case 4:
                    [weekday setText:@"T"];
                    break;
                case 5:
                    [weekday setText:@"F"];
                    break;
                case 6:
                    [weekday setText:@"S"];
                    break;
                default:
                    break;
            }
            
            [weekdayLabel addSubview:weekday];
        }
        
        [self addSubview:weekdayLabel];
        
        
        [self addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    self.scrollView.dataSource = ^(NSUInteger index) {
        return [weakSelf controllerAtIndex:index];
    };
    
    self.scrollView.numberOfPages = 3;
    [self addSubview:self.scrollView];
    
    return self;
    
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didDisplayCalendarForMonth:year:)]) {
        [_delegate SACalendar:self didDisplayCalendarForMonth:month year:year];
    }
}

#pragma SCROLL VIEW DELEGATE

- (UIViewController *)controllerAtIndex:(NSInteger) index {
    
    if (index == previousIndex && state == LOADSTATEPREVIOUS) {
        if (++month > MAX_MONTH) {
            month = MIN_MONTH;
            year ++;
        }
    
        scrollLeft = NO;
        firstDay = (int)[daysInWeeks indexOfObject:[DateUtil getDayOfDate:1 month:month year:year]];
        //selectedRow = DESELECT_ROW;

        /*
        if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didScrollRight:day:month:year:)]) {
            [_delegate SACalendar:self
                    didScrollRight:[calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]]
                              day:firstDay
                            month:month
                             year:year];
        }
        */
    
    } else if(state == LOADSTATEPREVIOUS) {
    
        if (--month < MIN_MONTH) {
            month = MAX_MONTH;
            year--;
        }
    
        scrollLeft = YES;
        firstDay = (int)[daysInWeeks indexOfObject:[DateUtil getDayOfDate:1 month:month year:year]];
        //selectedRow = DESELECT_ROW;
        /*
        if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didScrollLeft:day:month:year:)]) {
            [_delegate SACalendar:self
                    didScrollLeft:[calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]]
                              day:firstDay
                            month:month
                             year:year];
                
        }          
         */
    }
    
    previousIndex = (int)index;
    
    if (state  <= LOADSTATEPREVIOUS ) {
        state = LOADSTATENEXT;
    
    } else if (state == LOADSTATENEXT){
    
        prev_month = month - 1;
        prev_year = year;
        if (prev_month < MIN_MONTH) {
            prev_month = MAX_MONTH;
            prev_year--;
        }
        state = LOADSTATECURRENT;
    
    } else {
    
        next_month = month + 1;
        next_year = year;
        if (next_month > MAX_MONTH) {
            next_month = MIN_MONTH;
            next_year++;
        }
        
        if (scrollLeft) {
            if (--scroll_state < SCROLLSTATE_120) {
                scroll_state = SCROLLSTATE_012;
            }
        } else {
            scroll_state++;
            if (scroll_state > SCROLLSTATE_012) {
                scroll_state = SCROLLSTATE_120;
            }
        }
        state = LOADSTATEPREVIOUS;
        
        if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didDisplayCalendarForMonth:year:)]) {
            [_delegate SACalendar:self didDisplayCalendarForMonth:month year:year];
        }
    }
    
    /*
     * if already exists, reload the calendar with new values
     */
    UICollectionView *calendar = [calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]];
    [calendar reloadData];
    
    /*
     * create new view controller and add it to a dictionary for caching
     */
    if (![controllers objectForKey:[NSString stringWithFormat:@"%li",(long)index]]) {
        UIViewController *contr = [[UIViewController alloc] init];
        contr.view.backgroundColor = scrollViewBackgroundColor;
        
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.frame.size;

        headerSize = self.frame.size.height / calendarToHeaderRatio;
        
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - headerSize);
        UICollectionView *calendar = [[UICollectionView alloc]initWithFrame:rect collectionViewLayout:flowLayout];
        calendar.dataSource = self;
        calendar.delegate = self;
        calendar.scrollEnabled = NO;
        calendar.allowsSelection = YES;
        [calendar registerClass:[SACalendarCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [calendar setBackgroundColor:calendarBackgroundColor];
        calendar.tag = index;
        
        NSString *string = @"STRING";
        CGSize size = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        float pointsPerPixel = 12.0 / size.height;
        float desiredFontSize = headerSize * pointsPerPixel;
        
        UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, headerSize)];
        monthLabel.font = [UIFont systemFontOfSize: desiredFontSize * headerFontRatio];
        monthLabel.textAlignment = NSTextAlignmentCenter;
        monthLabel.text = [NSString stringWithFormat:@"%@ %04i",[DateUtil getMonthString:month],year];
        monthLabel.textColor = headerTextColor;
        
        [contr.view addSubview:monthLabel];
        [contr.view addSubview:calendar];
        
        [calendars setObject:calendar forKey:[NSString stringWithFormat:@"%li",(long)index]];
        [controllers setObject:contr forKey:[NSString stringWithFormat:@"%li",(long)index]];
        [monthLabels setObject:monthLabel forKey:[NSString stringWithFormat:@"%li",(long)index]];
        return contr;
    } else {
        return [controllers objectForKey:[NSString stringWithFormat:@"%li",(long)index]];
    }
    
}

/**
 *  Get the month corresponding to the collection view
 *
 *  @param tag of the collection view
 *
 *  @return month that the collection view should load
 */
-(int)monthToLoad:(int)tag
{
    if (scroll_state == SCROLLSTATE_120) {
        if (tag == 0) return next_month;
        else if(tag == 1) return prev_month;
        else return month;
    }
    else if(scroll_state == SCROLLSTATE_201){
        if (tag == 0) return month;
        else if(tag == 1) return next_month;
        else return prev_month;
    }
    else{
        if (tag == 0) return prev_month;
        else if(tag == 1) return month;
        else return next_month;
    }
}

/**
 *  Get the year corresponding to the collection view
 *
 *  @param tag of the collection view
 *
 *  @return year that the collection view should load
 */
-(int)yearToLoad:(int)tag
{
    if (scroll_state == SCROLLSTATE_120) {
        if (tag == 0) return next_year;
        else if(tag == 1) return prev_year;
        else return year;
    }
    else if(scroll_state == SCROLLSTATE_201){
        if (tag == 0) return year;
        else if(tag == 1) return next_year;
        else return prev_year;
    }
    else{
        if (tag == 0) return prev_year;
        else if(tag == 1) return year;
        else return next_year;
    }
}

#pragma COLLECTION VIEW DELEGATE

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
    
    firstDay = (int)[daysInWeeks indexOfObject:[DateUtil getDayOfDate:1 month:monthToLoad year:yearToLoad]];
    
    UILabel *monthLabel = [monthLabels objectForKey:[NSString stringWithFormat:@"%li",(long)collectionView.tag]];
    monthLabel.text = [NSString stringWithFormat:@"%@ %04i",[DateUtil getMonthString:monthToLoad],yearToLoad];

    return MAX_CELL;
}

/**
 *  Controls what gets displayed in each cell
 *  Edit this function for customized calendar logic
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SACalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
        
    // number of days in the month we are loading
    int daysInMonth = (int)[DateUtil getDaysInMonth:monthToLoad year:yearToLoad];
    
    // if cell is out of the month, do not show
    if (indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth) {
        cell.eventView.hidden = cell.dateLabel.hidden = cell.circleView.hidden = cell.selectedView.hidden = YES;
    } else {
        cell.dateLabel.hidden = NO;
        cell.circleView.hidden = YES;
        cell.eventView.hidden = YES;
        
        if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:doesCellHaveEvent:month:year:)]) {
            cell.eventView.hidden = [_delegate SACalendar:self doesCellHaveEvent:(int)indexPath.row - firstDay + 1  month:monthToLoad year:yearToLoad];
        }
        
        // get appropriate font size
        NSString *string = @"STRING";
        
        CGSize size = [string sizeWithAttributes:
                       @{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        float pointsPerPixel = 12.0 / size.height;
        float desiredFontSize = cellSize.height * pointsPerPixel;
        
        // if the cell is the current date, display the red circle
        BOOL isToday = NO;
        if (indexPath.row - firstDay + 1 == current_date && monthToLoad == current_month && yearToLoad == current_year) {
            cell.circleView.hidden = NO;
            cell.dateLabel.textColor = currentDateTextColor;
            cell.dateLabel.font = cellBoldFont;
            isToday = YES;
            if (firstLoad) {
                day = (int)indexPath.row - firstDay + 1;
                selectedRow = (int)indexPath.row;
                firstLoad = false;
            }
            
        } else {
            cell.dateLabel.font = cellBoldFont;
            cell.dateLabel.textColor = dateTextColor;
        }
        
        // if the cell is selected, display the black circle
        if (indexPath.row == selectedRow) {
            cell.selectedView.hidden = NO;
            cell.dateLabel.textColor = selectedDateTextColor;
            cell.dateLabel.font = cellBoldFont;
        } else {
            cell.selectedView.hidden = YES;
            if (!isToday) {
                cell.dateLabel.font = cellBoldFont;
                cell.dateLabel.textColor = dateTextColor;
            }
        }
        
        // set the appropriate date for the cell
        cell.dateLabel.text = [NSString stringWithFormat:@"%i",(int)indexPath.row - firstDay + 1];
    }
    
    return cell;
}

/*
 * Scale the collection view size to fit the frame
 */
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int width = self.frame.size.width;
    //int height = self.scrollView.frame.size.height;
    cellSize = CGSizeMake(width/DAYS_IN_WEEKS, 180 / MAX_WEEK);
    return CGSizeMake(width/DAYS_IN_WEEKS, 180 / MAX_WEEK);

}

/*
 * Set all spaces between the cells to zero
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

/*
 * If the width of the calendar cannot be divided by 7, add offset to each side to fit the calendar in
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    int width = self.scrollView.frame.size.width;
    int offset = (width % DAYS_IN_WEEKS) / 4;
    // top, left, bottom, right
    return UIEdgeInsetsMake(0,offset,0,offset);

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int daysInMonth = (int)[DateUtil getDaysInMonth:[self monthToLoad:(int)collectionView.tag] year:[self yearToLoad:(int)collectionView.tag]];
    if (!(indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth)) {
        
        int dateSelected = (int)indexPath.row - firstDay + 1;
        if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didSelectDate:month:year:)]) {
            [_delegate SACalendar:self didSelectDate:dateSelected month:month year:year];
        }
        selectedRow = (int)indexPath.row;
    }
    
    [collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView selectItemAtIndexPath:(NSIndexPath *)indexPath{
    int daysInMonth = (int)[DateUtil getDaysInMonth:[self monthToLoad:(int)collectionView.tag] year:[self yearToLoad:(int)collectionView.tag]];
    if (!(indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth)) {
        selectedRow = (int)indexPath.row;
    }
    
    [collectionView reloadData];
}


- (void)selectDay:(NSString *)theDate
{
    NSDate *theRealDate = [self.EEEEMMMMddyyyyFormatter dateFromString:theDate];
    NSString *date = [self.MMMMyyyyFormatter stringFromDate:[self.EEEEMMMMddyyyyFormatter dateFromString:theDate]];
    NSInteger theDay = [[self.ddFormatter stringFromDate:[self.EEEEMMMMddyyyyFormatter dateFromString:theDate]] integerValue];
    
    if (month == 12 && [[self.MMFormatter stringFromDate:theRealDate] integerValue] == 1) {
        month = 0;
        year++;
        [self.scrollView moveByPages:1 animated:NO];
    } else if (month == 1 && [[self.MMFormatter stringFromDate:theRealDate] integerValue] == 12) {
        month = 13;
        year--;;
        [self.scrollView moveByPages:-1 animated:NO];
    } else {
        if (month > [[self.MMFormatter stringFromDate:theRealDate] integerValue]) {
            [self.scrollView moveByPages:-1 animated:NO];
        } else if (month < [[self.MMFormatter stringFromDate:theRealDate] integerValue]) {
            [self.scrollView moveByPages:1 animated:NO];
        }
    }
    
    
    for(id key in monthLabels) {
        UILabel * value = [monthLabels objectForKey:key];
        if ([[value text] isEqualToString:date]) {
            UICollectionView *collectionView = [calendars objectForKey:key];
            [self collectionView:collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:(theDay + firstDay - 1) inSection:0]];
            return;
        }
    }
}


#pragma mark - DMLazyScrollView Delegate;
- (void)lazyScrollViewWillBeginDragging:(DMLazyScrollView *)pagingView
{
    calendarIsScrollingManually = TRUE;
}

- (void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex
{
    if (calendarIsScrollingManually) {
        calendarIsScrollingManually = FALSE;
        UICollectionView *view = [calendars objectForKey:[NSString stringWithFormat:@"%li",(long)currentPageIndex]];
        [self collectionView:view didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:firstDay inSection:0]];
        
        if (scrollLeft) {
            if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didScrollRight:day:month:year:)]) {
                [_delegate SACalendar:self
                       didScrollLeft:[calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]]
                                  day:firstDay
                                month:month
                                 year:year];
            }
            
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(SACalendar:didScrollRight:day:month:year:)]) {
                [_delegate SACalendar:self
                       didScrollRight:[calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]]
                                  day:firstDay
                                month:month
                                 year:year];
            }
            
        }
    }
}


/**
 *  Clean up
 */
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"delegate"];
}


@end
