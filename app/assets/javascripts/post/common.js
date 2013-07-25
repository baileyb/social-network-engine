function hidePicklist(prefix) {
    $("#" + prefix + "_picklist").hide();
    $("#" + prefix + "_change").find(".ui-icon").removeClass("ui-icon-arrow-u").addClass("ui-icon-arrow-d");
};

function showPicklist(prefix) {
    $("#" + prefix + "_picklist").show();
    $("#" + prefix + "_change").find(".ui-icon").removeClass("ui-icon-arrow-d").addClass("ui-icon-arrow-u");
};

function changeSelection(prefix, selected) {
    var self = $("#" + prefix + "_navbar").data("self");

    // Modify the background color
    if (selected == self) { $("#" + prefix + "_navbar").removeClass("orange").addClass("gray"); }
    else { $("#" + prefix + "_navbar").removeClass("gray").addClass("orange"); }

    // Set the "Posting As..." text
    var selected_text = $("#" + prefix + "_" + selected + "_label").data("text");
    $("#" + prefix + "_label").text("Posting as " + selected_text);

    // Set the selected data item on the navbar
    $("#" + prefix + "_navbar").data("selected", selected);

    // Call the server to set the session variable
    $.ajax({
        url: '/context',
        data: { id: selected },
        dataType: 'json'
    });
}

function setupBindings(prefix) {
    $("#" + prefix + "_change").click(function() {
        if ($("#" + prefix + "_picklist").is(":visible")) { hidePicklist(prefix); }
        else { showPicklist(prefix); }
    });

    $("#" + prefix + "_picklist").find("input[name='" + prefix + "_radio']").click(function() {
        changeSelection(prefix, $(this).attr("value"));
        $(this).attr("checked", "checked");
    });
};

function geotagPost(onSuccess) {
		$.mobile.showPageLoadingMsg();
    if (navigator.geolocation) {
        var watchID = navigator.geolocation.watchPosition(function (position) {
                if (position && position.coords && position.coords.latitude && position.coords.longitude) {
                    $("[id$='latitude']").val(position.coords.latitude);
                    $("[id$='longitude']").val(position.coords.longitude);

                    if (onSuccess) {
												onSuccess(position.coords.latitude, position.coords.longitude);
												$.mobile.hidePageLoadingMsg();
										}
                }
                navigator.geolocation.clearWatch(watchID);
            }, function (error) {
                console.log("in error block");
                navigator.geolocation.clearWatch(watchID);
								var errorText = "Geolocation Error: ";
								switch (error.code) {
                    case error.TIMEOUT:
												errorText += "Timeout";
                        break;
                    case error.POSITION_UNAVAILABLE:
												errorText += "Position Unavailable";
                        break;
                    case error.PERMISSION_DENIED:
												errorText += "Permission Denied";
                        break;
                    case error.UNKNOWN_ERROR:
												errorText += "Unknown Error";
                        break;
                }
								errorText += ".\nPlease turn on geolocation and give your device's browser permissions.\nPost without geolocation data?"
								$.mobile.hidePageLoadingMsg();
								var confirmPostAnyway=confirm(errorText);
								if (confirmPostAnyway == true) {
										onSuccess();
								}
            },
            {
                timeout: 5000, //5 seconds
                enableHighAccuracy: true
            });
        return;
    }
}

function submitPost(){
    geotagPost(function(){
        $("[id^='new']").submit();
    });
}

function onPageShow(prefix) {
    if ($("#" + prefix + "_navbar").length > 0) {
        // Setup the event handlers
        setupBindings(prefix);

        // Fire the click event on the initial selection
        var selected = $("#" + prefix + "_navbar").data("selected");
        selected = selected.toString().toUpperCase();
        $("input[value='" + selected + "']").trigger('click');
    }
}
