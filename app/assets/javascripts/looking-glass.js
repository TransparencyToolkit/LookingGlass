$(document).ready(function() {

  // Topbar Forms
  $('[data-behaviour~=datepicker]').datepicker();

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

      var chosen = $('#ftypes option:selected');
      var value = chosen.val();
      var type = chosen.data('type').toLowerCase();
      var hr_field_label = chosen.data('labelname');

      // Hide Forms
      $('#form-search-all').hide();
      $('#form-search-string').hide();
      $('#form-search-date').hide();
      $('#form-search-datetime').hide();

    // Modify Fields
    if (type === 'date' || type === 'datetime') {
	    $('#search-date-start').attr('name', 'startrange_' + value)
	    $('#search-date-end').attr('name', 'endrange_' + value)
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

  var doDiffing = function(doc_id, diffing, name, item) {

    dmp.Diff_Timeout = 4
    dmp.Diff_EditCost = 4

    var ms_start = (new Date()).getTime()
    var d = dmp.diff_main(item.versions.oldest, item.versions.newest)
    var ms_end = (new Date()).getTime()

    if (diffing == 'Sequentially') {
      dmp.diff_cleanupSemantic(d)
    }
    else if (diffing == 'Mixed') {
      dmp.diff_cleanupEfficiency(d)
    }

    var ds = dmp.diff_prettyHtml(d)

    $('#versions-diff-data-' + doc_id)
      .append('<' + item.element_type + ' class="diffed-' + name + '">' + item.label + ds + '</' + item.element_type + '>')
    //console.log('Diffing Processing Time: ' + (ms_end - ms_start) / 1000 + 's')
    return true
  }

  var doDiffingHTML = function(doc_id, diffing, name, item) {
    $('#versions-diff-data-' + doc_id)
      .append('<' + item.element_type + ' class="diffed-' + name + '">' + item.label + item.versions.oldest + '</' +
     item.element_type + '>')
  }

  var doNonDiffing = function(doc_id, diffing, name, item) {

    if (item.versions.oldest === undefined && item.versions.newest !== undefined) {
      //console.log(name + ' MISSING ' + item.versions.newest)
      $('#versions-diff-data-' + doc_id)
        .append('<' + item.element_type + ' class="diffed-' + name + '">' + item.label + item.versions.newest + ' <ins style="background:#e6ffe6;"> (shown in newest)</ins></' + item.element_type + '>')
    } else if (item.versions.newest === undefined && item.versions.oldest !== undefined) {
      //console.log(name + ' MISSING ' + item.versions.oldest)
      $('#versions-diff-data-' + doc_id)
        .append('<' + item.element_type + ' class="diffed-' + name + '">' + item.label + item.versions.oldest + ' <ins style="background:#ffe6e6;"> (shown in oldest)</ins></' + item.element_type + '>')
    }

    return true
  }

  var extractDiffingItem = function(element_pairs, version, item) {

    var name = $(item).attr('class')
    var type = $(item).prop('tagName')

    // Filter non-content elements
    if (_.indexOf(['SMALL', 'HR'], type) == -1) {

      var text_all = $(item).html()
      var label = ''

      if ($(item).find('.label').prop('outerHTML') !== undefined) {
        label = $(item).find('.label').prop('outerHTML')
      }

      var text_trim = text_all.replace(label, '')

      // Does item exist
      if (element_pairs[name] === undefined) {
        element_pairs[name] = {
          'element_type': type,
          'label': label,
          'versions': {}
        }

        element_pairs[name].versions[version] = text_trim

      } else if (element_pairs[name]) {
        //console.log(name + ' exists')
        element_pairs[name].versions[version] = text_trim
      }
    } else {
      // Use to debug unusual elements
      // console.log(name + ' | SKIPPED')
    }

    return element_pairs
  }

  var getDiffingData = function(doc_id, diffing) {

    // Reset Diff View
    $('#versions-diff-data-' + doc_id).html('')

    // Get Data
    var version_oldest = $('#version-oldest-' + doc_id).children()
    var version_newest = $('#version-newest-' + doc_id).children()
    var element_pairs = {}

    // Do Oldest version
    _.each(version_oldest, function(item, key) {
      element_pairs = extractDiffingItem(element_pairs, 'oldest', item)
    })

    // Then Newest version
    _.each(version_newest, function(item, key) {
      element_pairs = extractDiffingItem(element_pairs, 'newest', item)
    })

    // Render
    // to debug results
    // console.log(element_pairs)
    _.each(element_pairs, function(item, name) {
      if (item.versions.oldest !== undefined && item.versions.newest !== undefined) {
        if (/<[a-z][\s\S]*>/i.test(item.versions.oldest)) {
          doDiffingHTML(doc_id, diffing, name, item)
        } else if (/<[a-z][\s\S]*>/i.test(item.versions.newest)) {
          $('#versions-diff-data-' + doc_id)
            .append('<' + item.element_type + ' class="diffed-' + name + '">' + item.label + item.versions.oldest + '</' + item.element_type + '>');
        } else {
          doDiffing(doc_id, diffing, name, item)
        }
      } else {
        doNonDiffing(doc_id, diffing, name, item)
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
      .html('Data Differences: ' + $(this).data('diffing'))

    var position_offset = ($('#versions-diff-' + $(this).data('doc_id')).offset().top - 60)

    $('html, body').animate({ scrollTop: position_offset + 'px' }, 'fast')

  })

})
