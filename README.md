popurlar
========

Link tracker


Setup
=====
Requires OpenResty.

Setup at bottom of `<body>` tag.
``
<script type="text/javascript" src="http://mytrackerpage.com/popurlar.js"></script>
<script type="text/javascript">
    (function() {
        var track = new Popurlar({
            project_id: 1
        });
    })();
</script>
``
