/* global.js */

var datetimepicker_icons = {
    time: 'icon-clock',
    date: 'icon-calendar',
    up:   'icon-arrow-up',
    down: 'icon-arrow-down',
    previous: 'icon-arrow-left',
    next:  'icon-arrow-right',
    today: 'icon-camera',
    clear: 'icon-trash',
    close: 'icon-circle-x'
}


// Stick Alerts
$('.close-alert').on('click', function() {
    var alert_name = $(this).parent().attr('id')
    localStorage[alert_name] = true
})

