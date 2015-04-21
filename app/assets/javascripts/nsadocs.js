$(document).ready(function() {

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
    }

    // Show Form
    $('#form-search-' + type)
      .removeClass('hide')
      .show();
  });

});