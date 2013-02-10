(function () {
    var Http = function() {
        /* TODO: Support IE */
        this.req = new XMLHttpRequest();
    };

    Http.prototype.get = function(url, data, callback) {
        this.req.onreadystatechange = function () {
            var res = null;

            if (this.readyState == 4) {
                if (this.status == 200) {
                    res.status = this.status;
                    res.text = this.responseText;
                    callback(res);
                }
            }
        };
        this.req.open("GET", url, true);
        this.req.send(data);
    };

    var Popurlar = function(settings) {
        this.settings = settins;
        this.alternatives = {};

        var http = new Http();
        http.get('/track/', { 
                project_id: this.settings.project_id
        }, function (res) {
            this.alternatives = res.text;
        });
    };

    Popurlar.prototype.randomize_link_text = function(selector) {
        var elements = document.querySelectorAll(selector);

        for (var i in elements) {
            if (typeof(elements[i]) != 'object')
                continue;
            
            var title = elements[i].querySelectorAll(this.settings.link_text_selector);
            var choice = Math.floor(Math.random() * this.alternatives[elements[i]].length);
            title.textContent = this.alternatives[elements[i]][choice];
            title.setAttribute('data-alternative-num', choice);
    };

    window.popurlar = popurlar;
})();


/* Test */
var pop = new Popurlar({
    project_id: 1,
    link_text_selector: 'a',
    link_text_alternatives_selector: '.premable',
});

pop.randomize_link_text();
pop.track_view(); 

