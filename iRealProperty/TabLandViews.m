#import "TabLandViews.h"
#import "TabLandController.h"
#import "TrackChanges.h"
#import "Helper.h"

@implementation TabLandViews

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RealPropInfo *info = [RealProperty realPropInfo];
    self.workingBase = info.xland;
    
    [self setScreenEntities];
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    [self.tabLandController segmentUsed:kSubViews];
    self.isDirty = YES;
    RealPropInfo *propinfo = [RealProperty realPropInfo];
    XLand *xland = propinfo.xland;
    xland.rowStatus = @"U";
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
