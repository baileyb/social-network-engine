var setup = function () {

    onPageShow("newPost");

    if ($("#submit_NewPost").length > 0) {
        $("#submit_NewPost").click(function () {
						if ($("#new_post_text").val().length > 0) {
							$("#post_text").val($("#new_post_text").val());	
							submitPost();	
						} 
				});
    }
};

(function () {
    setup();
})();