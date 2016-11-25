# SwKArrayView
Objective C : iOS Array View Class, based on UITableView.

Usage is similar to the well-known UITableViewDelegate/DataSource protocols.


# SwKArrayViewDelegate : protocol
Required
- (UIView *)arrayView:(SwKArrayView *)arrayView viewForIndex:(NSInteger)index;

- (NSInteger)numberOfItemsForArrayView:(SwKArrayView *)view;

Optional

- (void)arrayView:(SwKArrayView *)arrayView selectedItemAtIndex:(NSInteger)index;
  - This is only called when the property "shouldAddTouchGestureRecognizer" is set to YES
