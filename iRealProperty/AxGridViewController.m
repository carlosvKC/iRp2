
#import "AxGridViewController.h"
#import "Helper.h"

@implementation AxGridViewController

@synthesize gridView;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.autoresizesSubviews = YES;
	gridView = [[AxGridView alloc] initWithFrame:self.view.bounds];
	self.gridView.autoresizingMask = self.view.autoresizingMask;
    // A little hard coded
    [gridView setBackgroundColor:[Helper UIColorFromRGB255:216 green:216 blue:216]];
	[self.view addSubview:self.gridView];
}

- (void)viewDidUnload 
{
	self.gridView = nil;
}

- (void)dealloc 
{
	gridView = nil;
}

- (NSInteger)numberOfRowsInGridView:(AxGridView *)gridView 
{
	return 0;
}
- (NSInteger)numberOfColumnsInGridView:(AxGridView *)gridView forRowWithIndex:(NSInteger)theIndex 
{
	return 0;
}
- (CGFloat)gridView:(AxGridView *)gridView heightForRow:(NSInteger)rowIndex 
{
	return 0.0f;
}
- (CGFloat)gridView:(AxGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
	return 0.0f;
}
- (AxGridViewCell *)gridView:(AxGridView *)gridView viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
	return nil;
}
@end
