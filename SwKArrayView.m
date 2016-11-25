//
//  SwKArrayView.m
//  SPACE
//
//  Created by Switt Kongdachalert on 11/25/2559 BE.
//  Copyright © 2559 Switt Kongdachalert. All rights reserved.
//

#import "SwKArrayView.h"
@class SwKArrayViewCell;
@protocol SwKArrayViewCellDelegate <NSObject>
-(UIView *)arrayCell:(SwKArrayViewCell *)cell viewForArrayIndex:(NSInteger)index;
-(void)arrayCell:(SwKArrayViewCell *)cell selectedArrayIndex:(NSInteger)index;
@end

@interface SwKArrayViewCell : UITableViewCell
-(void)reloadData;

@property (assign, nonatomic) id <SwKArrayViewCellDelegate> delegate;

@property (assign) CGFloat verticalInset;
@property (assign) CGFloat horizontalInset;
@property (assign) CGFloat widthSlotPerContent;
@property (assign) CGSize itemSize;

@property (assign, nonatomic) NSInteger beginningItemIndex;
@property (assign, nonatomic) NSInteger numItems;
@property (readonly) NSInteger endItemIndex;

@property (assign) BOOL shouldAddTouchGestureRecognizer;

-(UIView *)dequeueReusableView;
@end

@implementation SwKArrayViewCell {
    NSMutableArray <UIView *>*views;
    NSMutableArray <UIView *>*recycledViewsPool;
    
    UIView *touchingView;
    BOOL touchStillValid;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.userInteractionEnabled = YES;
        
        views = [NSMutableArray new];
        recycledViewsPool = [NSMutableArray new];
    }
    return self;
}

-(void)layoutSubviews {
    [self rearrangeViews];
}

-(CGRect)frameForObjectAtIndex:(int)index {
    return CGRectMake(_horizontalInset + _widthSlotPerContent*index +
                      (_widthSlotPerContent - _itemSize.width)/2.0 ,
                      _verticalInset,
                      _itemSize.width,
                      _itemSize.height);
}

-(void)setNumItems:(NSInteger)numItems {
    if(_numItems == numItems) return;
    _numItems = numItems;
}


-(UIView *)dequeueReusableView {
    if([recycledViewsPool count]) {
        UIView *recycleView = [recycledViewsPool firstObject];
        [recycledViewsPool removeObjectAtIndex:0];
        return recycleView;
    }
    return nil;
}

-(NSInteger)endItemIndex {
    return _beginningItemIndex + _numItems - 1;
}

-(void)reloadData {
    [self moveViewsToRecyclePool];
    
    for(NSInteger i = 0; i < _numItems; i++) {
        NSInteger currentIndex = _beginningItemIndex + i;
        UIView *populatedView = [self.delegate arrayCell:self viewForArrayIndex:currentIndex];
        
        if(self.shouldAddTouchGestureRecognizer) {
            populatedView.userInteractionEnabled = YES;
            populatedView.gestureRecognizers = nil;
            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedInSubview:)];
            gr.numberOfTapsRequired = 1;
            [populatedView addGestureRecognizer:gr];
        }
        
        [views addObject:populatedView];
        [self addSubview:populatedView];
    }
    
    [self clearRecyclePool];
    [self rearrangeViews];
}

-(void)moveViewsToRecyclePool {
    for(UIView *view in views) {
        //move to recycle pool
        [view removeFromSuperview];
        [recycledViewsPool addObject:view];
    }
    [views removeAllObjects];
}

-(void)clearRecyclePool {
    [recycledViewsPool removeAllObjects];
}

-(void)rearrangeViews {
    for(int i = 0; i < [views count]; i++) {
        UIView *view = [views objectAtIndex:i];
        view.frame = [self frameForObjectAtIndex:i];
    }
}
-(void)setDelegate:(id<SwKArrayViewCellDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}

-(void)touchedInSubview:(UITapGestureRecognizer *)gestureRecognizer {
    UIView *view = gestureRecognizer.view;
    NSInteger index = [views indexOfObject:view] + _beginningItemIndex;
    [self.delegate arrayCell:self selectedArrayIndex:index];
}

@end




@interface SwKArrayView () <UITableViewDataSource, UITableViewDelegate, SwKArrayViewCellDelegate>

@end
@implementation SwKArrayView {
    UITableView *table;
    
    NSInteger totalItemsCount;
    NSInteger numItemsPerRow;
    CGFloat widthItemSlot;
    CGFloat computedHorizontalContentGap;
    
    SwKArrayViewCell *currentContext;
}

-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        table = [[UITableView alloc] initWithFrame:self.bounds];
        [table setDataSource:self];
        [table setDelegate:self];
        [self addSubview:table];
        [table setSeparatorColor:[UIColor clearColor]];
        
        _verticalGapMatchesHorizontalGap = YES;
        _shouldAddTouchGestureRecognizer = YES;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews {
    table.frame = self.bounds;
    [self recomputeNumberOfItemsPerRow];
}

#pragma mark - UITableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwKArrayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rowscell"];
    if(!cell) {
        cell = [[SwKArrayViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rowscell"];
    }
    cell.beginningItemIndex = indexPath.row * numItemsPerRow;
    if((totalItemsCount - cell.beginningItemIndex) < numItemsPerRow) {
        cell.numItems = totalItemsCount - cell.beginningItemIndex;
    }
    else {
        cell.numItems = numItemsPerRow;
    }
    cell.itemSize = _itemSize;
    
    if(_verticalGapMatchesHorizontalGap) cell.verticalInset = computedHorizontalContentGap/2.0;
    else cell.verticalInset = _verticalContentGap/2.0;
    
    cell.horizontalInset = _sideInset;
    cell.shouldAddTouchGestureRecognizer = self.shouldAddTouchGestureRecognizer;
    cell.widthSlotPerContent = widthItemSlot;
    
    [cell setDelegate:self];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil((float)totalItemsCount/(float)numItemsPerRow);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_verticalGapMatchesHorizontalGap) {
        return _itemSize.height + computedHorizontalContentGap;
    }
    else return _itemSize.height + _verticalContentGap;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - SwKArrayViewCellDelegate
-(void)arrayCell:(SwKArrayViewCell *)cell selectedArrayIndex:(NSInteger)index {
    if([self.delegate respondsToSelector:@selector(arrayView:selectedItemAtIndex:)]) {
        [self.delegate arrayView:self selectedItemAtIndex:index];
    }
}

-(UIView *)arrayCell:(SwKArrayViewCell *)cell viewForArrayIndex:(NSInteger)index {
    currentContext = cell;
    return [self.delegate arrayView:self viewForIndex:index];
}

-(UIView *)dequeueReusableViewFromCurrentContext {
    if(currentContext) {
        return [currentContext dequeueReusableView];
    }
    else return nil;
}

-(void)recomputeNumberOfItemsPerRow {
    CGFloat minContentCellWidth = _itemSize.width + _minHorizontalContentGap;
    CGFloat totalWidth = table.frame.size.width - 2*_sideInset;
    
    numItemsPerRow = floor(totalWidth/minContentCellWidth);
    widthItemSlot = totalWidth/(CGFloat)numItemsPerRow;
    computedHorizontalContentGap = widthItemSlot - _itemSize.width;
}

-(void)setDelegate:(id<SwKArrayViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}

-(void)reloadData {
    if([self.delegate respondsToSelector:@selector(numberOfItemsForArrayView:)]) {
        totalItemsCount = [self.delegate numberOfItemsForArrayView:self];
        [self recomputeNumberOfItemsPerRow];
        
        [table reloadData];
    }
    else NSLog(@"SwKArrayView : Did you forget to set the delegate?");
}

-(void)setSideInset:(CGFloat)sideInset {
    _sideInset = sideInset;
    [self recomputeNumberOfItemsPerRow];
}
-(void)setMinHorizontalContentGap:(CGFloat)minHorizontalContentGap {
    _minHorizontalContentGap = minHorizontalContentGap;
    [self recomputeNumberOfItemsPerRow];
}
-(void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    [self recomputeNumberOfItemsPerRow];
}
-(void)setVerticalGapMatchesHorizontalGap:(BOOL)verticalGapMatchesHorizontalGap {
    _verticalGapMatchesHorizontalGap = verticalGapMatchesHorizontalGap;
}

@end
