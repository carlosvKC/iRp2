#import "GridBookmark.h"

@implementation GridBookmark
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        int height = 954-44;
        UIView *view = [self.view viewWithTag:1];
        view.frame = CGRectMake(0,44,768,height);
        view = [self.view viewWithTag:40];
        view.frame = CGRectMake(0,0,768,height);
        
        view = [self.view viewWithTag:41];
        view.frame = CGRectMake(0,0,768,50);
        view = [self.view viewWithTag:42];
        view.frame = CGRectMake(0,50,768,height-40);
    }
    else 
    {
        int height = 698-44;
        UIView *view = [self.view viewWithTag:1];
        view.frame = CGRectMake(0,44,1024,height);
        view = [self.view viewWithTag:40];
        view.frame = CGRectMake(0,0,1024,height);
        
        view = [self.view viewWithTag:41];
        view.frame = CGRectMake(0,0,1024,50);
        view = [self.view viewWithTag:42];
        view.frame = CGRectMake(0,50,1024,height-40);
    }
    [[self getFirstGridController]autoFitToView];
}


@end
