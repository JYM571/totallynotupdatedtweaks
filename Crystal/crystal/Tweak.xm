@interface NCNotificationListViewController : UICollectionViewController
- (void)clearAll;
@end

@interface NCNotificationPriorityListViewController : NCNotificationListViewController
@end

@protocol NCNotificationSectionList
@required
- (void)clearAllSections;
@end

@interface NCNotificationSectionListViewController : NCNotificationListViewController
- (void) sectionHeaderViewDidReceiveClearAllAction:(id)arg1;
@end

@interface SBDashBoardViewControllerBase : UIViewController
@end

@interface SBDashBoardNotificationListViewController : SBDashBoardViewControllerBase
-(void)_clearContentIncludingPersistent:(BOOL)clearPersistant;
@end



#define kRefresh @"REFRESH"
#define kPath @"/Library/PreferenceBundles/Crystal.bundle/Crystal.bundle"

static NSDictionary<NSString *, NSString *> *dict;
%hook NCNotificationListViewController
-(void) viewDidLoad {
    %orig;
    NSBundle *bundle = [[NSBundle alloc] initWithPath:kPath];
    dict = @{
            kRefresh : [bundle localizedStringForKey:kRefresh value:@"Pull to refresh" table:nil]
        };



    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(clearNotifications:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor clearColor]];
    // [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:[dict valueForKey:kRefresh]]];
    [self.collectionView addSubview:refreshControl];
}

%new
-(void) clearNotifications:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];

    [self performSelector:@selector(clearAll)];
    [(NCNotificationSectionListViewController *)self sectionHeaderViewDidReceiveClearAllAction:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Clear" object:nil userInfo:nil];

    [refreshControl endRefreshing];
}
%end


%hook SBDashBoardNotificationListViewController
-(void) viewDidLoad {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearNotifications) name:@"Clear" object:nil];
}

-(void) dealloc {
    %orig;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

%new 
-(void) clearNotifications {
    [self _clearContentIncludingPersistent:YES];
}
%end