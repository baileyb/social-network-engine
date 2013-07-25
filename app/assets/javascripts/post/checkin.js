var setup = function() {

    if ($("#submit_AllClear").length > 0) {
        $("#submit_AllClear").click(function() {
            $("#status_status").val("STATUS_OK");
            submitPost();
        });
    }

    if ($("#submit_NeedHelp").length > 0) {
        $("#submit_NeedHelp").click(function() {
            $("#status_status").val("STATUS_NEEDS_HELP");
            submitPost();
        });
    }

    if ($("#submit_NeedAssistance").length > 0) {
        $("#submit_NeedAssistance").click(function() {
            $("#status_status").val("STATUS_NEEDS_ASSISTANCE");
            submitPost();
        });
    }
};

(function(){
    setup();
})();