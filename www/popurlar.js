(function () {
    var Http = function() {
        /* TODO: Support IE */
        this.req = new XMLHttpRequest();
    };

    Http.prototype.serialize = function(obj) {
        var c = [];
        for (var i in obj) {
            c.push(encodeURIComponent(i) + '=' + encodeURIComponent(obj[i]));
        }
        return c.join("&");
    };

    Http.prototype.post = function(url, data, callback) {
        this.req.onreadystatechange = function () {
            var res = {};
            var callback = callback || function() {};

            if (this.readyState == 4) {
                if (this.status == 200) {
                    res.status = this.status;
                    res.text = this.responseText;
                    callback(res);
                }
            }
        };
        this.req.open("POST", url, true);
        this.req.setRequestHeader("Content-type","application/x-www-form-urlencoded");
        this.req.send(this.serialize(data));
    };

    Http.prototype.get = function(url, data, callback) {
        this.req.onreadystatechange = function () {
            var res = {};
            var callback = callback || function() {};

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
        this.settings = settings;
        this.alternatives = {};
        this.base = settings.base || "/";

        var http = new Http();
        // TODO: fix path
        http.post(this.base, { 
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
        }
    };

    // Manually track a view of current page
    Popurlar.prototype.track_view = function() {
        var http = new Http();
        // TODO: fix path
        http.post(this.base, { 
            project_id: this.settings.project_id,
            url: document.location.href
        });
    };

    window.Popurlar = Popurlar;
})();
