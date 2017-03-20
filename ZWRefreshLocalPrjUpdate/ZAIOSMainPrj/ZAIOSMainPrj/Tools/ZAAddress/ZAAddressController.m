//
//  ZAAddressController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAAddressController.h"
#import "ZAAddressCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "THContact.h"
#import "pinyin.h"
#import "PHJTransformPinyin.h"
#import "ChineseInclude.h"
#import "SFHFKeychainUtils.h"
#import "PinYinForObjc.h"
#import "ChineseInclude.h"
@interface ZAAddressController ()<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating>
{
    NSArray * _filterData;
    UISearchDisplayController *searchControl;
    UISearchController * searchVC;
    UISearchBar * coverSearch;
    BOOL listTaped;
}
@property (nonatomic,strong) NSMutableArray *indextitles;
@property (nonatomic,strong) NSDictionary * contactsDic;
@property (nonatomic,strong) UITableView * addressTable;
@property (nonatomic,strong) NSArray * bgColors;
@property (nonatomic,strong) NSArray * filterData;
@property (nonatomic,strong) NSArray * totalAddressArr;
@end

@implementation ZAAddressController
@synthesize filterData = _filterData;
-(void)dealloc
{
    //取消视图，
    searchControl.active = NO;
    searchControl.delegate = nil;
    searchControl = nil;
    
    searchVC.searchBar.delegate = nil;
    searchVC.active = NO;
    searchVC.searchResultsUpdater = nil;
    searchVC.delegate = nil;
    searchVC = nil;
    
    self.addressTable.delegate = nil;
    self.addressTable = nil;
    
    
    self.indextitles = nil;
    self.contactsDic = nil;
    
    self.bgColors = nil;
    self.filterData = nil;
    self.totalAddressArr = nil;
    
    NSLog(@"__has_feature %s",__FUNCTION__);
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
//        self.indextitles = @[UITableViewIndexSearch,@"A",@"B",@"C"];
        self.viewTtle = @"手机通讯录";
        NSArray * arr = [NSArray arrayWithObjects:[UIColor orangeColor],[UIColor magentaColor],[UIColor purpleColor],[UIColor grayColor],[UIColor blueColor],nil];
        self.bgColors = arr;
        listTaped = NO;
    }
    return self;
}
//未进行排重处理
+(BOOL)addContactToUserAddressList
{
    NSString * name = @"怕怕专属客服";
    NSString * telNum = @"010-89178958";
    NSString * tag = @"众安";

    //排重
    
    return [[self class] addContactName:name phoneNum:telNum withLabel:tag];
}

+(BOOL)addressBookAuthNeverStarted
{
//需要6.0以上，
    if (IOS6_OR_LATER)
    {
        ABAuthorizationStatus state = ABAddressBookGetAuthorizationStatus();
        if(state == kABAuthorizationStatusNotDetermined)
        {
            return YES;
        }
        return NO;
    }
    
    //无处理6.0以下
    return NO;
}

+(BOOL)addressBookAuthStateEnable
{
    //需要6.0以上，
    if (IOS6_OR_LATER)
    {
        ABAuthorizationStatus state = ABAddressBookGetAuthorizationStatus();
        if(state == kABAuthorizationStatusAuthorized)
        {
            return YES;
        }
        return NO;
    }
    
    //无处理6.0以下
    return NO;
}
+(void)startAddressAddWithBlock:(void(^)(BOOL enable))block
{
    ABAddressBookRequestAccessWithCompletion(nil, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block){
                 block(granted);
            }
        });
    });
}


// 添加联系人（联系人名称、号码、号码备注标签）
+ (BOOL)addContactName:(NSString*)name phoneNum:(NSString*)num withLabel:(NSString*)label
{
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.addresslist_Added_Contact) return YES;
    total.addresslist_Added_Contact = YES;
    
    // 创建一条空的联系人
    ABRecordRef record = ABPersonCreate();    CFErrorRef error;
    
    NSString * localSave = [DZUtils lastestAddressRecordId];
    NSLog(@"%s %@",__FUNCTION__,localSave);
    
    ABRecordID recordID = 0;
    if(localSave && [localSave length]>0)
    {
        recordID = (int32_t)[localSave longLongValue];
    }

    
    ABAddressBookRef addressBook = nil;
    // 如果为iOS6以上系统，需要等待用户确认是否允许访问通讯录。
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)                                                 {    dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        addressBook = ABAddressBookCreate();
    }
    
    
    //查看之前是否有
    ABRecordRef oldPeople = NULL;
    if(recordID!=0)
    {
        oldPeople = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    }
    
    if (!oldPeople)
    {
        // 设置联系人的名字
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);
        // 添加联系人电话号码以及该号码对应的标签名
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)num, (__bridge CFTypeRef)label, NULL);    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);

    }else{
        record = oldPeople;
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)num, (__bridge CFTypeRef)label, NULL);    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);
    }
    
    

    
    // 将新建联系人记录添加如通讯录中
    BOOL success = ABAddressBookAddRecord(addressBook, record, &error);
    
    if (!success)
    {
        total.addresslist_Added_Contact = NO;
        NSLog(@"ABAddressBookAddRecord fail");
        return NO;
    }else{
        // 如果添加记录成功，保存更新到通讯录数据库中
        success = ABAddressBookSave(addressBook, &error);
        
        if(success)
        {
            ABRecordID latestId = ABRecordGetRecordID(record);
            NSString * str = [NSString stringWithFormat:@"%ld",(long)latestId];
            
            if(!str || [str length]==0)
            {
                NSAssert(YES, @"新增的通讯录名单无RecordID");
                str = @"0";
            }
            total.addresslist_Added_Contact = YES;
            [total localSave];
            
            [SFHFKeychainUtils keyUtilsSaveString:str withKeyString:NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER];
            [[NSUserDefaults standardUserDefaults] setValue:str forKey:NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER];
        }
        
        return success ? YES : NO;
    }
}
//- (void)leftAction
//{
//    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Cancel];
//    [self.navigationController popViewControllerAnimated:YES];
//}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!listTaped)
    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Cancel];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height -= rect.origin.y;
    UITableView * table = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
    self.addressTable = table;
    [table registerNib:[UINib nibWithNibName:@"ZAAddressCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
//    table.allowsSelection = NO;
//    table.backgroundColor = [UIColor redColor];
    
    if (iOS8_constant_or_later)
    {
#if     __IPHONE_OS_VERSION_MAX_ALLOWED >= 8000
        //8.0以上使用
        UISearchController *search = [[UISearchController alloc] initWithSearchResultsController:nil];
        search.automaticallyAdjustsScrollViewInsets = NO;
        search.edgesForExtendedLayout = UIRectEdgeNone;
        search.extendedLayoutIncludesOpaqueBars = NO;
        search.modalPresentationCapturesStatusBarAppearance = NO;
        
        search.searchResultsUpdater = self;
        search.dimsBackgroundDuringPresentation = NO;
        search.delegate = self;
        searchVC =  search;
        search.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        search.searchBar.delegate = self;
        search.searchBar.placeholder = @"在通讯录中搜索...";
        search.searchBar.backgroundColor= [UIColor whiteColor];
        search.searchBar.searchBarStyle =  UISearchBarStyleProminent;
        [search.searchBar setSearchTextPositionAdjustment:UIOffsetMake(30, 0)];
        [search.searchBar sizeToFit];
        search.searchBar.returnKeyType = UIReturnKeyDefault;
        //    search.modalPresentationStyle = UIModalPresentationCurrentContext;
        //    search.definesPresentationContext = NO;
        
        //    table.tableHeaderView = nil;
        
        //确定搜索框位置
        rect  = [table convertRect:search.searchBar.bounds  toView:self.view];
        UISearchBar * barSearch = [[UISearchBar alloc] initWithFrame:rect];
        barSearch.delegate = self;
        barSearch.backgroundColor = search.searchBar.backgroundColor;
        [barSearch setSearchTextPositionAdjustment:UIOffsetMake(30, 0)];
        coverSearch = barSearch;
        barSearch.placeholder = search.searchBar.placeholder;
        
        [self.view addSubview:barSearch];
        [self.view bringSubviewToFront:barSearch];
        
        [table setContentInset:UIEdgeInsetsMake(search.searchBar.bounds.size.height, 0, 0, 0)];
#endif
        
    }else
    {
        //    8.0以下使用
        UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        table.tableHeaderView = searchBar;
        searchBar.delegate = self;
        searchBar.showsScopeBar = YES;
        searchBar.placeholder = @"在通讯录中搜索...";
        [searchBar setSearchTextPositionAdjustment:UIOffsetMake(30, 0)];
        
        //搜索的时候会有左侧滑动的效果
        searchControl = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
        searchControl.delegate = self;
        searchControl.searchResultsDataSource = self;
        searchControl.searchResultsDelegate = self;
        [searchControl.searchResultsTableView registerNib:[UINib nibWithNibName:@"ZAAddressCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
//        searchControl.searchResultsTableView.allowsSelection = YES;
        searchControl.searchBar.backgroundColor = [UIColor whiteColor];
        searchBar.returnKeyType = UIReturnKeyDefault;
    }
    
    __weak typeof(self) weakSelf = self;
    ABAddressBookRequestAccessWithCompletion(nil, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
            
        }
    });
}





-(BOOL)tableViewIsResultTable
{
    NSString * text = nil;
    if(iOS8_constant_or_later)
    {
        text = searchVC.searchBar.text;
        return  searchVC.isActive;
    }else {
        text = searchControl.searchBar.text;
        return   searchControl.isActive;
    }
}
#pragma mark - UISearchControllerDelegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //首次启动时调用，内容改变时，调用
    {
        //搜索页面内容刷新
        // 谓词搜索
        NSString * str = searchController.searchBar.text;
        if(!str||[str length]==0)
        {
            NSArray * array = self.totalAddressArr;
            
            NSArray * totalObjArr = nil;
            if(array && [array count]>0)
            {
               totalObjArr = [NSArray arrayWithArray:array];
            }
            self.filterData = totalObjArr;
            [self.addressTable reloadData];

        }
    }
    
}



#pragma mark -----
-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [self getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
//            // Get image if it exists
//            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
//            contact.image = [UIImage imageWithData:imgData];
//            if (!contact.image) {
//                contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
//            }
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        NSDictionary * totalDic =  [self letterIndexFromAddressDataArray:mutableContacts];
        self.contactsDic = totalDic;
        
        [self.addressTable reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}
-(NSDictionary *)letterIndexFromAddressDataArray:(NSArray *)dataArr
{
    NSMutableDictionary*index=[NSMutableDictionary dictionaryWithCapacity:0];
    
//    PinYinForObjc * exchange = [[PinYinForObjc alloc] init];
    
    for (THContact * model in dataArr)
    {

        NSString* total= [model fullName];

        NSString * start  = nil;
        if(total && [total length]>0 && [ChineseInclude isIncludeChineseInString:total])
        {
//            model.totalPinYin = [exchange privateChineseConvertToPinYin:total];
//            model.firstLetterPinYin = [exchange privateChineseConvertToPinYinHead:total];
            
            NSString *strFirLetter = [NSString stringWithFormat:@"%c",pinyinFirstLetter([total characterAtIndex:0])];
            model.totalPinYin = strFirLetter;
            model.firstLetterPinYin = strFirLetter;
            start = strFirLetter;
        }
        //获得中文拼音首字母，如果是英文或数字则#
        if(!start||[start length]==0) continue;
        NSString *strFirLetter = nil;
        
        //转换为小写
        strFirLetter= [self upperStr:[start substringToIndex:1]];
        if ([strFirLetter isEqualToString:@"#"]) {
            
        }
        
        if ([[index allKeys]containsObject:strFirLetter]) {
            //判断index字典中，是否有这个key如果有，取出值进行追加操作
            [[index objectForKey:strFirLetter] addObject:model];
        }else{
            NSMutableArray*tempArray=[NSMutableArray arrayWithCapacity:0];
            [tempArray addObject:model];
            [index setObject:tempArray forKey:strFirLetter];
        }
        
    }
    
    self.indextitles = [NSMutableArray arrayWithArray:[index allKeys]];
    [self sortMethod];
    
    
    NSMutableArray * total = [NSMutableArray array];
    for (NSInteger i = 0;i<[self.indextitles count];i++)
    {
        NSString * keyStr = [self.indextitles objectAtIndex:i];
        NSArray * eveArr = [index objectForKey:keyStr];
        [total addObjectsFromArray:eveArr];
    }
    self.totalAddressArr = total;
    
    [self.indextitles insertObject:UITableViewIndexSearch atIndex:0];
    
    return index;
}


#pragma  mark 字母转换大小写--6.0
-(NSString*)upperStr:(NSString*)str{
    
    //    //全部转换为大写
    //    NSString *upperStr = [str uppercaseStringWithLocale:[NSLocale currentLocale]];
    //    NSLog(@"upperStr: %@", upperStr);
    //首字母转换大写
    //    NSString *capStr = [str capitalizedStringWithLocale:[NSLocale currentLocale]];
    //    NSLog(@"capStr: %@", capStr);
    //    // 全部转换为小写
    NSString *lowerStr = [str uppercaseStringWithLocale:[NSLocale currentLocale]];
    //    NSLog(@"lowerStr: %@", lowerStr);
    return lowerStr;
    
}
#pragma mark 排序
-(void)sortMethod
{
    NSArray*array=  [self.indextitles sortedArrayUsingFunction:cmp context:NULL];
    NSMutableArray * sorArr = [NSMutableArray arrayWithArray:array];
    if(sorArr && [sorArr count]>0){
        NSString * str = [sorArr firstObject];
        if([str isEqualToString:@"#"])
        {
            [sorArr removeObject:@"#"];
            [sorArr addObject:@"#"];
        }
    }
    self.indextitles = sorArr;
    
}
//构建数组排序方法SEL
//NSInteger cmp(id, id, void *);
NSInteger cmp(NSString * a, NSString* b, void * p)
{
    if([a compare:b] == 1){
        return NSOrderedDescending;//(1)
    }else
        return  NSOrderedAscending;//(-1)
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}
-(void)enableSearchBarFirstResponderWith:(BOOL)search
{
    [coverSearch resignFirstResponder];
    if(search)
    {
        [searchVC.searchBar becomeFirstResponder];
    }else{
        [searchVC.searchBar resignFirstResponder];
    }
}

-(void)scaleTableViewForSearch:(BOOL)search
{
    //当搜索时，作为tableviewheaderview，当不搜索时，作为独立控件
    
    CGFloat startY =  kTop;
    CGFloat topHeight = self.titleBar.bounds.size.height;
    if(!search)
    {
        startY += topHeight;
    }
    
//    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //失去相应点
//        [weakSelf enableSearchBarFirstResponderWith:search];
//    });
    
    //搜索框隐藏
    coverSearch.hidden = search;
    searchVC.searchBar.hidden = !search;
    if(search)
    {
         searchVC.active = search;
    }

    
    CGFloat searchHeight = searchVC.searchBar.bounds.size.height;

    UITableView * table = self.addressTable;
    if(searchVC)
    {
        table.tableHeaderView = search?searchVC.searchBar:nil;
        table.contentInset = search?UIEdgeInsetsZero:UIEdgeInsetsMake(searchHeight, 0, 0, 0);
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                                CGRect rect = [[UIScreen mainScreen] bounds];
                                rect.origin.y = startY;
                                rect.size.height -= startY;
                                self.addressTable.frame = rect;
                                
                                rect.size.height = topHeight;
                                rect.origin.y -= topHeight;
                                self.titleBar.frame = rect;
                         
                         if(!search&&searchVC)
                             [self.addressTable setContentOffset:CGPointMake(0, -searchVC.searchBar.bounds.size.height)];

    }
                     completion:^(BOOL finished) {
//                         if(search)
                         {
                             searchVC.active = search;
                         }
                     }];

    

//    if(!iOS8_constant_or_later)
//    {
//        startY = kTop + topHeight;
//        CGRect rect = [[UIScreen mainScreen] bounds];
//        rect.origin.y = startY;
//        rect.size.height -= startY;
//        self.searchDisplayController.searchResultsTableView.frame = rect;
//    }

}
#pragma mark UISearchBarDelegate
//如果要实现输入中文时随着变化，修改此处
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString  * str = searchControl.searchBar.text;
    if(!searchControl) str = searchVC.searchBar.text;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.fullName contains [cd] %@ || self.totalPinYin contains [cd] %@ || self.firstLetterPinYin contains [cd] %@",str,str,str];
    if([ChineseInclude isIncludeChineseInString:str])
    {
        predicate = [NSPredicate predicateWithFormat:@"self.fullName contains [cd] %@",str];
    }
    
    NSArray * totalObjArr = self.totalAddressArr;
    
    self.filterData = [totalObjArr filteredArrayUsingPredicate:predicate];
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableView * table = !searchControl?self.addressTable:searchControl.searchResultsTableView;
        [table reloadData];
    });

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if(searchBar==coverSearch||searchBar==searchControl.searchBar)
    {
        [self.addressTable setContentOffset:CGPointZero];
        [self scaleTableViewForSearch:YES];
        [self enableSearchBarFirstResponderWith:YES];
        return searchBar==searchControl.searchBar;
    }
    
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
//    NSLog(@"searchBarsearchBar %@  ",searchBar);
//    NSLog(@"vcbar  %@  %@",searchVC.searchBar,coverSearch);
    
    //当8.0以下时，搜索框失去焦点，且搜索框内容为空，返回初始状态
    if(iOS8_constant_or_later) return;
    NSString * txt = searchControl.searchBar.text;
    if(!txt||[txt length]==0){
        //恢复原状
        [self scaleTableViewForSearch:NO];
    }
    
//    if(searchBar.hidden) return;
//    //searchControl情况
//    if(searchBar==searchControl.searchBar) return;
//    if(searchVC&&!searchVC.isActive) return;
//    //显示头部
//    [self scaleTableViewForSearch:NO];
//    
//    if(searchVC)
//    [self.addressTable reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if(searchBar.hidden) return;
    //显示头部
    [self scaleTableViewForSearch:NO];
}

#pragma mark ---
#pragma mark - UITableViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(searchVC && searchVC.isActive && scrollView == self.addressTable)
    {
        //展示结果内容
        [searchVC.searchBar resignFirstResponder];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (![self tableViewIsResultTable])
    {
        NSString * str = [self.indextitles objectAtIndex:section];
        NSArray * objArr = [self.contactsDic objectForKey:str];
        return objArr.count;
    }else{
        
        return _filterData.count;
    }
    

}
- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"ContactCell";
    ZAAddressCell *cell = (ZAAddressCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = (ZAAddressCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSAssert(YES, @"缺少cell的ib文件");
    }
    

    THContact *user = nil;
    
    if(![self tableViewIsResultTable])
    {
        NSString * str = nil;
        if([self.indextitles count]>indexPath.section)
        {
            str = [self.indextitles objectAtIndex:indexPath.section];
        }
        
        NSArray * objArr = [self.contactsDic objectForKey:str];
        if([objArr count]>indexPath.row)
        {
            user = [objArr objectAtIndex:indexPath.row];
        }
        
        cell.accessoryType =IOS7_OR_LATER?UITableViewCellAccessoryDetailButton:UITableViewCellAccessoryDetailDisclosureButton;
    }else {
        user = _filterData[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSInteger colorNum = [self.bgColors count];
    UIColor * color = [UIColor lightGrayColor];
    NSInteger index = indexPath.row % colorNum;
    if(colorNum>index)
    {
        color = [self.bgColors objectAtIndex:index];
    }
    
    NSString * name = nil;
//    name = [user fullName];
    name = [user updateFullName];
    cell.nameLbl.text = name;
    cell.phoneNumLbl.text = [user phone];
    cell.normalBGColor = color;
    cell.nameBGView.backgroundColor = color;
    if([name length]>=2)
    {
        cell.subNameLbl.text = [name substringWithRange:NSMakeRange([name length]-2, 2)];
    }
    
//    NSLog(@"cell.nameBGViewcell.nameBGView %@",cell.nameBGView);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
//    [searchControl.searchBar resignFirstResponder];
//    [searchVC.searchBar resignFirstResponder];
//    [coverSearch resignFirstResponder];


    //    if(![self tableViewIsResultTable])
    {
        
        //当选中时，运行block
        THContact *user = nil;
        if(![self tableViewIsResultTable])
        {
            NSString * str = nil;
            if([self.indextitles count]>indexPath.section)
            {
                str = [self.indextitles objectAtIndex:indexPath.section];
            }
            
            NSArray * objArr = [self.contactsDic objectForKey:str];
            if([objArr count]>indexPath.row)
            {
                user = [objArr objectAtIndex:indexPath.row];
            }
        }else {
            user = _filterData[indexPath.row];
        }
        
        if(iOS8_constant_or_later&&[self tableViewIsResultTable]){
            searchVC.active = NO;
            searchControl.active = NO;
        }
        
//        屏蔽  +86
        NSString * telNum = user.phone;
        if(telNum && [telNum length]>0)
        {
            telNum = [telNum stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            
            user.phone = telNum;
        }

        
        listTaped = YES;
        if(self.TapedOnSelectAddressPerson)
        {
            [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Confirm];
            self.TapedOnSelectAddressPerson(user);
        }
    }
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //    if(![self tableViewIsResultTable])
    {
        //当选中时，运行block
        THContact *user = nil;
        if(![self tableViewIsResultTable])
        {
            NSString * str = nil;
            if([self.indextitles count]>indexPath.section)
            {
                str = [self.indextitles objectAtIndex:indexPath.section];
            }
            
            NSArray * objArr = [self.contactsDic objectForKey:str];
            if([objArr count]>indexPath.row)
            {
                user = [objArr objectAtIndex:indexPath.row];
            }
        }else {
            user = _filterData[indexPath.row];
        }
        
        ABRecordID personId = user.recordId;;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
        ABPersonViewController *view = [[ABPersonViewController alloc] init];
        view.addressBook = addressBookRef;
        view.displayedPerson = ABAddressBookGetPersonWithRecordID(addressBookRef, personId);
        //        self.navigationController.navigationBarHidden = NO;
        
        [self.navigationController pushViewController:view animated:YES];
    }
    
    
    
}

#pragma mark ---
#pragma mark - SearchDisplayController
-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y  = kTop + searchControl.searchBar.bounds.size.height;
    rect.size.height -= rect.origin.y;
    tableView.frame = rect;
    
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    [tableView setContentOffset:CGPointZero];
}
//- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
//}

-(void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [self.addressTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableIndextitles
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([self tableViewIsResultTable]) return 1;
    return self.indextitles.count;
}
//返回每个Section的title
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([self tableViewIsResultTable]) return nil;
    if(section==0) return nil;
    return [self.indextitles objectAtIndex:section];
}
//返回索引栏数据
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if([self tableViewIsResultTable]) return nil;
    return self.indextitles;
}
//建立索引栏和section的关联
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if([self tableViewIsResultTable]) return 0;
    return [self.indextitles indexOfObject:title];
}

#pragma mark ---




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
