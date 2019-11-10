/* search.js */

var renderSearchFields = function(value, type, hr_field_label) {

    // Hide Forms
    $('#form-search-all').hide();
    $('#form-search-string').hide();
    $('#form-search-date').hide();
    $('#form-search-datetime').hide();

    console.log('change #ftypes with: ' + type)

    // Modify Fields
    if (type === 'date') {
	    $('#search-date-start').attr('name', 'startrange_' + value)
	    $('#search-date-end').attr('name', 'endrange_' + value)

        $('[data-behaviour~=datepicker]').datetimepicker({
            format: 'MM/DD/YYYY',
            icons: datetimepicker_icons
        })
    }
    else if (type === 'datetime') {
        // TODO: make timestamp values convert to readable format & vv
        console.log($('#search-datetime-start').val() + ' ' + $('#search-datetime-end').val())

        // moment.unix(1576321936).format("YYYY-MM-DD hh:mm");
        $('#search-datetime-start').attr('name', 'startrange_' + value)
	    $('#search-datetime-end').attr('name', 'endrange_' + value)

        console.log(datetimepicker_icons)
        $('[data-behaviour~=datetimepicker]').datetimepicker({
            extraFormats: ['X', 'x'],
            format: 'X',
            icons: datetimepicker_icons
        })
    }
    else if (type === 'string') {

      $('#form-search-' + type)
        .find('input[type=text]')
        .attr('name', value)
        .attr('placeholder', 'Search ' + hr_field_label)

      // Style & Fill Form Field
      var form_field = $('#form-search-' + type).find('input[type=text]')

      if (search_query[value] !== undefined) {
        form_field
          .attr('name', value)
          .attr('placeholder', 'Search ' + hr_field_label)
          .val(search_query[value] + ' ')
      } else {
        form_field
          .attr('name', value)
          .attr('placeholder', 'Search ' + hr_field_label)
          .val('')
      }

    }

}

$(document).ready(function() {

  // Sidebar Toggles
  $('.tree-toggler').on('click', function() {
      if ($(this).hasClass('just-minus')) {
          $(this).addClass('just-plus').removeClass('just-minus');
      } else if ($(this).hasClass('just-plus')) {
          $(this).addClass('just-minus').removeClass('just-plus');
      } else if ($(this).hasClass('plus')) {
          $(this).addClass('minus').removeClass('plus');
      } else {
          $(this).addClass('plus').removeClass('minus');
      }
      $(this).parent().children('ul.tree').toggle(300);
  });

  // Search Forms
  $('#ftypes').on('change', function() {

    var chosen = $('#ftypes option:selected')
    var value = chosen.val()
    var type = chosen.data('type').toLowerCase()
    var hr_field_label = chosen.data('labelname')

    renderSearchFields(value, type, hr_field_label)

    // Show Form
    $('#form-search-' + type)
      .removeClass('hide')
      .show()
  })

})
