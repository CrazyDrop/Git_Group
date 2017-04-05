function getAllImgSrc()
{
    var arrayObj = new Array();
    $("a img").each(function(){
                  var src = $(this).attr("src");
                  arrayObj.push(src);
                  });
    var result = arrayObj.join("|");
    return result;
    return arrayObj;
};

function getAllImgSrcContent()
{
    var arrayObj = new Array();
    $(".content img").each(function(){
                    var src = $(this).attr("src");
                    arrayObj.push(src);
                    });
    var result = arrayObj.join("|");
    return result;
    return arrayObj;
};

function replaceWebImageUrlWithLocal(originSrc, newSrc)
{
    $("a img").each(function(){
                  if ($(this).attr("src") == originSrc) {
                  $(this).attr("src", newSrc);
                  };
                  });
    
};
