//
//  ViewController.m
//  PhotoLocation
//
//  Created by luomeng on 16/8/22.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewController.h"

@interface ViewController ()
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
{

    
    
}

@end


@implementation ViewController (private)

- (IBAction)_select:(id)sender {
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    UIAlertController *actionVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camere = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *libary = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [actionVC addAction:camere];
    [actionVC addAction:libary];
    [actionVC addAction:cancel];
    [self presentViewController:actionVC animated:YES completion:nil];
}

@end

@implementation ViewController


#pragma mark -
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self dismissViewControllerAnimated:picker completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"ImagePage" sender:info];
}


#pragma mark -
#pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([segue.identifier isEqualToString:@"ImagePage"]) {
         ImageViewController *receive = segue.destinationViewController;
         receive.sourceImage = (NSDictionary *)sender;
         receive.navigationItem.title = @"图片详情";
     }
     
 }


@end










