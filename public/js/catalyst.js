/* LookingGlass catalyst.js
 *
 * Transparency Toolkit, 2018
 * Author: Brennan Novak
 */

var doc_url = document.createElement('a')
doc_url.href = window.location.href
var base_url = doc_url.protocol + '//' + doc_url.host + relative_url_root

var term_list_custom = "normalized_topics.json"
var term_list_country_names = "country_names.json"
var annotators = []

var showCatalystAlerts = function() {

    if (!localStorage["alert-catalyst-builder"]) {
        $('#alert-catalyst-builder').removeClass('hide')
    }

}

var resetBuilder = function() {
    $('input[name=filter_name]').val('')
    $('select[name=run_over]').val('')
    $('input[name=filter_text]').val('')
    $('input[name=filter_query]').val('')
    $('input[name=end_filter_range]').val('')
    $('#narrow-input-date').addClass('hide')
    $('#narrow-input-text').addClass('hide')
    $('#narrow-selects-field').addClass('hide')
    $('#narrow-submit').find('label').removeClass('invisible').addClass('hide')
    $('#narrow-search').find('h3').html('')
    $('#narrow-search').find('p').html('')
    $('#narrow-search').addClass('hide')
    $('#narrow-result').addClass('hide')
    $('#step-2').addClass('hide')
    $('#annotator-items').html('')
    $('#step-3').addClass('hide')
    $('#annotator-configs').html('')
}

var renderAnnotatorItems = function(annotators) {
    $elmAnnotators = $('#annotator-items')
    $(annotators).each(function(key, item) {
        var html = '\
            <div class="annotator-item default" title="' + item.description + '">\
                <label class="annotator-choose">\
                    <i class="icon-' + item.default_icon + '"></i>\
                    ' + item.name + '\
                    <input type="checkbox" class="" name="' + item.classname + '">\
                </label>\
            </div>'

        $elmAnnotators.append(html)
    })

    $('.annotator-choose').on('click', function(e) {
        if ($(e.target).is('label')) {
            if (!$(e.target).find('input[type=checkbox]').prop('checked')) {
                $(e.target).parent().removeClass('default').addClass('selected')
            } else {
                $(e.target).parent().removeClass('selected').addClass('default')
            }
        } else if ($(e.target).is('input')) {
            if (!$(e.target).prop('checked')) {
                $(e.target).parent().parent().removeClass('selected').addClass('default')
            } else {
                $(e.target).parent().parent().removeClass('default').addClass('selected')
            }
        }
    })
}

var renderAnnotatorConfigs = function() {
    // Update Step 2
    $('#step-2').find('h3').html('Miners Selected')
    $('#step-2').find('p').addClass('hide')
    $('.annotator-item.default').addClass('hide')
    $('#select-miners').addClass('hide')

    // Render Step3
    $('.annotator-item.selected').each(function(item, key) {
        var annotator_name = $(key).find('input').attr('name')
        for (item in annotators) {
            if (annotators[item].classname == annotator_name) {
                annotator = annotators[item]
                break;
            }
        }

        var annotator_id = 'annotator-config-' + annotator_name
        var params_id = 'annotator-params-' + annotator_name
        var fields_id = 'annotator-fields-' + annotator_name
        var html_fields = $('#template-' + $('#select-dataspec').val()).html()
        var html_template = $('#template-annotator-config').html()
        var html = html_template.replace(new RegExp('{{AID}}', 'g'), annotator_name)

        $('#annotator-configs').append(html)
        $('#' + annotator_id).find('h4').html(annotator.name)
        $('#' + annotator_id).find('i').addClass('icon-' + annotator.default_icon)
        $('#' + annotator_id).find('input[name=filter_icon]').val(annotator.default_icon)
        $('#' + annotator_id).find('input[name=filter_name]').val(annotator.default_human_readable_label)
        $('#' + fields_id).html(html_fields)

        var input_params = ''
        if (annotator.input_params.output_display_type) {
            input_params = '\
            <label>Display Type</label>\
            <select name="input_params[]output_display_type" class="form-control">'
            for (param in annotator.input_params.output_display_type) {
                input_params += '<option value="' + annotator.input_params.output_display_type[param] + '">' + annotator.input_params.output_display_type[param] + '</option>'
            }
            input_params += '</select>'
        } else if (annotator.input_params.term_list) {
            input_params = '\
                <label>Terms List</label>\
                <button type="button" class="annotator-terms-select btn btn-info btn-block">\
                    Select Terms\
                </button>\
                <label>Case Sensitive</label>\
                <select name="input_params[]case_sensitive" class="form-control">\
                    <option value="false">No</option>\
                    <option value="true">Yes</option>\
                </select>\
                <input type="hidden" name="input_params[]term_list">'
        } else if (annotator.input_params.number_of_keywords) {
            input_params = '\
            <label>Number of Keywords</label>\
            <select name="input_params[]number_of_keywords" class="form-control">\
                <option value="1">One</option>\
                <option value="2">Two</option>\
                <option value="3">Three</option>\
                <option value="4">Four</option>\
                <option value="5">Five</option>\
                <option value="6">Six</option>\
                <option value="7">Seven</option>\
                <option value="8">Eight</option>\
                <option value="9">Nine</option>\
                <option value="10">Ten</option>\
            </select>'
        }

        $('#' + params_id).html(input_params)
    })

    $('#step-3').removeClass('hide')

    // Events
    $('.annotator-terms-select').on('click', function(e) {
        $('#modal-annotator-terms').modal('show')
    })
    $('.annotator-icon-choose').on('click', function(e) {
        $('#modal-annotator-icon').modal('show')
    })
}

var dataGetRecipe = function() {
    var dataspec = $('select[name=default_dataspec]').val()
    var run_over = $('select[name=run_over]').val()
    var filter_query = ''
    var end_filter_range = ''
    var field_type = ''
    if (run_over == 'within_range') {
        filter_query = $('input[name=filter_query]').val()
        end_filter_range = $('input[name=end_filter_range]').val()
        field_type = 'date-' + dataspec
    } else if (run_over == 'matching_query') {
        filter_query = $('input[name=filter_text]').val()
        end_filter_range = ''
        field_type = 'text-' + dataspec
    }
    var field_to_search = $('#field-search-' + field_type).find('select[name=field_to_search]').val()

    return {
        filter_name: $('input[name=filter_name]').val(),
        default_dataspec: dataspec,
        run_over: run_over,
        filter_query: filter_query,
        end_filter_range: end_filter_range,
        field_to_search: field_to_search
    }
}

var recipeSearch = function() {
    var recipe = dataGetRecipe()
    var ajaxy = $.post('/api/recipe_search', {
        recipe: recipe
    }, function() {
        console.log('Sending recipe_search')
    })
        .done(function(response) {
           $('#narrow-result').find('h3').html('Documents Found')
           $('#narrow-result').find('p').html(response.message)
           $('#narrow-result').removeClass('hide')
        })
        .fail(function(err) {
            $('#modal-error').modal('show')
            $('#modal-error').find('p').html(err)
        })
        .always(function() {
            $('#step-2').removeClass('hide')
        })
}


var createJob = function() {
    var recipe = dataGetRecipe()
    var annotator_configs = []

    $('.annotator-config').each(function(item, key) {
        annotator_configs.push($(this).serializeArray())
    })

    var job = {
        recipe: recipe,
        annotators: annotator_configs
    }

    var ajaxy = $.post(base_url + 'api/create_job', {
        job: JSON.stringify(job)
    }, function() {
        console.log('Sending create_job')
    })
        .done(function(response) {
            $('#modal-running-job').modal('show')
        })
        .fail(function(err) {
            $('#modal-error').modal('show')
            $('#modal-error').find('p').html(err)
        })
        .always(function() {
            resetBuilder()
        })
}


$(document).ready(function() {

    showCatalystAlerts()

    $.getJSON(base_url + 'api/annotators', function(response) {
        annotators = response
        renderAnnotatorItems(response)
    })

    $('#select-dataspec').on('change', function(e) {
        var dataspec = $(this).val()
        var run_over = $('#select-run-over').val()
        $('select[name=field_to_search]').parent().addClass('hide')
        $('#document_type_' + dataspec).removeClass('hide')
        if (run_over == 'all') {
            $('#narrow-selects-field').addClass('hide')
            $('#narrow-submit').find('label').removeClass('invisible').addClass('hide')
        } else if (run_over == 'within_range') {
            $('#narrow-selects-field').removeClass('hide')
            $('#field-search-date-' + dataspec).removeClass('hide')
            $('#narrow-submit').find('label').removeClass('hide').addClass('invisible')
        } else if (run_over == 'matching_query') {
            $('#narrow-selects-field').removeClass('hide')
            $('#field-search-text-' + dataspec).removeClass('hide')
            $('#narrow-submit').find('label').removeClass('hide').addClass('invisible')
        }
    })

    $('#select-run-over').on('change', function(e) {
        var dataspec = $('#select-dataspec').val()
        var run_over = $(this).val()
        $('#narrow-selects-field').find('div').addClass('hide')
        if (run_over == 'all') {
            $('#narrow-input-date').addClass('hide')
            $('#narrow-input-text').addClass('hide')
            $('#narrow-selects-field').addClass('hide')
            $('#narrow-submit').find('label').removeClass('invisible').addClass('hide')
        } else if (run_over == 'within_range') {
            $('#narrow-input-date').removeClass('hide')
            $('#narrow-input-date').find('input').datetimepicker({
                format: 'YYYY-MM-DD'
            })
            $('#narrow-input-text').addClass('hide')
            $('#narrow-selects-field').removeClass('hide')
            $('#field-search-date-' + dataspec).removeClass('hide')
            $('#narrow-submit').find('label').removeClass('hide').addClass('invisible')
        } else if (run_over == 'matching_query') {
            $('#narrow-input-text').removeClass('hide')
            $('#narrow-input-date').addClass('hide')
            $('#narrow-selects-field').removeClass('hide')
            $('#field-search-text-' + dataspec).removeClass('hide')
            $('#narrow-submit').find('label').removeClass('hide').addClass('invisible')
        }
    })

    $('#submit-narrow').on('click', function(e) {
        e.preventDefault()
        recipeSearch()
    })

    $('#select-miners').on('click', function(e) {
        e.preventDefault()
        renderAnnotatorConfigs()
    })

    $('#cancel-job').on('click', function(e) {
        e.preventDefault()
        resetBuilder()
    })

    $('#run-job').on('click', function(e) {
        e.preventDefault()
        createJob()
    })

    // Modals
    $('#modal-annotator-icon').on('show.bs.modal', function(e) {
        var button = $(e.relatedTarget)
        var modal = $(this)
    })

    $('#modal-annotator-icon').on('hide.bs.modal', function(e) {

    })

})
