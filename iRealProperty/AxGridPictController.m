#import "AxGridPictController.h"

#import "MediaAccy.h"
#import "MediaBldg.h"
#import "MediaLand.h"
#import "MediaMobile.h"
#import "MediaNote.h"
#import "Helper.h"

@implementation AxGridPictController



@synthesize mediaArray;
@synthesize font;
@synthesize minFontSize;
@synthesize textColor;
@synthesize pictureRect;
@synthesize labelRect;
@synthesize cellRect;

@synthesize delegate;

#pragma mark - initialization
-(id)initWithMediaArray:(NSArray *)medias destinationViewId:(int)tag
{
//    enum{
//        kResBldg = 1,
//        kAccy =2,
//        kCndoBldg =3,
//        kCmlBldg =4,
//        kMobile=5,
//        kMediaBldg
//    };

    self = [super init];
    
    if(self)
    {
        mediaArray = medias;    // Keep list of media
        tagId = tag;
    }
    return self;
}
#pragma mark - Lifecycle
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    // Get views information
    UIView *mainView = [self.view viewWithTag:tagId];
    UIView *pictureView = [mainView viewWithTag:tagId+1];
    UIView *labelView = [mainView viewWithTag:tagId+2];

    UILabel *label = (UILabel *)[labelView.subviews objectAtIndex:0];
    
    pictureRect = pictureView.frame;
    labelRect = labelView.frame;
    cellRect = mainView.frame;
    
    // Get the label info
    font = label.font;
    minFontSize = label.minimumFontSize;
    //to do http://stackoverflow.com/questions/19293220/how-to-set-minimumfont-size-or-minimumscalfactorios7-with-the-attributed-strin
    //minFontSize = [label setMinimumScaleFactor:10.0/font]];
    textColor = label.textColor;

    // Remove the existing views
    [label removeFromSuperview];
    [labelView removeFromSuperview];
    [pictureView removeFromSuperview];
    
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
	self.gridView.bounces = NO;
    
    // Don't show the vertical scroll
    self.gridView.showsVerticalScrollIndicator = FALSE;
    self.gridView.showsHorizontalScrollIndicator = TRUE;
    
    // if there is a button to add picture, put it at the top
    UIView *view = [mainView viewWithTag:300];
    if(view!=nil)
    {
        [mainView bringSubviewToFront:view];
        
        UIButton *btn = (UIButton *)view;
        [btn addTarget:self action:@selector(pictButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    view = [mainView viewWithTag:301];
    if(view!=nil)
    {
        [mainView bringSubviewToFront:view];
        
        UIButton *btn = (UIButton *)view;
        [btn addTarget:self action:@selector(cadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}
- (void)dealloc 
{
}
#pragma mark - Utilities
-(void)updateMedias:(NSArray *)medias
{
    mediaArray = medias;
    AxGridView *contentView = (AxGridView *)[self.view.subviews objectAtIndex:0];
    [contentView layoutData];
    [contentView setNeedsDisplay];
}
#pragma mark - AxGridViewDataSource methods

- (NSInteger)numberOfRowsInGridView:(AxGridView *)gridView 
{
	return 1;
}
- (NSInteger)numberOfColumnsInGridView:(AxGridView *)gridView forRowWithIndex:(NSInteger)index 
{
	return [mediaArray count];
}

- (CGFloat)gridView:(AxGridView *)gridView heightForRow:(NSInteger)rowIndex 
{
	return cellRect.size.height;
}
- (CGFloat)gridView:(AxGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    return labelRect.size.width;
}
- (AxGridViewCell *)gridView:(AxGridView *)gv viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{

	NSString *identifier = @"Cell-Media"; 

	AxGridPictView *cell = (AxGridPictView *)[gv dequeueReusableCellWithIdentifier:identifier];
    
	if (!cell) 
    {
		cell = [[AxGridPictView alloc] initWithReuseIdentifier:identifier];
	}
    // Get the data
    cell.colNum = columnIndex;
    cell.gridPictController = self;
    return cell;
}

#pragma mark - gridView delegate methods
- (void)pictButtonClicked:(id)sender
{
    // avoid double clicks
    if([NSDate timeIntervalSinceReferenceDate] - timeStamp < 0.75)
        return;
    timeStamp = [NSDate timeIntervalSinceReferenceDate];

    [delegate gridMediaAddPicture:self];
}
-(void)cadButtonClicked:(id)sender
{
    // avoid double clicks
    if([NSDate timeIntervalSinceReferenceDate] - timeStamp < 0.75)
        return;
    timeStamp = [NSDate timeIntervalSinceReferenceDate];
        
    if([delegate respondsToSelector:@selector(gridMediaAddCad:)])
        [delegate gridMediaAddCad:self];
}
- (void)gridView:(AxGridView *)gv selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    [delegate gridMediaSelection:self media:[mediaArray objectAtIndex:columnIndex] columnIndex:columnIndex];
    
}
- (void)gridView:(AxGridView *)gv selectionLongMadeInCell:(AxGridViewCell *)cell 
{
    if([delegate respondsToSelector:@selector(gridMediaLongSelection:inCell:withMedia:)])
    {
        [delegate gridMediaLongSelection:gv inCell:cell withMedia:[mediaArray objectAtIndex:cell.xPosition]];
    }

}
- (void)gridView:(AxGridView *)gridView scrolledToEdge:(AxGridViewEdge)edge 
{
}

@end

