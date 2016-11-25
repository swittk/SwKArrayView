//
//  SwKArrayView.h
//  SPACE
//
//  Created by Switt Kongdachalert on 11/25/2559 BE.
//  Copyright © 2559 Switt Kongdachalert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwKArrayView;

/*!
 * Delegate for SwKArrayView
 */
@protocol SwKArrayViewDelegate <NSObject>

/// Should return the view to be shown at the given index
/// Use array view's dequeueReusableViewFromCurrentContext to reuse a view shown in the array
-(UIView *)arrayView:(SwKArrayView *)arrayView viewForIndex:(NSInteger)index;

/// Should return number of items to be shown
-(NSInteger)numberOfItemsForArrayView:(SwKArrayView *)view;

@optional
/// This method is called on 'touch up' of a touched item.
/// ****
/// If the supplied view has touch methods (touchBegan:, touchMoved:, etc.)
/// implemented, then this will NOT be called.
-(void)arrayView:(SwKArrayView *)arrayView selectedItemAtIndex:(NSInteger)index;

@end

@interface SwKArrayView : UIView

/// The array view delegate
@property (assign, nonatomic) id <SwKArrayViewDelegate> delegate;

/// The size of each item to be shown
@property (assign, nonatomic) CGSize itemSize;

/// This currently does nothing because I realized I had no real use for it :/
@property (assign) CGFloat verticalInset;

/// This specifies the side inset if the array view
@property (assign, nonatomic) CGFloat sideInset;

/// This specifies the minimum horizontal gap width between the items
@property (assign, nonatomic) CGFloat minHorizontalContentGap;

/// This specifies if the vertical gap between the items should match the horizontal gap
/// This value defaults to YES.
@property (assign, nonatomic) BOOL verticalGapMatchesHorizontalGap;

/// This specifies the vertical gap between the items.
/// Set verticalGapMatchesHorizontalGap to NO to use this property
@property (assign) CGFloat verticalContentGap;

/// Specifies if the array view should add a touch gesture recognizer to the supplied item views
/// *** This removes all current gesture recognizers from the view
/// *** Defaults to YES
@property (assign) BOOL shouldAddTouchGestureRecognizer;

/// Dequeues a reusuable item view. Do not call outside the delegate method of
/// arrayView:viewForIndex:
-(UIView *)dequeueReusableViewFromCurrentContext;

/// Reloads data
-(void)reloadData;

@end
