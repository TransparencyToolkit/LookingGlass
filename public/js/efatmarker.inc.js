            (function(){
		    var $ = document.id;
                    window.addEvent('domready', function(){
                    var markerButton = $('efm-button');
                    if ( markerButton ) {
                        eMarker = new EFatMarker($('uniquer'));
                        eMarker.tokenToSpans();
                        markerButton.addEvent('mousedown', function(){
                            eMarker.interpretSelection(true);
                            return false;
                        });

                        $('efm-unhighlightall').addEvent('mousedown', function(){
                            eMarker.unhighlightAll(true);
                            return false;
                        });
                        $('efm-unhighlight').addEvent('mousedown', function(){
                            eMarker.unhighlightSelection(true);
                            return false;
                        });
                        $('efm-highlight').addEvent('mousedown', function(){
                            eMarker.highlightSelection(true);
                            return false;
                        });
                        $('efm-permalink').addEvent('mousedown', function(){
                            window.location.href = this.href;
                            return false;
                        });
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
                        eMarker.syncDOM();
                        if (eMarker.hasSpans()) {
                            var scroll = new Fx.Scroll(
                                window, {
                                    offset: {
                                        'x': 0,'y': -100
                                    }
                                }
                            ),
                            highlights = $$('#uniquer .efm-hi');
                            if (highlights.length > 0) {
                                scroll.toElement(highlights[0]);
                            }
                        }
                    }
                });
            })();
