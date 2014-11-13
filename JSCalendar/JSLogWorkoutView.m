//
//  JSLogWorkoutView.m
//  JSCalendar
//
//  Created by John Setting on 11/12/14.
//  Copyright (c) 2014 John Setting. All rights reserved.
//

#import "JSLogWorkoutView.h"

@interface JSLogWorkoutView()
@end

@implementation JSLogWorkoutView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    UILabel *scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, self.frame.size.width - 20, 10)];
    [scaleLabel setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
    [scaleLabel setTextColor:[UIColor brownColor]];
    [scaleLabel setText:@"SCALE"];
    [self addSubview:scaleLabel];
    
    self.scaleSegment = [[UISegmentedControl alloc] initWithItems:@[@"Rx", @"Scaled"]];
    [self.scaleSegment setFrame:CGRectMake(10, 95, self.frame.size.width - 20, 25)];
    [self.scaleSegment setSelectedSegmentIndex:0];
    [self.scaleSegment setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.scaleSegment];
    
    
    UILabel *notesViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, self.frame.size.width - 20, 10)];
    [notesViewLabel setText:@"NOTES"];
    [notesViewLabel setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
    [notesViewLabel setTextColor:[UIColor brownColor]];
    [self addSubview:notesViewLabel];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneButtonActionForNotesView:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 35)];
    [toolbar setItems:@[spacer, doneButton]];
    
    self.notesView = [[UITextView alloc] initWithFrame:CGRectMake(10, 145, self.frame.size.width - 20, 100)];
    [self.notesView setInputAccessoryView:toolbar];
    [self addSubview:self.notesView];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, self.frame.size.width - 20, 10)];
    [dateLabel setText:@"DATE"];
    [dateLabel setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
    [dateLabel setTextColor:[UIColor brownColor]];
    [self addSubview:dateLabel];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM d, yyyy"];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedDateViewAction:)];
    singleTap.numberOfTapsRequired = 1;
    
    self.dateView = [[UITextView alloc] initWithFrame:CGRectMake(10, 275, self.frame.size.width - 20, 30)];
    [self.dateView setText:[formatter stringFromDate:[NSDate date]]];
    [self.dateView setSelectable:YES];
    [self.dateView setEditable:NO];
    [self.dateView addGestureRecognizer:singleTap];
    [self addSubview:self.dateView];
    
    return self;
}

- (void)doneButtonActionForNotesView:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(JSLogWorkoutView:doneButtonPressed:)]) {
        [self.delegate JSLogWorkoutView:self doneButtonPressed:button];
    }
}

- (void)tappedDateViewAction:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(JSLogWorkoutView:tappedDateView:)]) {
        [self.delegate JSLogWorkoutView:self tappedDateView:recognizer];
    }
}



@end
