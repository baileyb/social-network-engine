function pagination () {
    var bound = false;
    var currentPage = 1;
    var callback = null;


    function nearBottom() {
        return $(window).scrollTop() > $(document).height() - $(window).height() - 300;
    }

    return {
        check: function () {
            if (!bound) {
                $(window).scroll(this.check);
                bound = true
            }

            if (nearBottom()) {
                currentPage++;
                if (bound) {
                    $(window).unbind('scroll', this.check);
                    bound = false;
                }

                if (callback) {
                    callback(currentPage);
                }
            }

        },

        init: function(_callback, startingPage)
        {
            callback = _callback;
            if (startingPage)
            {
                currentPage = startingPage
            }
            return this;
        }
    };
}