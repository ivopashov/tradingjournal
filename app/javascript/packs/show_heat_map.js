function performanceClass(change) {
    if (change >= 0 && change < 0.5) {
        return "color-green-1";
    } else if (change >= 0.5 && change < 1) {
        return "color-green-2";
    } else if (change >= 1 && change < 2.5) {
        return "color-green-3";
    } else if (change >= 2.5 && change < 5) {
        return "color-green-4";
    } else if (change >= 5 && change < 7.5) {
        return "color-green-5";
    } else if (change >= 7.5 && change < 10) {
        return "color-green-6";
    } else if (change >= 10 && change < 15) {
        return "color-green-7";
    } else if (change >= 15 && change < 25) {
        return "color-green-8";
    } else if (change >= 25 && change < 50) {
        return "color-green-9";
    } else if (change >= 50) {
        return "color-green-10";
    } else if (change < 0 && change >= -0.5) {
        return "color-red-1";
    } else if (change < -0.5 && change >= -1) {
        return "color-red-2";
    } else if (change < -1 && change >= -2.5) {
        return "color-red-3";
    } else if (change < -2.5 && change >= -5) {
        return "color-red-4";
    } else if (change < -5 && change >= -7.5) {
        return "color-red-5";
    } else if (change < -7.5 && change >= -10) {
        return "color-red-6";
    } else if (change < -10 && change >= -15) {
        return "color-red-7";
    } else if (change < -15 && change >= -20) {
        return "color-red-8";
    } else if (change < -20 && change >= -30) {
        return "color-red-9";
    } else if (change < -30) {
        return "color-red-10";
    } else if (change == "no data") {
        return "grey";
    }
}

$(".js-performance-percentages").each(function () {
    let performance = $(this).text();
    $(this).addClass(performanceClass(parseFloat(performance)));
});

$(".js-stock").each(function() {
    let elementClassForColoring = performanceClass($(this).data("performance-1d"));
    $(this).addClass(elementClassForColoring);
});

$(".js-stock-with-data").on("click", function () {
    let ticker = $(this).data("symbol");
    new TradingView.widget({
        "container_id": "technical-analysis",
        "width": "100%",
        "height": 600,
        "symbol": ticker,
        "interval": "D",
        "timezone": "exchange",
        "theme": "dark",
        "style": "1",
        "toolbar_bg": "#f1f3f6",
        "withdateranges": true,
        "hide_side_toolbar": true,
        "allow_symbol_change": false,
        "save_image": false,
        "studies": [
            "StochasticRSI@tv-basicstudies"
        ],
        "show_popup_button": true,
        "popup_width": "1000",
        "popup_height": "650",
        "locale": "en"
    });

    $(".tradingview-widget-copyright").show();
});