//
//  ViewController.m
//  test8.8
//
//  Created by 柠檬 on 16/8/8.
//  Copyright © 2016年 柠檬. All rights reserved.
//

#import "ViewController.h"
#import "CalendarHomeViewController.h"
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>


@property(nonatomic,strong)UILabel *lblFirst;//左边的label
@property(nonatomic,strong)UILabel *lblSecond;//中间的label
@property(nonatomic,strong)UILabel *lblThird;//右边的label
@property(nonatomic,copy)NSString *strLeft;//左边label的text
@property(nonatomic,copy)NSString *strMiddle;//中间label的text
@property(nonatomic,copy)NSString *strRight;//右边label的text

@property(nonatomic,strong)NSArray *aryLeft;//左边label的数据源
@property(nonatomic,strong)NSArray *aryRight;//右边label的数据源


@property(nonatomic,strong)UIView *vLeft;//点击左边label显示的视图
@property(nonatomic,strong)UIView *vRight;//点击右边label显示测视图
@property(nonatomic,strong)UIView *vMask;//遮罩视图 在左边或右边视图显示的情况下在后面加一个遮罩是图

@property(nonatomic,strong)UITableView *tabVMain;//主页显示的tableView
@property(nonatomic,strong)UITableView *tabVLeft;//左边label的tabelView
@property(nonatomic,strong)UITableView *tabVRight;//右边label的tableView

@property(nonatomic,strong)CalendarHomeViewController *vCalendar;//日历视图


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.strLeft=@"地点";
    self.strMiddle=@"时间";
    self.strRight=@"地区";
    [self.view addSubview:self.tabVMain];
    
    
    [self loadLeftAndRightAndMiddle];//这个方法要先调用
    [self loadTopButtonView];//再调用这个
    //不然你会发现日历视图是从label上面下来的 滑动过程中会把label盖住
}

-(void)loadTopButtonView
{
    NSArray *array=@[@"地点",@"日期",@"全部"];
    //循环创建 顶部的标题
    for (NSInteger i=0; i<array.count; i++) {
        UILabel *label=[[UILabel alloc]init];
        label.text=array[i];
        label.font=[UIFont systemFontOfSize:16];
        label.backgroundColor=[UIColor whiteColor];
        label.userInteractionEnabled=YES;
        label.textAlignment=NSTextAlignmentCenter;
        label.frame=CGRectMake(i*WIDHT/3, 0, WIDHT/3, 40);
        label.tag=100+i;
        [self.view addSubview:label];
        if (i==0) {
            self.lblFirst=label;
        }else if (i==1){
            self.lblSecond=label;
        }else if (i==2){
            self.lblThird=label;
        }
        //给label添加手势
        UITapGestureRecognizer *tag=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblTapAction:)];
        [label addGestureRecognizer:tag];
    }

}
-(void)lblTapAction:(UITapGestureRecognizer *)tapG
{
    if (tapG.view.tag==100) {
        //点击的是校区label
        [self hidevRight];//不管右侧的视图是不是正在显示都隐藏掉
        [self hidevCalendar];//不管中间的日历是不是显示都隐藏掉
        [self showvMask];//显示遮罩视图
        if (self.vLeft.frame.size.height==0) {
            //此时说明左边的视图没显示 让他显示
            [self showvLeft];
            
        }else{
            //此时说明左边的视图正在显示  让他隐藏
            [self hidevLeft];
        }
        
        
        
    }else if (tapG.view.tag==101){
        [self hidevLeft];//大致思路同上
        [self hidevRight];
        [self hidevMask];
        if (self.vCalendar.view.frame.size.height==0) {
            [self showvCalendar];
        }else{
            [self hidevCalendar];
        }
        
        
        
    }else if (tapG.view.tag==102){
        [self hidevLeft];
        [self hidevCalendar];
        [self showvMask];
        if (self.vRight.frame.size.height==0) {
            [self showvRight];
        }else{
            [self hidevRight];
        }
        
    }
    
}
-(void)vMaskTapAction
{
    //遮罩视图的点击事件 隐藏 所有视图
    [self hidevLeft];
    [self hidevMask];
    [self hidevRight];
}
-(void)loadLeftAndRightAndMiddle
{
    if (!self.vMask) {//创建遮罩视图
        self.vMask=[[UIView alloc]initWithFrame:CGRectMake(0, 40, WIDHT, 0)];
        self.vMask.backgroundColor=[UIColor lightGrayColor];
        self.vMask.alpha=0.1;
        [self.view addSubview:self.vMask];
        UITapGestureRecognizer *tapG=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vMaskTapAction)];
        [self.vMask addGestureRecognizer:tapG];
    }
    
    if (!self.vLeft) {//创建左边的视图
        self.vLeft =[[UIView alloc]initWithFrame:CGRectMake(0, 40, WIDHT, 0)];
        self.vLeft.backgroundColor=[UIColor redColor];
        [self.view addSubview:self.vLeft];
        [self.vLeft addSubview:self.tabVLeft];
        self.vLeft.layer.masksToBounds=YES;
    }
    
    if (!self.vRight) {//创建右边的视图
        self.vRight =[[UIView alloc]initWithFrame:CGRectMake(0, 40, WIDHT, 0)];
        self.vRight.backgroundColor=[UIColor greenColor];
        [self.view addSubview:self.vRight];
        [self.vRight addSubview:self.tabVRight];
        self.vRight.layer.masksToBounds=YES;
    }
    
    if (!self.vCalendar) {//创建中间的日历
        self.vCalendar = [[CalendarHomeViewController alloc]init];
        self.vCalendar.calendartitle = @"日历";
        [self.vCalendar setAirPlaneToDay:365 ToDateforString:nil];//飞机初始化方法
        self.vCalendar.view.frame=CGRectMake(0, -HEIGHT, WIDHT, 0);
        [self.view addSubview:self.vCalendar.view];
    }
    __weak typeof (self) weakSelf=self;
    //回调
    self.vCalendar.calendarblock = ^(CalendarDayModel *model){
        weakSelf.strMiddle=[model toString];//取出模型中的日期，给字符串赋值
        [weakSelf.lblSecond setText:weakSelf.strMiddle];//让label现实
        [weakSelf.tabVMain reloadData];//刷险主页的tableView
        [weakSelf hidevCalendar];//点击一下后 隐藏日期

    };
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.tabVLeft) {//点击的是左边tableView的某一而cell
        self.strLeft=self.aryLeft[indexPath.row];//赋值
        [self.lblFirst setText:self.strLeft];//现实
        [self.tabVMain reloadData];//刷新主页tableView
        [self hidevLeft];//点击一下后隐藏所有视图
        [self hidevMask];
        [self hidevRight];
        [self hidevCalendar];
    }else if (tableView==self.tabVRight){
        self.strRight=self.aryRight[indexPath.row];
        [self.lblThird setText:self.strRight];
        [self.tabVMain reloadData];
        [self hidevLeft];
        [self hidevMask];
        [self hidevRight];
        [self hidevCalendar];
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num=0;
    if (tableView==self.tabVLeft) {
        num=self.aryLeft.count;
    }else if (tableView==self.tabVRight){
        num=self.aryRight.count;
    }else if (tableView==self.tabVMain){
        num=4;
    }
    return num;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    if (tableView==self.tabVLeft) {
        cell=[self addLeftTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (tableView==self.tabVRight){
        cell=[self addRightTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (tableView==self.tabVMain){
        cell=[self addMainTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    return cell;
    
}

-(UITableViewCell *)addMainTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"MainTableViewId";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%@-%@-%@",self.strLeft,self.strMiddle,self.strRight];
    
    return cell;
}
-(UITableViewCell *)addLeftTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"LeftTableViewId";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text=self.aryLeft[indexPath.row];
    return cell;
}

-(UITableViewCell *)addRightTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"tableViewId";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text=self.aryRight[indexPath.row];
    return cell;
}


/**
 *  下面是一些视图的隐藏和显示方法
 */


-(void)showvLeft
{
    [UIView animateWithDuration:0.3 animations:^{
        self.vLeft.frame=CGRectMake(0, 40, WIDHT, 300);
    }];
}
-(void)hidevLeft
{
    [UIView animateWithDuration:0.3 animations:^{
        self.vLeft.frame=CGRectMake(0, 40, WIDHT, 0);
    }];
}

-(void)showvCalendar
{
    [UIView animateWithDuration:0.3 animations:^{
       self.vCalendar.view.frame=CGRectMake(0, 40, WIDHT, HEIGHT-40);
    }];
}
-(void)hidevCalendar
{
    [UIView animateWithDuration:0.3 animations:^{
        //因为给日历视图一个具体的范围没有用 所以默认让他在屏幕外面  只要在屏幕中看不到就好
        self.vCalendar.view.frame=CGRectMake(0, -HEIGHT, WIDHT, 0);
    }];
}

-(void)showvRight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.vRight.frame=CGRectMake(0, 40, WIDHT, 300);
    }];
}
-(void)hidevRight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.vRight.frame=CGRectMake(0, 40, WIDHT, 0);
    }];
}

-(void)showvMask
{
    [UIView animateWithDuration:0.3 animations:^{
        self.vMask.frame=CGRectMake(0, 40, WIDHT, HEIGHT);
    }];
}

-(void)hidevMask
{
    [UIView animateWithDuration:0.3 animations:^{
        self.vMask.frame=CGRectMake(0, 40, WIDHT, 0);
    }];
}


/**
 *  下面都是懒加载
 *
 */


-(UITableView *)tabVLeft
{
    if (_tabVLeft==nil) {
        _tabVLeft=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, 300)];
        _tabVLeft.delegate=self;
        _tabVLeft.dataSource=self;
        
    }
    return _tabVLeft;
}
-(UITableView *)tabVRight
{
    if (_tabVRight==nil) {
        _tabVRight=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, 300)];
        _tabVRight.delegate=self;
        _tabVRight.dataSource=self;
    }
    return _tabVRight;
}

-(UITableView *)tabVMain
{
    if (_tabVMain==nil) {
        _tabVMain=[[UITableView alloc]initWithFrame:CGRectMake(0, 40, WIDHT, HEIGHT-42) style:UITableViewStyleGrouped];
        _tabVMain.delegate=self;
        _tabVMain.dataSource=self;
    }
    return _tabVMain;
}


-(NSArray *)aryLeft
{
    if (_aryLeft==nil) {
        _aryLeft=[NSArray arrayWithObjects:@"黄埔校区",@"卢湾校区",@"徐汇校区",@"长宁校区",@"普陀校区",@"闸北校区",@"虹口校区",@"杨浦校区",@"闵行校区",@"浦东新校区", nil];
    }
    return _aryLeft;
}


-(NSArray *)aryRight
{
    if (_aryRight==nil) {
        _aryRight=[NSArray arrayWithObjects:@"语文",@"数学",@"物理",@"化学",@"地理",@"生物", nil];
    }
    return _aryRight;
}




@end
