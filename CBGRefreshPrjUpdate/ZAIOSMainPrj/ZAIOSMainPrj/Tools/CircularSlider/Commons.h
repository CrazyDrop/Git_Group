//
//  Commons.h
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#ifndef TB_CircularSlider_Commons_h
#define TB_CircularSlider_Commons_h

#define TB_HANDLESIZE           40
/** Parameters **/
#define TB_SLIDER_SIZE 320                          //The width and the heigth of the slider
#define TB_BACKGROUND_WIDTH FLoatChange(18)         //The width of the dark background
#define TB_LINE_WIDTH FLoatChange(18)               //The width of the active area (the gradient) and the width of the handle
#define TB_FONTSIZE 10
//The size of the textfield font
#define TB_FONTFAMILY @"Futura-CondensedExtraBold"  //The font family of the textfield font

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING (40 + TB_LINE_WIDTH / 2.0)

#define TB_SLIDER_SELECTED_COLOR        [UIColor whiteColor]
#define TB_SLIDER_UNSELECTED_COLOR      [DZUtils colorWithHex:@"ecfdf6"]
#define TB_SLIDER_HEIGHT1_LINE_COLOR      [DZUtils colorWithHex:@"18b583"]

#endif
