var setup = function() {
    $("[data-action='all-clear']").live("click", function() {
        $("#status_status").val("STATUS_OK");
        $("#status_form").submit();
    });
};

(function(){
    setup();
})();