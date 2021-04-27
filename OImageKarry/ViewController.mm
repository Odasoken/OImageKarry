//
//  ViewController.m
//  OImageKarry
//
//  Created by lx on 2021/4/23.
//  Copyright © 2021 lx. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

/*
 Download the opencv2.framework from the link and import it to your project:
 https://udomain.dl.sourceforge.net/project/opencvlibrary/4.5.2/opencv-4.5.2-ios-framework.zip
 
 */
#import "ViewController.h"
#import "UIImageView+Hello.h"
#import "UIImage+Hello.h"


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *originImageView;

@property (weak, nonatomic) IBOutlet UIImageView *greyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *TreshouldImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hsvImageView;

@property (weak, nonatomic) IBOutlet UIImageView *hsitImageView;

//@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self cvMakeImage];
    [self.originImageView enableTapPreview];
     [self.greyImageView enableTapPreview];
     [self.TreshouldImageView enableTapPreview];
     [self.hsvImageView enableTapPreview];
    [self.hsitImageView enableTapPreview];
}

- (IBAction)selectImage:(UIButton *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate=self;
    //    imagePickerController.allowsEditing=YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)cvMakeImage
{
    if (!self.originImageView.image) {
        return;
    }
    cv::Mat orignImg;
    UIImageToMat(self.originImageView.image,orignImg);
    //
    cv::Mat greyImg;
    cv::cvtColor(orignImg, greyImg, cv::COLOR_BGR2GRAY);
    
    cv::Mat hsvImg;
    cv::cvtColor(orignImg, hsvImg, cv::COLOR_BGR2HSV);
    
    cv::Mat threshImg;
    cv::threshold(greyImg, threshImg, 150, 255,  cv::THRESH_BINARY);
    //
    //    cv::Mat cannyImg;
    //    cv::Canny(threshImg, cannyImg, 180, 255);
        
        
    //    std::vector<cv::Vec4i> lines;
    //    cv::HoughLinesP(cannyImg, lines, 1,  CV_PI / 180,50,50, 10);
    //    for( size_t i = 0; i < lines.size(); i++ )
    //      {
    //          cv::Vec4i line = lines[i];
    //          cv::line( orignImg,  cv::Point(line[0], line[1]),  cv::Point(line[2], line[3]),  cv::Scalar(0,255,0), 3);
    //      }

       
        
   UIImage *grayimage = MatToUIImage(greyImg);
   self.greyImageView.image = grayimage;
    
    UIImage *tresh_Image = MatToUIImage(threshImg);
    self.TreshouldImageView.image = tresh_Image;
        
//        cv::Mat mask;
//        cv::inRange(hsvImg,  cv::Scalar(0,0,0),  cv::Scalar(179,157,79), mask);
        
    UIImage *hsv_image = MatToUIImage(hsvImg);
    self.hsvImageView.image = hsv_image;
    
    //    cv::imshow("Hello", orignImg);
    cv::Mat hist;
    int channels[] = {0,1};
    int hbins = 60,sbins = 64;
    int histSize[] = {hbins,sbins};
    
    float hranges[] = {0,180};
    //saturation varies from 0 to 255
    float sranges[] = {0,255};
    const float *ranges[] = {hranges,sranges};
    
    cv::calcHist(&hsvImg, 1, channels, cv::Mat(), hist, 2, histSize, ranges);
    
    double maxVal = .0;
    minMaxLoc(hist,0,&maxVal,0,0);
    int scale = 8;
    //show the histogram on the image
    cv::Mat histImg = cv::Mat::zeros(sbins*scale,hbins*scale,CV_8UC3);
    for (int h = 0;h < hbins;h++)
    {
        for (int s = 0;s<sbins;s++)
        {
            float binVal = hist.at<float>(h,s);
            int intensity = cvRound(binVal*0.9*255/maxVal);
            rectangle(histImg,cv::Point(h*scale,s*scale),cv::Point((h+1)*scale-1,(s+1)*scale-1),cv::Scalar::all(intensity),cv::FILLED);
        }
    }

        
    UIImage *hits_image = MatToUIImage(histImg);
    self.hsitImageView.image = hits_image;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
     self.originImageView.image = image.normalizedImage;
//    UIImageOrientation orientation =  image.imageOrientation;
    [self cvMakeImage];
    
}



@end
