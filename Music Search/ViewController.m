//
//  ViewController.m
//  Music Search
//
//  Created by Minh Luu on 11/25/14.
//  Copyright (c) 2014 Minh Luu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UISearchBarDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

@end

@implementation ViewController

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.results = nil;
    [self.tableView reloadData];
    
    [self.view addGestureRecognizer:self.tap];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.view removeGestureRecognizer:self.tap];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchText = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self searchForArtist:searchText];
}

- (void)searchForArtist:(NSString *)artistName {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@", artistName]];
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            weakSelf.results = [resultDict objectForKey:@"results"];
            [weakSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }] resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Music Search";
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignSearchKeyboard:)];
}

- (void)resignSearchKeyboard:(UIGestureRecognizer *)gesture {
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *result = [self.results objectAtIndex:indexPath.row];
    NSString *trackName = [result objectForKey:@"trackName"];
    NSString *collectionName = [result objectForKey:@"collectionName"];
    NSURL *albumURL = [NSURL URLWithString:[result objectForKey:@"artworkUrl100"]];
    cell.textLabel.text = trackName;
    cell.detailTextLabel.text = collectionName;
    return cell;
}

@end
