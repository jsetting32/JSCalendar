//
//  SACalendarCell.h
//  SACalendarExample
//
//  Created by Nop Shusang on 7/12/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License
//
//  Extended By John Setting on 11/07/14

#import <UIKit/UIKit.h>

@protocol SACalendarCellDelegate;

@interface SACalendarCell : UICollectionViewCell

@property (nonatomic, weak)id<SACalendarCellDelegate>delegate;
/**
 *  a circle that appears on the current date
 */
@property UIView *circleView;

/**
 *  a circle that appears on the selected date
 */
@property UIView *selectedView;

/**
 *  the label showing the cell's date
 */
@property UILabel *dateLabel;

/**
 *  the circle that appears below the dateLabel
 */
@property UIView *eventView;

@end

