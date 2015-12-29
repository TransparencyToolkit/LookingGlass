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

  var doDiffing = function(doc_id, diffing, element, label, text1, text2) {

    dmp.Diff_Timeout = 4;
    dmp.Diff_EditCost = 4;

    var ms_start = (new Date()).getTime()
    var d = dmp.diff_main(text1, text2)
    var ms_end = (new Date()).getTime()

    if (diffing == 'Sequential') {
      dmp.diff_cleanupSemantic(d);
    }
    else if (diffing == 'Mixed') {
      dmp.diff_cleanupEfficiency(d);
    }

    var ds = dmp.diff_prettyHtml(d);

    $('#versions-diff-data-' + doc_id).append('<' + element + '>' + label + ds + '</' + element + '>');
    //console.log('Diffing Processing Time: ' + (ms_end - ms_start) / 1000 + 's')
  }

  var getDiffingData = function(doc_id, diffing) {

    // Reset Diff View
    $('#versions-diff-data-' + doc_id).html('')

    // Get Data
    var version_oldest = $('#version-oldest-' + doc_id).children()
    var version_newest = $('#version-newest-' + doc_id).children()

    // Move elements to matching pairs
    // Makes [h3, p] and [h3, p] we have [h3, h3] and [p, p]
    var element_pairs = _.zip(version_oldest, version_newest)

    // Diff Pairs
    _.each(element_pairs, function(element, key) {

      // Need for reconstructing
      var element_type = $(element).prop('tagName')

      // Filter non-content elements
      if (_.indexOf(['SMALL', 'HR'], element_type) == -1) {

        // Cache original element
        var label = ''
        if ($(element[0]).find('.label').prop('outerHTML') !== undefined) {
          label = $(element[0]).find('.label').prop('outerHTML')
        }

        var element_one = $(element[0]).html().replace(label, '')
        var element_two = $(element[1]).html().replace(label, '')

        // Process
        if (/<[a-z][\s\S]*>/i.test(element_one) && /<[a-z][\s\S]*>/i.test(element_two)) {
          //console.log('Element is HTML so cannot diff')
          $('#versions-diff-data-' + doc_id).append('<' + element_type + '>' + label + element_two + '</' + element_type + '>');
        } else if (element_one != '' && element_two != '') {
          doDiffing(doc_id, diffing, element_type, label, element_one, element_two)
        } else {
          $('#versions-diff-data-' + doc_id).append('<p>' + label + ' <em>oops, error or no data compare</em></p>')
        }
      }
    })
  }

  // Perform Diff
  $('.versions-compute').on('click', function(e) {
    e.preventDefault()
    getDiffingData($(this).data('doc_id'), $(this).data('diffing'))

    $('#versions-diff-' + $(this).data('doc_id'))
      .removeClass('invisible')
      .find('h3.panel-title')
      .html($(this).data('diffing') + ' Data Differences')
  })

})
