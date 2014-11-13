//
//  SACalendar.h
//  SACalendarExample
//
//  Created by Nop Shusang on 7/10/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License
//
//  Extended By John Setting on 11/07/14

#import <UIKit/UIKit.h>
#import "SACalendarConstants.h"
#import "DMLazyScrollView.h"

@protocol SACalendarDelegate;
@interface SACalendar : UIView

@property (nonatomic, weak) id<SACalendarDelegate> delegate;
@property (nonatomic) DMLazyScrollView* scrollView;

/**
 *  Default constructor. Calendar will begin at current month
 *
 *  @param frame of the calendar
 *
 *  @return initialized calendar
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  Begin calendar at specific month and year
 *
 *  @param frame of the calendar
 *  @param m     month to begin calendar
 *  @param y     year to begin calendar
 *
 *  @return initialized calendar starting at mm/yyyy
 */
- (id)initWithFrame:(CGRect)frame month:(int)m year:(int)y;

/**
 *  Calendar will begin at current month. The user can also specify other properties
 *
 *  @param frame     of the calendar
 *  @param direction scroll direction, default to horizontal
 *  @param paging    paging enabled, default to yes
 *
 *  @return initialized calendar
 */
-(id)initWithFrame:(CGRect)frame scrollDirection:(scrollDirection)direction pagingEnabled:(BOOL)paging;

/**
 *  The complete constructor
 *
 *  @param frame     of the calendar
 *  @param m         month to begin calendar
 *  @param y         year to begin calendar
 *  @param direction scroll direction, default to horizontal
 *  @param paging    paging enabled, default to yes
 *
 *  @return initialized calendar
 */
-(id)initWithFrame:(CGRect)frame month:(int)m year:(int)y scrollDirection:(scrollDirection)direction pagingEnabled:(BOOL)paging;

/** 
 *  This method selects the day on the calendar view
 *
 *  @param theDate   A string with the current date (e.g Monday, November 11, 2014)
 */
- (void)selectDay:(NSString *)theDate;
@end

@protocol SACalendarDelegate <NSObject>
@optional

/**
 *  A delegate function that get called once the calendar changed to display a different month.
 *  This is caused by swiping left or right
 *
 *  @param calendar The calendar object that get changed
 *  @param month    The new month displayed
 *  @param year     The new year displayed
 */
-(void) SACalendar:(SACalendar*)calendar didDisplayCalendarForMonth:(int)month year:(int)year;

/**
 *  This function get called when a specific date is selected
 *
 *  @param calendar The calendar object that the selected date is on
 *  @param day      The date selected
 *  @param month    The month selected
 *  @param year     The year selected
 */
-(void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year;

/**
 *  This function get called when a collection view is loaded and checks whether an event is on the
 *  specified date
 *
 *  @param calendar The calendar object that the selected date is on
 *  @param day      The day
 *  @param month    The month
 *  @param year     The year
 */
- (BOOL)SACalendar:(SACalendar *)calendar doesCellHaveEvent:(int)day month:(int)month year:(int)year;

/**
 *  This function is called when the user scrolls the calendar left
 *  @param calendar The calendar object that is current visible
 *  @param day      The day
 *  @param month    The month
 *  @param year     The year
 */
- (void)SACalendar:(SACalendar *)calendar didScrollLeft:(UICollectionView *)collectionView day:(int)day month:(int)month year:(int)year;

/**
 *  This function is called when the user scrolls the calendar right
 *  @param calendar The calendar object that is current visible
 *  @param day      The day
 *  @param month    The month
 *  @param year     The year
 */
- (void)SACalendar:(SACalendar *)calendar didScrollRight:(UICollectionView *)collectionView day:(int)day month:(int)month year:(int)year;

@end