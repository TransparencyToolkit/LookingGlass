/*!

EFatMarker Copyright (C) 2013 Raymond Hill
https://github.com/gorhill/efatmarker
Version: 20130422
http://opensource.org/licenses/MIT

**/

/*jslint browser: true, bitwise: true, plusplus: true, todo: true, vars: true, white: true */

(function() {

"use strict";

/******************************************************************************/

// http://jsperf.com/cache-window-document-or-not
// This also help the minifier to further minify

var win = window,
    doc = win.document;

/******************************************************************************/

var EFatMarker = function() {
    var node = doc.querySelector(".efm-target");
    if (!node) {
        throw "EFatMarker: no element with class 'efm-target' found.";
        }

    this.parentNode = node;

    // collect text and index-node pairs
    var textmap = [],
        iNode = 0,
        nNodes = node.childNodes.length,
        nodeText,
        textLength = 0,
        stack = [],
        child, nChildren,
        state;
    for (;;) {
        while (iNode < nNodes){
            child = node.childNodes[iNode];
            iNode += 1;
            // text: collect and save index-node pair
            if (child.nodeType === 3) {
                textmap.push({i:textLength, n:child});
                nodeText = child.nodeValue;
                textLength += nodeText.length;
                }
            // element: collect text of child elements,
            // except from script or style tags
            else if (child.nodeType === 1) {
                // save parent's loop state
                nChildren = child.childNodes.length;
                if (nChildren) {
                    stack.push({n: node, l: nNodes, i: iNode});
                    // initialize child's loop
                    node = child;
                    nNodes = nChildren;
                    iNode = 0;
                    }
                }
            }
        // restore parent's loop state
        if (!stack.length) {
            break;
            }
        state = stack.pop();
        node = state.n;
        nNodes = state.l;
        iNode = state.i;
        }

    // sentinel
    textmap.push({i:textLength});

    // store for later use
    this.textmap = textmap;
    this.textLength = textLength;

    // initialize other properties
    this.spans = [];

    // encode 18-bit integer into 3 base-64 url-friendly characters
    this.base64Digits = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

    // methods
    this.tokenToSpans = function() {
        var token = win.location.hash || '',
            matches;
        // token must be perfectly formatted, or else reject it
        matches = token.match(/^#efm(([\-\w]{6}){1,})/);
        if (!matches || !matches.length) {
            return;
            }
        token = matches[1];
        this.spans = [];
        var b64s = this.base64Digits,
            i, n,
            start, end,
            fragment;
        for (i=0, n=token.length; i<n; i+=6) {
            fragment = token.substr(i,6);
            start = (b64s.indexOf(fragment.charAt(0))<<12) + (b64s.indexOf(fragment.charAt(1))<<6) + b64s.indexOf(fragment.charAt(2));
            end = (b64s.indexOf(fragment.charAt(3))<<12) + (b64s.indexOf(fragment.charAt(4))<<6) + b64s.indexOf(fragment.charAt(5));
            this.addSpan(start, end);
            }
        };

    this.spansToToken = function() {
        var n = this.spans.length;
        // We need to return a non-empty token, or else Firefox will
        // move to the top of the page.
        // TODO: check behavior in other browsers.
        if (!n) {
            return '#efm';
            }
        var b64s = this.base64Digits,
            token = ['#efm'],
            i, entry,
            start, end;
        for (i=0; i<n; i++) {
            entry = this.spans[i];
            start = entry.start;
            end = entry.end;
            token.push(String(b64s[start>>12&0x3F]) + String(b64s[start>>6&0x3F]) + String(b64s[start&0x3F]));
            token.push(String(b64s[end>>12&0x3F]) + String(b64s[end>>6&0x3F]) + String(b64s[end&0x3F]));
            }
        return token.join('');
        };

    this.addSpan = function(start, end) {
        // spans must be ordered
        // normalize span
        if (start > end) {
            var tmp = start;
            start = end;
            end = tmp;
            }
        start = Math.max(0, start);
        end = Math.min(this.textLength, end);
        if (start === end) {return;}
        // find insertion point
        var spans = this.spans,
            n = spans.length,
            i, span,
            iLeft = 0,
            iRight = n;
        while (iLeft < iRight) {
            i=iLeft + iRight >> 1;
            if (end < spans[i].start) {iRight = i;}
            else if (start > spans[i].end) {iLeft = i+1;}
            else {iRight = i;}
            }
        // merge spans which intersect
        while (iRight < n) {
            span = spans[iRight];
            if (span.start > end) {
                break;
                }
            start = Math.min(span.start, start);
            end = Math.max(span.end, end);
            iRight++;
            }
        // insert
        spans.splice(iLeft, iRight-iLeft, {start: start, end: end});
        };

    this.removeSpans = function(start, end) {
        // spans must be ordered
        // normalize span
        if (start > end) {
            var tmp = start;
            start = end;
            end = tmp;
            }
        start = Math.max(0, start);
        end = Math.min(this.textLength, end);
        if (start === end) {return;}
        // find insertion point
        var spans = this.spans,
            n = spans.length,
            i, span,
            iLeft = 0,
            iRight = n;
        while (iLeft < iRight) {
            i=iLeft + iRight >> 1;
            if (end <= spans[i].start) {iRight = i;}
            else if (start >= spans[i].end) {iLeft = i+1;}
            else {iRight = i;}
            }
        // exclude spans which intersect
        var toremove_start,
            toremove_end;
        while (iRight < n) {
            span = spans[iRight];
            if (span.start > end) {
                break;
                }
            toremove_start = Math.max(span.start, start);
            toremove_end = Math.min(span.end, end);
            // remove span within span
            if (toremove_start > span.start && toremove_end < span.end) {
                spans.splice(iRight+1, 0, {start: toremove_end, end: span.end});
                span.end = toremove_start;
                iRight+=2;
                n++;
                }
            // remove span from start
            else if (toremove_start === span.start && toremove_end < span.end) {
                span.start = toremove_end;
                iRight++;
                }
            // remove span from end
            else if (toremove_start > span.start && toremove_end === span.end) {
                span.end = toremove_start;
                iRight++;
                }
            // remove span
            else {
                spans.splice(iRight, 1);
                n--;
                }
            }
        };

    this.unhighlightAll = function(render) {
        this.spans = [];
        if (render) {
            if (win.getSelection) {
                var selection = win.getSelection();
                if (selection) {
                    win.getSelection().removeAllRanges();
                    }
                }
            this.syncDOMAll();
            }
        };

    this.spanInSpan = function(start, end) {
        var spans = this.spans,
            i = spans.length,
            span;
        while (i-- > 0) {
            span = spans[i];
            if (start >= span.start && end <= span.end) {
                return true;
                }
            }
        return false;
        };

    this.hasSpans = function() {
        return this.spans.length > 0;
        };

    this.highlightSelection = function(render) {
        if (!win.getSelection) {return;}
        var selection = win.getSelection();
        if (!selection) {return;}
        var iRange, range,
            iTextStart, iTextEnd;
        for (iRange=0; iRange<selection.rangeCount; iRange++) {
            range = selection.getRangeAt(iRange);
            // convert to target container world
            iTextStart = this.normalizeOffset(range.startContainer, range.startOffset);
            iTextEnd   = this.normalizeOffset(range.endContainer, range.endOffset);
            if (iTextStart >= 0 && iTextStart < iTextEnd) {
                this.addSpan(iTextStart, iTextEnd);
                }
            }
        if (render) {
            selection.removeAllRanges();
            this.syncDOMAll();
            }
        };

    this.unhighlightSelection = function(render) {
        if (!win.getSelection) {return;}
        var selection = win.getSelection();
        if (!selection) {return;}
        var iRange, range,
            iTextStart, iTextEnd;
        for (iRange=0; iRange<selection.rangeCount; iRange++) {
            range = selection.getRangeAt(iRange);
            // convert to target container world
            iTextStart = this.normalizeOffset(range.startContainer, range.startOffset);
            iTextEnd   = this.normalizeOffset(range.endContainer, range.endOffset);
            if (iTextStart >= 0 && iTextStart < iTextEnd) {
                this.removeSpans(iTextStart, iTextEnd);
                }
            }
        if (render) {
            selection.removeAllRanges();
            this.syncDOMAll();
            }
        };

    this.interpretSelection = function(render) {
        if (!win.getSelection) {return;}
        var selection = win.getSelection();
        if (!selection) {return;}
        var iRange, range,
            iTextStart, iTextEnd;
        for (iRange=0; iRange<selection.rangeCount; iRange++) {
            range = selection.getRangeAt(iRange);
            // convert to target container world
            iTextStart = this.normalizeOffset(range.startContainer, range.startOffset);
            iTextEnd   = this.normalizeOffset(range.endContainer, range.endOffset);
            if (iTextStart >= 0 && iTextStart < iTextEnd) {
                // first check whether a range is completely within
                // a single span, and if so we remove this span
                if (this.spanInSpan(iTextStart, iTextEnd)) {
                    this.removeSpans(iTextStart, iTextEnd);
                    }
                else {
                    this.addSpan(iTextStart, iTextEnd);
                    }
                }
            }
        if (render) {
            selection.removeAllRanges();
            this.syncDOMAll();
            }
        };

    // There are different to synchronize DOM with internal state:
    // * Synchronize highlights.
    // * Synchronize EFatMarker menu entries.
    // * Synchronize window hash.
    // We may not want all of the above to be synchronized at once,
    // example(s):
    // * When page load for first time, we want to leave hash untouched, as
    //   there maybe an hash which is meaningless to EFatMarker, but meaningful
    //   for the browser.
    // TODO: identify other cases, if any.
    this.syncDOMAll = function() {
        this.syncDOMHighlights();
        this.syncDOMHash();
        this.syncDOMMenu();
        };

    this.syncDOMHighlights = function() {
        this.unrender();
        this.render();
        };

    this.syncDOMHash = function() {
        var token = this.spansToToken();
        win.location.hash = token;
        };

    // Meant to be called once when the page is loaded, after
    // EFatMarker.render() has been called.
    this.syncDOMGotoFirstAnchor = function() {
        // First highlight will be given the current token value as
        // an anchor, so that when page is first shown, first highlight is
        // within view.
        if (this.hasSpans()) {
            var highlight = doc.querySelector(".efm-parent");
            if (highlight) {
                var token = this.spansToToken();
                highlight.id = token.substr(1);
                // Yeah, that's to force the browser to react to our new
                // anchor...
                win.location.hash = "#efm";
                win.location.hash = token;
                }
            }
        };

    this.syncDOMMenu = function() {
        // update permalink
        var el = doc.querySelector('#efm-permalink input'),
            href = win.location.href,
            token = this.spansToToken();
        if (el) {
            el.value = token ? href : '';
            }
        // prepare a tweeter button for these highlights
        el = doc.getElementById('efm-twitter-button');
        if (el) {
            var queryComponents = [];
            queryComponents.push('url=' + String(encodeURIComponent(href)));
            queryComponents.push('text=' + encodeURIComponent(doc.querySelector('head title').innerHTML));
            var canonicalUrl = doc.querySelector('head link[rel="canonical"]');
            if (canonicalUrl) {
                queryComponents.push('counturl=' + String(encodeURIComponent(canonicalUrl.href)));
                }
            el.href = 'https:\/\/twitter.com\/share?' + queryComponents.join('&');
            }
        // enable/disable options which need at least one highlight
        var elems = doc.querySelectorAll('.efm-need-highlight'),
            n = elems.length,
            hasHighlight = this.hasSpans();
        while (n--){
            elems[n].style.display = hasHighlight ? '' : 'none';
            }
        };

    this.unrender = function() {
        var textmap = this.textmap,
            i = textmap.length-1,
            entry, efmNode, efmParent;
        // 1st pass, remove hilights
        while (i-- > 0) {
            entry = textmap[i];
            efmNode = entry.n.parentNode;
            // rhill 2011-09-14: parent node can be null, when
            // the text of an element node is modified (Ideally, this
            // should not be allowed as this risk of screwing up the
            // reliability of offsets. Fortunately in the current case,
            // the text is replaced with same length.)
            if (efmNode && efmNode.className && efmNode.className === 'efm-hi') {
                efmNode.parentNode.replaceChild(entry.n, efmNode);
                }
            }
        // 2nd pass, remove highlight parents
        i = textmap.length-1;
        while (i-- > 0) {
            entry = textmap[i];
            efmParent = entry.n.parentNode;
            // rhill 2011-09-14: parent node can be null, when
            // the text of an element node is modified (Ideally, this
            // should not be allowed as this risk of screwing up the
            // reliability of offsets. Fortunately in the current case,
            // the text is replaced with same length.)
            if (efmNode && efmNode.className && efmParent.className === 'efm-parent') {
                while (efmParent.hasChildNodes()) {
                    efmParent.parentNode.insertBefore(efmParent.firstChild, efmParent);
                    }
                efmParent.parentNode.removeChild(efmParent);
                }
            }
        // TODO: 3rd pass, merge adjacent text nodes
        // [optional, might be nice to reduce fragmentation of DOM tree]
        // looks like this may be required to prevent browser from 
        // reinterpreting incorrectly white space characters...
        };

    this.render = function() {
        var spans = this.spans,
            i = spans.length,
            span;
        while (i-- > 0) {
            span = spans[i];
            this.renderSpan(span.start, span.end);
            }
        };

    // hmm, trailing white spaces need to be included, as
    // it appears the browser interpret differently trailing
    // white spaces and leading white spaces.. have to read
    // more
    // rhill 2012-08-23: this is not an issue if white-space are
    // preserved (i.e. pre, pre-wrap, etc.), otherwise this is an
    // issue, possible solution maybe to replace first white-space
    // with one non-standard white-space-like character which the
    // browser won't eat
    // (see http://www.cs.tut.fi/~jkorpela/chars/spaces.html)
    this.renderSpan = function(iTextStart, iTextEnd) {
        var textmap = this.textmap,
            i, iLeft, iRight,
            iEntry, entry, entryStart, entryText,
            whitespaces,
            iNodeTextStart, iNodeTextEnd,
            efmParentNode, efmNode, efmTextNode;

        // find entry in textmap array (using binary search)
        iLeft = 0;
        iRight = textmap.length;
        while (iLeft < iRight) {
            i=iLeft + iRight >> 1;
            if (iTextStart < textmap[i].i){iRight = i;}
            else if (iTextStart >= textmap[i+1].i){iLeft = i + 1;}
            else {iLeft = iRight = i;}
            }
        iEntry = iLeft;
        iRight = textmap.length;
        while (iEntry < iRight) {
            entry = textmap[iEntry];
            entryStart = entry.i;
            entryText = entry.n.nodeValue;
            iNodeTextStart = iTextStart - entryStart;
            iNodeTextEnd = Math.min(iTextEnd,textmap[iEntry+1].i) - entryStart;
            // rhill 2011-09-07: include trailing white space(s), or else these
            // become leading white space(s), and the browser interpret them
            // differently
//            whitespaces = entryText.substring(iNodeTextEnd).match(/^\s+/);
//            if (whitespaces && whitespaces.length) {
//                iNodeTextEnd += whitespaces[0].length;
//                }
            // remove entry, we will create new entry reflecting new structure
            textmap.splice(iEntry, 1);
            // create parent node which will receive the (up to three) child nodes
            efmParentNode = doc.createElement('span');
            efmParentNode.className = 'efm-parent';
            // slice of text before hilighted slice
            if (iNodeTextStart > 0){
                efmTextNode = doc.createTextNode(entryText.substring(0,iNodeTextStart));
                efmParentNode.appendChild(efmTextNode);
                textmap.splice(iEntry, 0, {i:entryStart, n:efmTextNode});
                entryStart += efmTextNode.length;
                iEntry++;
                }
            // highlighted slice
            efmNode = doc.createElement('span');
            efmTextNode = doc.createTextNode(entryText.substring(iNodeTextStart, iNodeTextEnd));
            efmNode.appendChild(efmTextNode);
            efmNode.className = 'efm-hi';
            efmParentNode.appendChild(efmNode);
            textmap.splice(iEntry, 0, {i:entryStart, n:efmTextNode});
            entryStart += efmTextNode.length;
            iEntry++;
            // slice of text after hilighted slice
            if (iNodeTextEnd < entryText.length){
                efmTextNode = doc.createTextNode(entryText.substr(iNodeTextEnd));
                efmParentNode.appendChild(efmTextNode);
                textmap.splice(iEntry, 0, {i:entryStart, n:efmTextNode});
                entryStart += efmTextNode.length;
                iEntry++;
                }
            // replace text node with our efm parent node
            entry.n.parentNode.replaceChild(efmParentNode, entry.n);
            // if the match doesn't intersect with the following
            // index-node pair, this means this match is completed
            if (iTextEnd <= textmap[iEntry].i){
                break;
                }
            }
        };

    this.getTextNodes = function() {
        };

    this.normalizeOffset = function(textNode, offset) {
        if (textNode.nodeType !== 3) {
            return -1;
            }
        // Just ensure that whatever text node is passed is really a descendant
        // of our EFatMarker's target container.
        // TODO: Probably unecessary check, since the text node won't be found
        //       in our internal textnode-offset pairs anyway..
        var node = textNode;
        while (node) {
            node = node.parentNode;
            if (node === this.parentNode) {
                break;
                }
            }
        if (!node) {
            return -1;
            }
        // Find entry in textmap array (using binary search)
        var textmap = this.textmap,
            iEntry = textmap.length,
            entry;
        while (iEntry-- > 0) {
            entry = textmap[iEntry];
            if (textNode === entry.n) {
                return entry.i + offset;
                }
            }
        return -1;
        };
    };

    win.addEventListener('load', function(){
        var eMarker = new EFatMarker();
        if (!eMarker) { return; }
        eMarker.tokenToSpans(); // apply whatever token is there

        // Add EFatMarker button, to specified target container, or if none
        // found, to body element.

        var markerButtonContainer = doc.querySelector('.efm-button-container');
        if (!markerButtonContainer) {
            markerButtonContainer = doc.createElement('div');
            markerButtonContainer.className = 'efm-button-container';
            markerButtonContainer.style.position = 'fixed';
            markerButtonContainer.style.right = '0';
            markerButtonContainer.style.bottom = '0';
            doc.body.appendChild(markerButtonContainer);
            }
        var markerButton = doc.createElement("div");
        markerButton.id = "efm-button";
        markerButton.innerHTML =
              '<div id="efm-menu">'
            + '<h3 style="margin:0 0 2px 0">EFatMarker<\/h3>'
            + '<p class="efm-menu-separator efm-need-highlight"><\/p>'
            + '<p id="efm-permalink" class="efm-need-highlight">Permalink with highlights:<br>'
            + '<input type="text" readonly="readonly" value=""><\/p>'
            + '<p class="efm-menu-separator efm-need-highlight"><\/p>'
            + '<a id="efm-twitter-button" class="efm-need-highlight" href="#" target="_blank">these highlights<\/a>'
            + '<p class="efm-menu-separator"><\/p>'
            + '<a id="efm-unhighlightall" class="efm-need-highlight">Un-highlight all<\/a>'
            + '<a id="efm-unhighlight">Un-highlight selection<span>u<\/span><\/a>'
            + '<a id="efm-highlight">Highlight selection<span>h</span><\/a>'
            + '<\/div>';
        markerButtonContainer.appendChild(markerButton);
        // need to act on mousedown or else selection disappear
        markerButton.addEventListener('mousedown', function(event){
            eMarker.interpretSelection(true);
            event.preventDefault();
            });
        var elem = doc.querySelector('#efm-unhighlightall');
        if (elem){
            elem.addEventListener('mousedown', function(event){
                eMarker.unhighlightAll(true);
                event.preventDefault();
                });
            }
        elem = doc.querySelector('#efm-unhighlight');
        if (elem){
            elem.addEventListener('mousedown', function(event){
                eMarker.unhighlightSelection(true);
                event.preventDefault();
                });
            }
        elem = doc.querySelector('#efm-highlight');
        if (elem){
            elem.addEventListener('mousedown', function(event){
                eMarker.highlightSelection(true);
                event.preventDefault();
                });
            }
        elem = doc.querySelector('#efm-permalink > input');
        if (elem){
            elem.addEventListener('click', function(event){
                this.select();
                });
            }
        // TODO: Put back keybord support without having to depend on a
        // specific framework.
        // if Mootools Keyboard is available, use it
/*
        if (Keyboard) {
            var keyboard = new Keyboard({
                defaultEventType: 'keyup',
                events: {
                    'h': function(){
                        eMarker.highlightSelection(true);
                        },
                    'u': function(){
                        eMarker.unhighlightSelection(true);
                        }
                    }
                });
            keyboard.activate();
            }
*/        

        eMarker.syncDOMHighlights();
        eMarker.syncDOMMenu();
        // Try to auto scroll to first highlight, if any. Fallback on
        // using plain old anchor if no framework detected for a slick
        // animation.
        if (eMarker.hasSpans()) {
            if (typeof jQuery === 'function') {
                jQuery('body,html').animate({scrollTop: parseInt(jQuery('.efm-parent').offset().top, 10) - 50});
                }
           else if (typeof Fx === 'function') {
                var highlight = doc.querySelector('.efm-parent');
                if (highlight) {
                    var scroll = new Fx.Scroll(win, {offset:{'x':0,'y':-50}});
                    scroll.toElement(highlight);
                    }
                }
            else {
                eMarker.syncDOMGotoFirstAnchor();
                }
            }
        });

/******************************************************************************/

}());
