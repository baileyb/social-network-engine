// Moved all .on() pageshow and pagebeforeshow here because once a page is loaded the javascript will either not be loaded again when
// returning to that page, or the .on() from another page will be run. 
//
// Also added page id so that each .on() will only apply to its applicable page.

$(document).on('pagebeforeshow', "#organizationsShow", function() {		
	//if multiple profiles have been viewed, jquerymobile will store all of the .postsButtons. The last one always seems to be the current one
	$(".organizationPostsButton :last", this).click();
});		

$(document).on('pagebeforeshow', "#usersShow",  function() {	
	//if multiple profiles have been viewed, jquerymobile will store all of the .postsButtons. The last one always seems to be the current one
	$(".userPostsButton :last", this).click();
});
		
//$(document).on("pageshow", "#index",  function() {
//	$.ajax({
//		beforeSend: function() { $.mobile.showPageLoadingMsg(); }, //Show spinner
//    complete: function() { $.mobile.hidePageLoadingMsg() }, //Hide spinner
//		url: "/reloadPosts"
//	});
//});

$(document).on('pageshow', "#done",  function() {	
  hide_header_footer();
});

$(document).on('pageshow', "#deviseNew",  function() {	
  hide_header_footer();
});

$(document).on('pageshow', "#loadAccount",  function() {	
  hide_header_footer();
});

$(document).on('pageshow', "#loadOrganizations",  function() {	
  hide_header_footer();
});

$(document).on('pageshow', "#signup",  function() {	
  hide_header_footer();
});