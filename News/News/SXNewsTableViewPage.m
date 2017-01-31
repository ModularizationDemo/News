//
//  SXTableViewPage.m
//  SXNews
//
//  Created by 董 尚先 on 15-1-22.
//  Copyright (c) 2015年 ShangxianDante. All rights reserved.
//

#import "SXNewsTableViewPage.h"
#import "SXNewsCell.h"
#import "SXNewsViewModel.h"
#import <Detail-Category/Lothar+Detail.h>
#import <PhotoSet-Category/Lothar+PhotoSet.h>
#import <MJRefresh/MJRefresh.h>

@interface SXNewsTableViewPage ()

@property(nonatomic,strong) NSMutableArray <SXNewsEntity *>*arrayList;
@property(nonatomic,assign)BOOL update;
@property(nonatomic,strong)SXNewsViewModel *viewModel;

@end

@implementation SXNewsTableViewPage

- (SXNewsViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[SXNewsViewModel alloc]init];
    }
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    __weak SXNewsTableViewPage *weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.update = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(welcome) name:@"SXAdvertisementKey" object:nil];
//    self.tableView.headerHidden = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
}

- (void)welcome
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"update"];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"update"]) {
        return;
    }
    if (self.update == YES) {
        [self.tableView.mj_header beginRefreshing];
        self.update = NO;
    }
}


#pragma mark - /************************* 刷新数据 ***************************/
// ------下拉刷新
- (void)loadData
{
    // http://c.m.163.com//nc/article/headline/T1348647853363/0-30.html
    NSString *allUrlstring = [NSString stringWithFormat:@"/nc/article/%@/0-20.html",self.urlString];
    [self loadDataForType:1 withURL:allUrlstring];
}

// ------上拉加载
- (void)loadMoreData
{
    //    NSString *allUrlstring = [NSString stringWithFormat:@"/nc/article/%@/%ld-20.html",self.urlString,self.arrayList.count];
    NSString *allUrlstring = [NSString stringWithFormat:@"/nc/article/%@/%ld-20.html",self.urlString,(long)(self.arrayList.count - self.arrayList.count%10)];
    [self loadDataForType:2 withURL:allUrlstring];
}

// ------公共方法
- (void)loadDataForType:(int)type withURL:(NSString *)allUrlstring
{
    @weakify(self)
    [[self.viewModel.fetchNewsEntityCommand execute:allUrlstring]subscribeNext:^(NSArray *arrayM) {
        @strongify(self)
        if (type == 1) {
            self.arrayList = [arrayM mutableCopy];
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }else if(type == 2){
            [self.arrayList addObjectsFromArray:arrayM];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        }
    } error:^(NSError *error) {
        NSLog(@"%@",error.userInfo);
    }];
}

#pragma mark -
#pragma mark tableView datasource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SXNewsEntity *newsModel = self.arrayList[indexPath.row];
    NSString *ID = [SXNewsCell idForRow:newsModel];
    if ((indexPath.row%20 == 0)&&(indexPath.row != 0)) {
        ID = @"NewsCell";
    }
    SXNewsCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.NewsModel = newsModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SXNewsEntity *newsModel = self.arrayList[indexPath.row];
    CGFloat rowHeight = [SXNewsCell heightForRow:newsModel];
    if ((indexPath.row%20 == 0)&&(indexPath.row != 0)) {
        rowHeight = 80;
    }
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 刚选中又马上取消选中，格子不变色
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SXNewsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqual: @"NewsCell"] || [cell.reuseIdentifier isEqual: @"TopTxtCell"] || [cell.reuseIdentifier isEqual: @"ImagesCell"]) {
        UIViewController *dc = [[Lothar shared] Detail_aViewControllerWithDocid:self.arrayList[indexPath.row].docid
                                                                        boardid:self.arrayList[indexPath.row].boardid
                                                                     replyCount:self.arrayList[indexPath.row].replyCount];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        [self.navigationController pushViewController:dc animated:YES];
    } else {
        UIViewController *pc = [[Lothar shared] PhotoSet_aViewController:self.arrayList[indexPath.row].photosetID
                                                              replyCount:self.arrayList[indexPath.row].replyCount
                                                                 boardid:self.arrayList[indexPath.row].boardid
                                                                   docid:self.arrayList[indexPath.row].docid];
        [self.navigationController pushViewController:pc animated:YES];
    }
}

@end
