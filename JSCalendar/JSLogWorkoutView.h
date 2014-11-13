//
//  JSLogWorkoutView.h
//  JSCalendar
//
//  Created by John Setting on 11/12/14.
//  Copyright (c) 2014 John Setting. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSLogWorkoutViewDelegate;

@interface JSLogWorkoutView : UIView
@property (nonatomic, weak) id<JSLogWorkoutViewDelegate>delegate;
@property (nonatomic) UISegmentedControl *scaleSegment;
@property (nonatomic) UITextView *notesView;
@property (nonatomic) UITextView *dateView;
@end

@protocol JSLogWorkoutViewDelegate <NSObject>
- (void)JSLogWorkoutView:(JSLogWorkoutView *)view doneButtonPressed:(UIButton *)button;
- (void)JSLogWorkoutView:(JSLogWorkoutView *)view tappedDateView:(UITapGestureRecognizer *)recognizer;
@end
