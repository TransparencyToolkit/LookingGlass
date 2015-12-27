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
      var selected_parts = value.split('_sindex_')
      var this_spec = _.findWhere(dataspec, { 'index_name': selected_parts[1] })
      var item = _.findWhere(this_spec.field_info_sorted, { 'Field Name' : selected_parts[0]});
    }

    // Modify Fields
    if (type === 'date') {

      $('#search-date-start')
        .attr('name', 'startrange_' + value)
      $('#search-date-end')
        .attr('name', 'endrange_' + value)

    }
    else if (type === 'string') {

      $('#form-search-' + type)
        .find('input[type=text]')
        .attr('name', value)
        .attr('placeholder', 'Search ' + item['Human Readable Name'])

      // Style & Fill Form Field
      var form_field = $('#form-search-' + type).find('input[type=text]')

      if (search_query[value] !== undefined) {
        form_field
          .attr('name', value)
          .attr('placeholder', 'Search ' + item['Human Readable Name'])
          .val(search_query[value] + ' ')
      } else {
        form_field
          .attr('name', value)
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

    if ($('#' + new_tab_id).length == 0) {
      $('#maincontent').find('.nav-pills').append('<li id="li' + new_tab_id + '">\
        <a href="#' + new_tab_id + '" data-toggle="tab"> Article #' + $(this).data('index') + '</a>\
      </li>');

      $('#maincontent').find('.tab-content').append('<div class="tab-pane" id="' + new_tab_id + '">\
        <iframe class="show-iframe" src="' + $(this).attr('href') + '" width="100%" height="700" sandbox="allow-same-origin"></iframe>\
      </div>');
    }

    $('#li' + new_tab_id + ' a[href="#' + new_tab_id + '"]').tab('show');

  });


  // Diffing
  var dmp = new diff_match_patch();

  var doDiffing = function(element, text1, text2) {

    dmp.Diff_Timeout = 4;
    dmp.Diff_EditCost = 4;

    var ms_start = (new Date()).getTime()
    var d = dmp.diff_main(text1, text2)
    var ms_end = (new Date()).getTime()

    if (document.getElementById('semantic').checked) {
      dmp.diff_cleanupSemantic(d);
    }
    if (document.getElementById('efficiency').checked) {
      dmp.diff_cleanupEfficiency(d);
    }

    var ds = dmp.diff_prettyHtml(d);

    $('#versions-diff').append('<' + element + '>' + ds + '</' + element + '>');
    //console.log('Diffing Processing Time: ' + (ms_end - ms_start) / 1000 + 's')
  }

  // Perform Diff
  $('#versions-compute').on('click', function(e) {

    e.preventDefault()
    $('#versions-diff').html('')

    // Get All Versions
    var versions = $('#versions-container').find('.version')

    // Move elements to matching pairs
    // Instead of [h3, p] and [h3, p] we have [h3, h3] and [p, p]
    var element_pairs = _.zip( $(versions[0]).children(), $(versions[1]).children() )
    //console.log(element_pairs)

    // Diff Element Pairs
    _.each(element_pairs, function(element, key) {

      // Need for reconstructing
      var element_type = $(element).prop('tagName')

      //console.log('doing element key: ' + key + ' type: ' + element_type)
      //console.log(element)
      doDiffing(element_type, $(element[0]).html(), $(element[1]).html() )
    })
  })

})
