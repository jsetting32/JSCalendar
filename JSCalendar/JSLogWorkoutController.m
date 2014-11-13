//
//  JSLogWorkoutController.m
//  JSCalendar
//
//  Created by John Setting on 11/10/14.
//  Copyright (c) 2014 John Setting. All rights reserved.
//

#import "JSLogWorkoutController.h"
#import "JSLogWorkoutView.h"

@interface JSLogWorkoutController () <JSLogWorkoutViewDelegate>
@property (nonatomic) JSLogWorkoutView *workoutView;
@property (nonatomic) UIDatePicker *datePicker;
@end

@implementation JSLogWorkoutController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor yellowColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
    
    self.workoutView = [[JSLogWorkoutView alloc] initWithFrame:self.view.frame];
    [self.workoutView setDelegate:self];
    [self.view addSubview:self.workoutView];
}

- (void)JSLogWorkoutView:(JSLogWorkoutView *)view doneButtonPressed:(UIButton *)button
{
    [self.workoutView.notesView resignFirstResponder];
}

- (void)JSLogWorkoutView:(JSLogWorkoutView *)view tappedDateView:(UITapGestureRecognizer *)recognizer
{
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, self.view.frame.size.width, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, self.view.frame.size.width, 216);
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, self.view.frame.size.width, 216)];
    self.datePicker.tag = 10;
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
    toolBar.tag = 11;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:
                                             [UIColor colorWithRed:30.0f/255.0f
                                                             green:144.0f/255.0f
                                                              blue:255.0f/255.0f
                                                             alpha:1.0f],
                                         }
                              forState:UIControlStateNormal];
    
    [toolBar setItems:@[spacer, doneButton] animated:NO];
    [self.view addSubview:toolBar];

    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    self.datePicker.frame = datePickerTargetFrame;
    [UIView commitAnimations];
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM d, yyyy"];

    self.workoutView.dateView.text = [formatter stringFromDate:[self.datePicker date]];
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, self.view.frame.size.width, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, self.view.frame.size.width, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)cancelButtonPressed:(UIBarButtonItem *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveButtonPressed:(UIBarButtonItem *)button
{
    NSLog(@"%@", self.workoutView.notesView.text);
    NSLog(@"%i", [self.workoutView.scaleSegment selectedSegmentIndex]);
    NSLog(@"%@", self.workoutView.dateView.text);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
