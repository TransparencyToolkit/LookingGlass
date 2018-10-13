/* LookingGlass catalyst.js
 *
 * Transparency Toolkit, 2018
 * Author: Brennan Novak
 */

console.log('catalyst.js...')

var term_list_custom = "normalized_topics.json"
var term_list_country_names = "country_names.json"
var annotators = []

var renderAnnotators = function(annotators) {
    console.log(annotators)
    $elmAnnotators = $('#annotators')
    $(annotators).each(function(key, item) {

        var input_params = ''
        if (item.input_params.output_display_type) {
            input_params = '\
            <label>Display Type</label>\
            <select name="output_display_type">'
            for (param in item.input_params.output_display_type) {
                input_params += '<option value="' + item.input_params.output_display_type[param] + '">' + item.input_params.output_display_type[param] + '</option>'
            }
            input_params += '</select>'
        } else if (item.input_params.term_list) {
            input_params = '\
                <label>Terms List</label>\
                <button type="button" class="btn btn-sm">Add Terms</a>'
        } else if (item.input_params.number_of_keywords) {
            input_params = '\
            <label>Number of Keywords</label>\
            <select name="number_of_keywords">\
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

        var html = '\
            <div class="annotator text-center">\
                <div class="panel panel-default">\
                    <div class="panel-heading">\
                        <label class="annotator-choose">\
                            <input type="checkbox" name="' + item.classname + '"> ' + item.name + '\
                        </label>\
                    </div>\
                    <div class="panel-body">\
                        <div class="annotator-icon">\
                            <a class="annotator-icon-choose btn btn-small btn-link">\
                                <i class="icon-' + item.default_icon + '"></i>\
                                Choose Icon\
                            </a>\
                        </div>\
                        <fieldset>\
                            <label>Filter Name</label>\
                            <input type="text" name="name" value="' + item.default_human_readable_label + '">\
                        </fieldset>\
                        ' + input_params + '\
                    </div>\
                </div>\
            </div>'

        $elmAnnotators.append(html)
    })


    // Miners
    $('.annotator-choose').on('click', function(e) {
        e.stopPropagation()
        if ($(e.target).is('label')) {
            if (!$(e.target).find('input[type=checkbox]').prop('checked')) {
                $(e.target).parent().parent().removeClass('panel-default').addClass('panel-success')
            } else {
                $(e.target).parent().parent().removeClass('panel-success').addClass('panel-default')
            }
        } else if ($(e.target).is('input')) {
            if (!$(e.target).prop('checked')) {
                $(e.target).parent().parent().parent().removeClass('panel-success').addClass('panel-default')
            } else {
                $(e.target).parent().parent().parent().removeClass('panel-default').addClass('panel-success')
            }
        }
    })

    $('.annotator-icon-choose').on('click', function(e) {
        $('#modal-annotator-icon').modal('show')
    })

}


var runJob = function() {
    console.log('run catalyst job')

    var recipe = {}

    var annotators_to_run = ''


    $('.annotator-choose').each(function(key, item) {

        console.log($(item).val())

    })


    var job = {
        default_dataspec: $('select[name=dataspec]').val(),
        index: $('input[name=project_index]').val(),
        docs_to_process: {
            run_over: $('select[name=run_over]').val(),
            field_to_search: $('').val(),
            filter_query: $('input[name=filter_text]').val(),
            end_filter_range: $('input').val(),
        },
        input_params: annotators_to_run
    }


    var ajaxy = $.post( "/run_job", {
        job: job
    }, function() {
        $('#modal-running-job').modal('show')
    })
        .done(function(response) {
            console.log(response)
            $('#modal-save-changes').modal('hide')
        })
        .fail(function(err) {
            console.log(err)
            alert('Error: display error in modal');
        })
        .always(function() {
            alert('finished');
        })
}


$(document).ready(function() {

    $.getJSON("/api/annotators", function(response) {
        annotators = response
        renderAnnotators(response)
    })


    $('#select-dataspec').on('change', function(e) {
        console.log('select dataset: ' + $(this).val())
        $('select[name=field_to_search]').parent().addClass('hide')

        $('#document_type_' + $(this).val()).removeClass('hide')

    })

    $('#select-run-over').on('change', function(e) {
        console.log('select run_over: ' + $(this).val())
        if ($(this).val() == 'all') {
            $('#narrow-input-date').addClass('hide')
            $('#narrow-input-text').addClass('hide')
            $('#narrow-submit').addClass('hide')
        } else if ($(this).val() == 'within_date_range') {
            $('#narrow-input-date').removeClass('hide')
            $('#narrow-submit').removeClass('hide')
            $('#narrow-input-date').find('input').datetimepicker({
                format: 'YYYY-MM-DD'
            })
            $('#narrow-input-text').addClass('hide')
        } else if ($(this).val() == 'matching_query') {
            $('#narrow-input-text').removeClass('hide')
            $('#narrow-submit').removeClass('hide')
            $('#narrow-input-date').addClass('hide')
        }
    })

    $('#run-job').on('click', function(e) {
        runJob()
    })

    // Modals
    $('#modal-annotator-icon').on('show.bs.modal', function(e) {
        var button = $(e.relatedTarget)
        var modal = $(this)

    })

    $('#modal-annotator-icon').on('hide.bs.modal', function(e) {

    })

})
