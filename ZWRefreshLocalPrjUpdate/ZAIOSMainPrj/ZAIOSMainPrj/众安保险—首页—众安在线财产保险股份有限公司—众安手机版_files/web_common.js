$(function(){
	//返回操作提示，弹出显示
	var tp ="400-999-9595";
	var msg_val = $("#msg").text();
	var alert_title;
	if (msg_val == "账号或密码错误") {
		alert_title = '<img style="display:block; width:25%; margin:0 auto;" src="/resource/image/error@2x.png" />';
	}
	else {
		alert_title = '<h1><span class="za_web_alert_kindly">温馨提示</span></h1>';
	}
	var th = $(document).height();
	var dch = $(window).height();
	var mask_h;
	if (th > dch) {
		mask_h = th;
	}else{
		mask_h = dch;
	}
	if(msg_val){
		if ( msg_val.indexOf(tp) >= 0 ){
			msg_val = '未查到此保单相关信息，如有疑问请拨打<a href="tel:400-999-9595">400-999-9595</a>';
		}
		var alertdom=
			'<div class="g_pop_mask" style="position:absolute;height:'+mask_h+'px;"></div>'+
			'<div class="g_pop animated bounceInUp" style="top: 0px; left: 0px; width: 100%;display:table;">'+
				'<div style="margin-top:50%;">'+
					'<div class="gp_wrap">'+
						'<div class="gp_title" style="display: block; margin-top:10px;">'+
							alert_title+
						'</div>'+
						'<div class="gp_hd">'+msg_val+'</div>'+
							'<div class="gp_ft">'+
								'<a class="z_d_ok" href="javascript:;" style="width:100%;">确定</a>'+
							'</div>'+
						'</div>'+
					'</div>'+
				'</div>'+
			'</div>';
		//alert(alertdom)
		//alert(msg_val);
		$("body").append(alertdom);
		$(".z_d_ok").on("click",function(){
			setTimeout(function() { 
				$(".g_pop_mask").hide();
		    },900);
			$(".g_pop").removeClass("bounceInUp").addClass("bounceOutDown");
		});
	}
	
	//身份证填充出生日期
	$(".Dc_num").on("blur",function() {
		if ($(this).parents("div").find(".Dc_type").val() == '1' || $(this).parents("div").find(".Dc_type").val() == 'I' ) {
			var cal = $(this).parents("div").find(".za_web_date");
			if ($(this).val() != "") {
		    	cal.val(getBirthdatByIdNo($(this).val()));
			} else {
		    	cal.val("");
			};
		};
	});
	//验证身份证号并获取出生日期
	function getBirthdatByIdNo(iIdNo) {
	    var tmpStr = "";
	    var strReturn = "";
	    if ((iIdNo.length != 15) && (iIdNo.length != 18)) {
	    	$(this).parents("p").next("p.error_alert").remove(); 
			$(this).parents("p").after("<p class='error_alert'>输入的身份证号位数错误</p>");
	        //strReturn = "输入的身份证号位数错误";
	        //return strReturn;
	    }
	    if (iIdNo.length == 15) {
	        tmpStr = iIdNo.substring(6, 12);
	        tmpStr = "19" + tmpStr;
	        tmpStr = tmpStr.substring(0, 4) + "-" + tmpStr.substring(4, 6) + "-" + tmpStr.substring(6);
	        //alert(tmpStr);
	        return tmpStr;
	    } else {
	        tmpStr = iIdNo.substring(6, 14);
	        tmpStr = tmpStr.substring(0, 4) + "-" + tmpStr.substring(4, 6) + "-" + tmpStr.substring(6);
	        //alert(tmpStr);
	        return tmpStr;
	    };
	}
	$("#za_web_careEw").on("click",function(){
		var th = $(document).height();
		var dch = $(window).height();
		var mask_h;
		if (th > dch) {
			mask_h = th;
		}else{
			mask_h = dch;
		}
		var Ewdom=
			'<div class="g_pop_mask" style="position:absolute;height:'+mask_h+'px;"></div>'+
			'<div class="g_pop" style="top: 0px; left: 0px; width: 100%;position:absolute;height:'+mask_h+'px;">'+
				'<div class="gp_wrap" style="position:absolute; bottom:100px;">'+
					'<div class="gp_hd"><img src="/resource/image/za_web_careEw.jpg" style="width:100%;" /></div>'+
				'</div>'+
			'</div>';
		$("body").append(Ewdom);
		var img_h = $(".gp_wrap").height();
		$(".g_pop").on("click",function(){
			$(".g_pop_mask").hide();
			$(".g_pop").hide();
		});
	});
});


// 对Date的扩展，将 Date 转化为指定格式的String 
// 月(M)、日(d)、小时(h)、分(m)、秒(s)、季度(q) 可以用 1-2 个占位符， 
// 年(y)可以用 1-4 个占位符，毫秒(S)只能用 1 个占位符(是 1-3 位的数字) 
// 例子： 
// (new Date()).Format("yyyy-MM-dd hh:mm:ss.S") ==> 2006-07-02 08:09:04.423 
// (new Date()).Format("yyyy-M-d h:m:s.S")      ==> 2006-7-2 8:9:4.18 
Date.prototype.Format = function(fmt) 
{ //author: meizz 
  var o = { 
    "M+" : this.getMonth()+1,                 //月份 
    "d+" : this.getDate(),                    //日 
    "h+" : this.getHours(),                   //小时 
    "m+" : this.getMinutes(),                 //分 
    "s+" : this.getSeconds(),                 //秒 
    "q+" : Math.floor((this.getMonth()+3)/3), //季度 
    "S"  : this.getMilliseconds()             //毫秒 
  }; 
  if(/(y+)/.test(fmt)) 
    fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length)); 
  for(var k in o) 
    if(new RegExp("("+ k +")").test(fmt)) 
  fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length))); 
  return fmt; 
};

//限定日期不能大雨当前时间
function datecal(objid){
	_this = $(objid);
	var nowdate = _this.val(); //你文本框中的值
    var today =new Date().Format("yyyy-MM-dd");  //当前日期
    //alert(nowdate > today);
    _this.attr("max",today);
    if ( nowdate > today){
    	//alert("出生日期不能大与今天");
    	$(objid).parents("p").next("p.error_alert3").remove(); 
    	$(objid).parents("p").after("<p class='error_alert3' style='text-indent:70px;'>出生日期不能大与今天</p>");
    	return false;
    }else{
    	_this.parents("p").next("p.error_alert3").remove(); 
    	return true;
    }
}

//通过出生日期计算年龄
function jsGetAge(strBirthday){       
    var returnAge;
    var strBirthdayArr=strBirthday.split("-");
    var birthYear = strBirthdayArr[0];
    var birthMonth = strBirthdayArr[1];
    var birthDay = strBirthdayArr[2];
    
    d = new Date();
    var nowYear = d.getFullYear();
    var nowMonth = d.getMonth() + 1;
    var nowDay = d.getDate();
    if(nowYear == birthYear){
        returnAge = 0;//同年 则为0岁
    }else{
        var ageDiff = nowYear - birthYear ; //年之差
        if(ageDiff > 0){
            if(nowMonth == birthMonth){
                var dayDiff = nowDay - birthDay;//日之差
                if(dayDiff < 0){
                    returnAge = ageDiff - 1;
                }else{
                    returnAge = ageDiff ;
                }
            }else{
                var monthDiff = nowMonth - birthMonth;//月之差
                if(monthDiff < 0){
                    returnAge = ageDiff - 1;
                }else{
                    returnAge = ageDiff ;
                }
            }
        }else{
            returnAge = -1;//返回-1 表示出生日期输入错误 晚于今天
        }
    }
    return returnAge;//返回周岁年龄
}

//计算两个日期的相差天数
function _stringDateDiff(startDate, endDate){
   var aDate, oDate1, oDate2, iDays ;
   aDate = startDate.split('-');
   oDate1 = new Date(aDate[1]+'-'+aDate[2]+'-'+aDate[0]) ;
   aDate = endDate.split('-');
   oDate2 = new Date(aDate[1]+'-'+ aDate[2] +'-'+aDate[0]);
   iDays = parseInt(Math.abs(oDate1 -oDate2)/1000/60/60/24); //把相差的毫秒数转换为天数
   return iDays ;
}


//计算两个日期的相差天数
function _dateDateDiff(startDate, endDate){
   iDays = parseInt((startDate -endDate)/1000/60/60/24); //把相差的毫秒数转换为天数
   return iDays ;
}

//百度统计
var _hmt = _hmt || [];
(function() {
var hm = document.createElement("script");
hm.src = "//hm.baidu.com/hm.js?b7644745bc16bb3843c74c4a8a01df1b";
var s = document.getElementsByTagName("script")[0]; 
s.parentNode.insertBefore(hm, s);
})();


//GA统计
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	  ga('create', 'UA-61955298-2', 'auto');
	  ga('send', 'pageview');