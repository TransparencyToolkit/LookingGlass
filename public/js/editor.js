/* editor.js
 *
 * Transparency Toolkit, 2018
 * Author: Brennan Novak
 */

var global_facets = {}
var editable_classes = 'unedited editing changed saving saved error'

var editable = {
    facet_groups: [],
    state: 'unedited',
    doc_id: '',
    doc_properties: ['document_type', 'data_source', 'collection_tag', 'selector_tag', 'version_changed'],
    items: {}
}

var selectized_items = {}

// Get Doc ID
var doc_url = document.createElement('a')
doc_url.href = window.location.href
var doc_id = doc_url.pathname.replace('/docs/', '')
editable.doc_id = doc_id
var base_url = doc_url.protocol + '//' + doc_url.host


var showEditableItems = function($elem) {

    $elem.addClass('hide')
    var original = $elem.html().trim()
    var parent = $elem.parent()
    var name = parent.attr('class')
    var editable_id = 'editable-' + parent.attr('class')

    // TODO: strip out span.efm-parent span.efm-hi classes from Highlighter
    if ($('#' + editable_id).length <= 0) {

        var form_field = ''
        // TODO: handle the case where fields are blank / have no data
        // make this show a 'empty' placeholder field when 'unedited' state
        // when user has Editor, when not show nothing
        // Determine item input type
        if ($elem.hasClass('list_title')) {
            form_field = '<input type="text" id="' + editable_id + '" data-name="' + name + '" class="editable-form-item form-control" value="' + original + '" placeholder="Item Title">'
            parent.append(form_field)

        } else if ($elem.hasClass('type-text') && original.length <= 120) {
            form_field = '<input type="text" id="editable-' + name +'" data-name="' + name + '" class="editable-form-item form-control" value="' + original + '">'
            parent.append(form_field)

        } else if ($elem.hasClass('type-text') && original.length >= 121) {
            form_field = '<textarea id="' + editable_id + '" data-name="' + name + '" class="editable-form-item form-control" rows="5">' + original + '</textarea>'
            parent.append(form_field)

        } else if ($elem.hasClass('long-text')) {
            form_field = '<textarea id="' + editable_id + '" data-name="' + name + '" class="editable-form-item form-control" rows="8">' + original + '</textarea>'
            parent.append(form_field)

        } else if ($elem.hasClass('list_date')) {
            form_field = '\
                <div class="form-group editable-form-item">\
                    <div class="input-group date" id="editable-' + name +'">\
                        <input type="text" data-name="' + name + '" class="form-control" value="' + original + '">\
                        <span class="input-group-addon">\
                            <span class="icon-calendar"></span> Picker\
                        </span>\
                    </div>\
                </div>'
            parent.append(form_field)
            $('#editable-date').datetimepicker({
                format: 'YYYY-MM-DD',
                icons: datetimepicker_icons
            })
        } else if ($elem.hasClass('list_datetime')) {
            // Make non unix so datetimepicker work with the value
            var converted = moment.unix(original).format('YYYY-MM-DD HH:MM')
            form_field = '\
                <div class="form-group editable-form-item">\
                    <div class="input-group date" id="editable-' + name +'">\
                        <input type="text" data-name="' + name + '" class="form-control" value="' + converted + '">\
                        <span class="input-group-addon">\
                            <span class="icon-clock"></span> Picker\
                        </span>\
                    </div>\
                </div>'
            parent.append(form_field)

            // TODO: this is not robust enough
            if (!editable.items.hasOwnProperty('datetime')) {
                editable.items['datetime'] = {
                    original: '1970-01-01 00:00',
                    edited: false
                }
            }

            $('#editable-datetime').datetimepicker({
                format: 'YYYY-MM-DD hh:mm',
                defaultDate: editable.items['datetime'].original,
                icons: datetimepicker_icons
            })
        } else if ($elem.hasClass('source-link') || $elem.hasClass('link')) {
            form_field = '<input type="url" id="' + editable_id + '" data-name="' + name + '" class="editable-form-item form-control" placeholder="http://website.com/link-to-source" value="' + original + '">'
            parent.append(form_field)
        } else {
            console.log('Error unknown data type')
            console.log($elem)
        }

        // Global state object
        editable.items[name] = {
            original: original,
            edited: false
        }
    } else {
        console.log('Editable field exists: ' + name)
    }
}

// Update UI
var updateEditableUI = function(state_class) {
    editable.state = state_class
    console.log('updateEditableUI ' + state_class)
    if (state_class == 'changed') {
        $('#button-editable-action').html('Save Changes')
        $('#button-editable-discard').removeClass('hide')
    } else {
        $('#button-editable-action').html('Start Editing')
        $('#button-editable-discard').addClass('hide')
    }
    $('#editable-bar').removeClass(editable_classes).addClass(state_class)
}

// Check all items
var allEditableStates = function() {
    var items_states = []
    var items = _.keys(editable.items)
    for (item of items) {
        items_states.push(editable.items[item].edited)
    }
    return items_states
}

var enableEditableActions = function() {

    $('.editable-form-item').on('input', function(event) {

        var item_name = event.currentTarget.dataset.name
        var item_text = event.currentTarget.value

        // Item is not changed
        if (item_text == editable.items[item_name].original) {
            //console.log('1.0 item is not changed')
            editable.items[item_name].edited = false
            $(event.currentTarget).removeClass('item-changed')

            // Check all items
            items_states = allEditableStates()
            if (items_states.indexOf(true) > -1) {
                //console.log('1.2 other fields are changed')
                updateEditableUI('changed')
            } else {
                //console.log('1.3 no other fields changed reverting from chan ged')
                updateEditableUI('unedited')
            }
        }
        else if (item_text != editable.items[item_name].original) {
            //console.log('2.0 this field is changed')
            updateEditableUI('changed')
            editable.items[item_name].edited = true
	        editable.items[item_name].changed = item_text
            $(event.currentTarget).addClass('item-changed')
        }
        else {
            //console.log('3.0 ugh oh, im confused')
            updateEditableUI('editing')
        }
    })

    $('#editable-date').on('dp.change', function(e){
        var new_date = $('#editable-date').data('date')
        if (new_date != editable.items['date'].original) {
            editable.items['date'].edited = true
	        editable.items['date'].changed = new_date
            updateEditableUI('changed')
        } else {
            console.log('Date is confused')
            updateEditableUI('editing')
        }
    })

    $('#editable-datetime').on('dp.change', function(e){
        var new_datetime = moment($('#editable-datetime').data('date')).unix()
        if (new_datetime != editable.items['datetime'].original) {
            editable.items['datetime'].edited = true
	        editable.items['datetime'].changed = new_datetime
            updateEditableUI('changed')
        } else {
            console.log('Datetime is confused')
            updateEditableUI('editing')
        }
    })
}

var stopEditingItems = function(new_state) {

    // Remove inputs & show original
    $('.editable-form-item').each(function() {
        $(this).remove()
    })
    $('.editable').each(function() {
        $(this).removeClass('hide')
    })

    // Update Editbar
    let action_text = 'Start Editing'
    if (new_state == 'saved') {
        action_text = 'Done Saving'
    }

    $('#button-editable-discard').addClass('hide')
    $('#button-editable-action').html(action_text)
    $('#editable-bar').removeClass(editable_classes).addClass(new_state)

    // Facets
    makeFacetsNormal()
}

var selectizeFacetGroup = function(group, facets) {

    // Hide HTML
    $($('.facet.' + group).find('p')[1]).hide()

    // Build Selectize
    var options = []
    var chosen = []
    var i = 0
    for (facet of facets.buckets) {
        options.push({
            id: i,
            title: facet.key
        })
        // Already in document
        if (editable.items[group].original.indexOf(facet.key) !== -1) {
            chosen.push(i)
        }
        i++
    }

    var updateSelectizedInput = function(group, state) {
        // console.log('updateSelectizedInput ' + group + ' ' + state)
        editable.items[group].edited = state
        if (state == true) {
           $('.facet.' + group).find('div.selectize-input').addClass('items-changed')
        } else {
           $('.facet.' + group).find('div.selectize-input').removeClass('items-changed')
        }
    }

    var checkDiff = function(original, current) {
        let result = false
        if (current.sort().join('-') === original.sort().join('-')) {
            result = true
        }

        return result
    }

    $selectize_group = $('#selectize-' + group)
    $selectize_group.removeClass('hide')
    var $selectized = $selectize_group.selectize({
        maxItems: null,
        create: true,
        persist: true,
        valueField: 'id',
        labelField: 'title',
        searchField: 'title',
        options: options,
        onItemAdd: function(id, item) {

            // Is new facet
            if (!Number.isInteger(id)) {
                global_facets[group].buckets.push({
                    key: facet,
                    doc_count: 0
                })

                id =  (global_facets[group].buckets.length - 1)
            }

            var id = parseInt(id)
            var facet = $(item).html()
            var current_facets = [facet]

            $('#selectize-' + group).children(':selected').each(function() {
                current_facets.push($(this).html())
            })

            // Not in original
            if (!editable.items[group].original.includes(facet)) {

                // Add to selectize instance
                chosen.push(id)

                // Update editable
                editable.items[group].changed = current_facets
                updateSelectizedInput(group, true)
                updateEditableUI('changed')

            // Was original, then removed, then re-added
            } else if (editable.items[group].original.includes(facet) && editable.items[group].edited) {

                // Add to selectize instance
                chosen.push(id)

                // Check if matches
                var diff = checkDiff(editable.items[group].original, current_facets)
                if (diff) {

                    // Update this item
                    editable.items[group].changed = []
                    updateSelectizedInput(group, false)

                    // Check all items (only change global if unedited)
                    items_states = allEditableStates()
                    if (items_states.indexOf(true) === -1) {
                        updateEditableUI('unedited')
                    }
                } else {
                    editable.items[group].changed = current_facets
                    updateSelectizedInput(group, true)
                }
            }
        },
        onItemRemove: function(id, item) {
            var facet = $(item).html()

            // Only delete existing facet
            if (editable.items[group].changed.length === 0) {
                var index = editable.items[group].original.indexOf(facet)
                var changed = editable.items[group].original.filter(e => e !== facet)
                editable.items[group].changed = changed
            } else {
                var index = editable.items[group].changed.indexOf(facet)
                editable.items[group].changed.splice(index, 1)
            }
            chosen.splice(index, 1)

            // Check if this facet is edited
            var diff = checkDiff(editable.items[group].original, editable.items[group].changed)
            if (diff) {

                editable.items[group].edited = false
                updateSelectizedInput(group, false)

                // Check all other fields
                var items_states = allEditableStates()
                if (items_states.indexOf(true) === -1) {
                    updateEditableUI('unedited')
                }  else if (items_states.indexOf(true) > -1) {
                    updateEditableUI('changed')
                }
            // Facets different
            } else {
                editable.items[group].edited = true
                updateSelectizedInput(group, true)
                updateEditableUI('changed')
            }
        }
    })

    // Add existing items
    selectized_items[group] = $selectized[0].selectize
    for (id of chosen) {
        selectized_items[group].addItem(id)
    }
}

var makeFacetsSelectized = function() {
    for (group of editable.facet_groups) {
        if (editable.doc_properties.indexOf(group) == -1) {
            selectizeFacetGroup(group, global_facets[group])
        }
    }
}

var makeFacetsNormal = function() {
    for (group of editable.facet_groups) {
        if (!editable.doc_properties.includes(group)) {
            selectized_items[group].destroy()
            $('#selectize-' + group).addClass('hide')
            $($('.facet.' + group).find('p')[1]).show()
        }
    }

    $('.selectize-control.multi').each(function() {
        $(this).remove()
    })
}

var updateChangedItems = function() {
    $('.editable').each(function() {
        let item = $(this).parent().attr('class')
        if (editable.items[item].edited) {
            var changed = editable.items[item].changed
            $(this).html(changed)
            editable.items[item] = {
                original: changed,
                changed: "",
                edited: false
            }
        }
    })

    $('.facet').each(function() {
        let item = $(this).attr('class').replace('facet ', '')
        if (editable.items[item].edited) {
            let facets = ""
            let comma = ", "
            let count = 0
            for (let x in editable.items[item].changed) {
                let facet = editable.items[item].changed[x]
                count++;
                if (count == editable.items[item].changed.length) {
                    comma = ""
                }
                facets += '<a href="/search?' + item + '_facet=' + facet + '">'
                facets += facet
                facets += '</a>' + comma
            }
            $('.facet.' + item).find('p:nth-last-child(2)').html(facets)
            editable.items[item] = {
                original: editable.items[item].changed,
                changed: "",
                edited: false
            }
        }
    })
}

var resetEditor = function() {
    editable.state = 'unedited'
    $('#editable-bar').removeClass(editable_classes).addClass('unedited')
    $('#button-editable-action').html('Start Editing')
}

var saveChanges = function() {
    var post_uri = '/edit_document'
    if (editable.doc_id == '/entities/create') {
        post_uri = '/entities/save'
        editable.doc_type = $('#class_name').val()
    }

    var ajaxy = $.post(post_uri, {
        edited: editable
    }, function() {
        editable.state = 'saved'
        stopEditingItems('saved')
    })
      .done(function(response) {
          console.log('Done saving edits')
          updateChangedItems()
          setTimeout(resetEditor, 1000)
      })
      .fail(function(err) {
          console.log('Error saving edits')
          console.log(err)
      })
}

var deleteDocument = function() {
    console.log('deleteDocument running...')

    

    var documents = []

    $.ajax({
        url: '/delete_documents',
        data: documents,
        type: 'DELETE'
    }).done(function(response) {

        console.log(response)
    })
}

$(document).ready(function() {

    $.getJSON("/api/facets", function(response) {
        global_facets = response
    })

    $('#sidebar-details').find('div.facet').each(function() {
        var facets = []
        var group = $(this).context.className.replace('facet ', '')
        var select = '<select class="hide" id="selectize-' + group + '" multiple></select>'
        $(this).append(select)
        $('.facet.' + group).find('a').each(function() {
            facets.push($(this).html())
        })

        editable.facet_groups.push(group)
        editable.items[group] = {
            original: facets,
            changed: [],
            edited: false
        }
    })

    $('#button-editable-action').on('click', function() {

        // Not editing
        if (editable.state == 'unedited') {

            // Hide Highlighter
            $('#efm-button').css('z-index', -10)

            // Instantiate facets & form fields
            makeFacetsSelectized()
            $('.editable').each(function() {
                showEditableItems($(this))
            })

            $(this).html('Stop Editing')
            editable.state = 'editing'
            $('#editable-bar').removeClass(editable_classes).addClass('editing')
        }
        // Editing but no changes
        else if (editable.state == 'editing') {
            editable.state = 'unedited'
            stopEditingItems('unedited')
            makeFacetsNormal()
        }
        // Has changes, now save
        else if (editable.state == 'changed') {
            $(this).html('Saving Edits')
            editable.state = 'saving'
            $('#editable-cancel').addClass('hide')
            $('#editable-bar').removeClass(editable_classes).addClass('saving')
            saveChanges()
        }
        else if (editable.state == 'saved') {
            console.log('Here in saved state')
        }
        else {
            console.log('Unknown editor state')
        }

        enableEditableActions()
    })

    $('#button-editable-discard').on('click', function() {
        if (editable.state == 'editing') {
            editable.state = 'unedited'
            stopEditingItems('unedited')
        }
        else if (editable.state == 'changed') {
            editable.state = 'unedited'
            stopEditingItems('unedited')
            $(this).addClass('hide')
        }

        makeFacetsNormal()
    })

    $('#button-delete-doc').on('click', function() {
        deleteDocument()
    })

    // Modals
    $('#modal-add-link').on('show.bs.modal', function(e) {
        var button = $(e.relatedTarget)
        var modal = $(this)
        var link_type = e.relatedTarget.dataset.type
        $('#efm-button').css('z-index', 10)
        $('#form-associated-doc').hide()
        $('#form-named-link').hide()
        $('#form-related-link').hide()

        if (link_type == 'associated-doc') {
            $('#form-associated-doc').show()
            $('#modalAddLinkLabel').html('Link Associated Document')
            $('#documentUrl').attr({
                'placeholder': base_url + '/docs/Some_Related_document',
                'name': 'associated_document'
            })
            $('#buttonAddLink').html('Link Document')

        } else if (link_type == 'named-link') {
            $('#form-named-link').show()
            $('#modalAddLinkLabel').html(e.relatedTarget.innerText)
            $('#buttonAddLink').html('Add URL')

        } else if (link_type == 'related-link') {
            $('#form-related-link').show()
            $('#modalAddLinkLabel').html('Add Related URL')
            $('#buttonAddLink').html('Add URL')
        }
    })

    $('#modal-add-link').on('hide.bs.modal', function(e) {
        $('#efm-button').css('z-index', 9999999999)
    })

})
