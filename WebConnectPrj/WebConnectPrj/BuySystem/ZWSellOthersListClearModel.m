//
//  ZWSellOthersListClearModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/31.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSellOthersListClearModel.h"
#import "ZWDataDetailModel.h"

@implementation ZWSellOthersListClearModel

-(void)checkWebResponseWithResultDic:(NSDictionary *)dic
{
    NSInteger code  = [[dic valueForKey:@"return_code"] intValue];
//    NSArray * reslut = [ZWDataDetailModel dataArrayFromJsonArray:arr];
//    [self.dataArr addObjectsFromArray:reslut];
//    if(code == 0)
//    {
//        [self.dataArr addObject:@"成功"];
//    }else
    {
        
        NSString * str = [dic valueForKey:@"return_message"];
        if(!str || [str length]==0) str = @"成功";
        NSLog(@"%@",str);
        [self.dataArr addObject:str];
    }
    
}
-(NSArray *)defaultSortArray
{
    NSArray * arr =
    @[
      @"https://www.91zhiwang.com/api/pay/sms?amount=36148767&asset_id&bank_card_number=&bank_id=3&city=&coupon_id=0&coupon_type=0&crowd_fund_plan_id&deliver_address_id&device_guid=FD75E44A-B582-4A15-BC83-A176D2AD6C08&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&email&encrypt_type=1&insurance_secret_code&order_deduct_id=0&pay_account=bank_card&plan_id&product_id=89537&province=&reserve_phone=13051850106&selected_due_date=&session_id=b7f81095324e74d6f9f5c6dd5913d5c1ca86455b46c05b24334a65ba30b1996bb5fc4dc8a0b9485b795a1a3d4046df85161963dcd6e0fd4a&sn=210731950cc00dc6d2a1a9c35972fc5c&timestamp=1479709072739.956&trade_password=ktEvJqGe0enqpaMPcR-glyu6sxNbjoRgLQw643ElQmbXTloJ9Myp8jdm_PFd0F5KWapY_1jFayuOLWHOFcYBzIBr5Wwaza2m6y4s9zS6-1z0Z1R1jbf2XpPPYRfujGONFPt5hwuV_VsRm4g_B_5yobA3_Tng2m0cnfZYGVchQDs&unit_count&user_bank_account_id=491743&user_id=127431",
      @"https://www.91zhiwang.com/api/pay/sms?amount=30652734&asset_id&bank_card_number=&bank_id=3&city=&coupon_id=0&coupon_type=0&crowd_fund_plan_id&deliver_address_id&device_guid=FD75E44A-B582-4A15-BC83-A176D2AD6C08&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&email&encrypt_type=1&insurance_secret_code&order_deduct_id=0&pay_account=bank_card&plan_id&product_id=89501&province=&reserve_phone=13051850106&selected_due_date=&session_id=b7f81095324e74d6f9f5c6dd5913d5c1ca86455b46c05b24334a65ba30b1996bb5fc4dc8a0b9485b795a1a3d4046df85161963dcd6e0fd4a&sn=99547f6a23cf083375b1128759b1ec10&timestamp=1479709132195.342&trade_password=FXdskDqk4cW9FlmR4_Ih_66FYs0sYxSGFy_UBb9QsQDB9BnPBpQmLGTufexX6hZHX0d7TIl3B55mZv6p7fZ9Z_igaciBqSW89deOU9sqcEa_2krZ0mSo6P3ufHAp26o9nku0BQTKLRidrT6LtOeQuHGZNfctNK9O_RZZpFep5k0&unit_count&user_bank_account_id=491743&user_id=127431",
      @"https://www.91zhiwang.com/api/pay/sms?amount=31939362&asset_id&bank_card_number=&bank_id=3&city=&coupon_id=0&coupon_type=0&crowd_fund_plan_id&deliver_address_id&device_guid=FD75E44A-B582-4A15-BC83-A176D2AD6C08&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&email&encrypt_type=1&insurance_secret_code&order_deduct_id=0&pay_account=bank_card&plan_id&product_id=90144&province=&reserve_phone=13051850106&selected_due_date=&session_id=b7f81095324e74d6f9f5c6dd5913d5c1ca86455b46c05b24334a65ba30b1996bb5fc4dc8a0b9485b795a1a3d4046df85161963dcd6e0fd4a&sn=82b1a014bf2ef799801a17aa3f62ca58&timestamp=1479709162103.216&trade_password=pGdlFzwpCYDbAqhJvkDnvZbCESbX9W3KbhJU3sLvN9Um6Vjx9KMsMwYra27dF4JF8MqEOz3WrpMeu2aQ91UsZuQHiUmuEAmWRy4lc4jBV_QGS7lR7dedlGFfZy8xT_bE9FQbz0zioYp2pQS-d0OUgl5LgMaMnsjfyDiJ2hJpyRE&unit_count&user_bank_account_id=491743&user_id=127431"
      

      
      
      
      ];
    return arr;
    
}


@end
