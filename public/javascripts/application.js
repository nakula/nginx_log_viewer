// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery('#404p').toggle(function(){
	jQuery.each(['200','301', '499', '500', '304', '302'], function(i, val){
		jQuery(jQuery("table")[1]).find("tr td:nth-child(3):contains('"+val+"')").parent().hide().next().hide();
	});
}, function(){
	jQuery.each(['200','301', '499', '500', '304', '302'], function(i, val){
		jQuery(jQuery("table")[1]).find("tr td:nth-child(3):contains('"+val+"')").parent().show();
	});
});

function poll() {
	$.get("/showpoll/Googlebot?start="+lastindex, function(data){
jQuery("tbody.red").css('background-color','white');
		jQuery(jQuery("table")[1]).append("<tbody class='red' style='background-color:#FFFFCC;'>" + data + "</tbody>");
	setTimeout("poll();", 10000);
	});
}

