require.config({
    paths: {
        jquery: "../bower_components/jquery/jquery",
        bootstrap: "vendor/bootstrap"
    },
    shim: {
        bootstrap: {
            deps: ["jquery"],
            exports: "jquery"
        }
    }
});

require(["app", "player", "world", "input", "jquery", "bootstrap", "requestAnimationFrame.polyfill"], function (App, Player, World, input, $) {
    "use strict";

    // Start the game!
    $(document).ready(function() {
        new App();
    });
});
