function addCommas(e) {
    e += "", x = e.split("."), x1 = x[0], x2 = x.length > 1 ? "." + x[1] : "";
    var t = /(\d+)(\d{3})/;
    while (t.test(x1))
        x1 = x1.replace(t, "$1,$2");
    return x1 + x2
}

function levenshteinDistance (s, t) {
        if (!s.length) return t.length;
        if (!t.length) return s.length;
 
        return Math.min(
                levenshteinDistance(s.substr(1), t) + 1,
                levenshteinDistance(t.substr(1), s) + 1,
                levenshteinDistance(s.substr(1), t.substr(1)) + (s[0] !== t[0] ? 1 : 0)
        );
}

function roundNumber(e, t) {
    var n = Math.round(e * Math.pow(10, t)) / Math.pow(10, t);
    return n
}

function toPercentage(n) {
  return roundNumber(n * 100, 0) + "%";
}

function shorten_nicely_with_ellipsis(){
    var str = arguments[1];
    var truncating = !!arguments[2];

    // If we're not already breaking on a whitespace character, loop
    // backwards over the string, and break on the first character of
    // the first group of whitespace characters we find. 
    if( truncating && !arguments[2].match(/^\s/) ) {
        for(var i=str.length; --i; i<=1) {
            if( str[i].match(/\s/) && !str[i-1].match(/\s/) ) {
                str = arguments[1].substr(0, i);
                break;
            }
        }
    }

    if( truncating ) {                
        str = str + '...';
    }

    return str;
}

// String.prototype.truncate = function(tlength){
//   var re = this.match(/^.{0,25}[\\S]*/);
//   var l = re[0].length;
//   var re = re[0].replace(/\\s$/,'');
//   if(l < this.length)
//     re = re + "&hellip;";
//   return re;
// }

function truncate(str, limit) {
  var bits, i;
	bits = str.split('');
	if (bits.length > limit) {
		for (i = bits.length - 1; i > -1; --i) {
			if (i > limit) {
				bits.length = i;
			}
			else if (' ' === bits[i]) {
				bits.length = i;
				break;
			}
		}
		bits.push('...');
	}
	return bits.join('');
}
























