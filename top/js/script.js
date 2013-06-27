function addCommas(e) {
    e += "", x = e.split("."), x1 = x[0], x2 = x.length > 1 ? "." + x[1] : "";
    var t = /(\d+)(\d{3})/;
    while (t.test(x1))
        x1 = x1.replace(t, "$1,$2");
    return x1 + x2
}

function roundNumber(e, t) {
    var n = Math.round(e * Math.pow(10, t)) / Math.pow(10, t);
    return n
}























