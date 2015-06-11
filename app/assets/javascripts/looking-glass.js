$(document).ready(function() {

  // Search Forms
  $('#ftypes').on('change', function() {

    var chosen = $('#ftypes option:selected');
    var value = chosen.val();
    var type = chosen.data('type').toLowerCase();

    // Hide Forms
    $('#form-search-all').hide();
    $('#form-search-string').hide();
    $('#form-search-date').hide();

    // Get Item
    if (type !== 'all') {
      var item = _.findWhere(dataspec, { 'Field Name' : value});
    }

    // Modify Fields
    if (type === 'date') {
      $('#search-date-start')
        .attr('name', item['Form Params'][0])
      $('#search-date-end')
        .attr('name', item['Form Params'][1])
    } else if (type === 'string') {
      $('#form-search-' + type)
        .find('input[type=text]')
        .attr('name', item['Form Params'])
        .attr('placeholder', 'Search ' + item['Human Readable Name'])

      // Style & Fill Form Field
      var form_field = $('#form-search-' + type).find('input[type=text]')

      if (search_query[value] !== undefined) {
        form_field
          .attr('name', item['Form Params'])
          .attr('placeholder', 'Search ' + item['Human Readable Name'])
          .val(search_query[value] + ' ')
      } else {
        form_field
          .attr('name', item['Form Params'])
          .attr('placeholder', 'Search ' + item['Human Readable Name'])
          .val('')
      }
    }

    // Show Form
    $('#form-search-' + type)
      .removeClass('hide')
      .show();
  });


  // Show Article in Tab
  $('.show-article-tab').on('click', function(e) {

    e.preventDefault();

    $(this).attr('href');
    $(this).data('index');
    var new_tab_id = 'article-' + $(this).data('index');

    $('#maincontent').find('.nav-pills').append('<li id="li' + new_tab_id + '">\
      <a href="#' + new_tab_id + '" data-toggle="tab"> Article #' + $(this).data('index') + '</a>\
    </li>');

    $('#maincontent').find('.tab-content').append('<div class="tab-pane" id="' + new_tab_id + '">\
      <iframe class="show-iframe" src="' + $(this).attr('href') + '" width="100%" height="700" sandbox="allow-same-origin"></iframe>\
    </div>');

    $('#li' + new_tab_id + ' a[href="#' + new_tab_id + '"]').tab('show');
  });


});
