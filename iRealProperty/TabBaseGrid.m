#import "TabBase.h"
#import "TabBaseGrid.h"
#import "RealProperty.h"
#import "Helper.h"

@implementation TabBaseGrid

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getFirstGridController].delegate = (ScreenController *)self.itsController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [Helper findAndResignFirstResponder:self.view];
   if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
   {
       int height = 868;
      UIView *view = [self.view viewWithTag:1];
      view.frame = CGRectMake(0,0,768,height);
      view = [self.view viewWithTag:40];
      view.frame = CGRectMake(0,0,768,height);
      
      view = [self.view viewWithTag:41];
      view.frame = CGRectMake(0,0,768,50);
      view = [self.view viewWithTag:42];
      view.frame = CGRectMake(0,50,768,height-40-50);
    }
   else 
   {
       int height = 612;
       UIView *view = [self.view viewWithTag:1];
       view.frame = CGRectMake(0,0,1024,height);
       view = [self.view viewWithTag:40];
       view.frame = CGRectMake(0,0,1024,height);
       
       view = [self.view viewWithTag:41];
       view.frame = CGRectMake(0,0,1024,50);
       view = [self.view viewWithTag:42];
       view.frame = CGRectMake(0,50,1024,height-40-50);
   }
    [[self getFirstGridController]autoFitToView];
}
@end
