$(document).ready(function () {
    function getQueryString(name) {
      name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
      var regexS = "[\\?&]" + name + "=([^&#]*)";
      var regex = new RegExp(regexS);
      var results = regex.exec(window.location.search);
      if(results == null) {
        return "";
      } else {
        return decodeURIComponent(results[1].replace(/\+/g, " "));
      }
    }

    // auto refresh posts
    setInterval(function () {

        if ($("#posts").is(":visible") == true) {
            var token = $('#posts').data('token');

            $.get('/refresh', { token: token, f: getQueryString("f") }).done(function (data) {
                var jqHtml = $(data);
                var newToken = jqHtml.children("#token").text();
                if (newToken) {
                    $("#posts").data('token', newToken);
                }

                var feedItems = jqHtml.children(".feed-item");

                if (feedItems.length > 0) {
                    $("#posts").prepend(feedItems);
                }

                if (parseInt(jqHtml.children("#max-distance").text()) > 1 )
                {
                    $('#geo-filter-panel').append('<input type="range" id="radius" name="radius" id="slider-fill-mini" value="1" min="0" max="10" step="5" data-highlight="true">');
                }

            });
        }

    }, 10000);
});
