/* LookingGlass editor.js
 *
 * Transparency Toolkit, 2018
 * Author: Brennan Novak
 */

var editable_classes = 'unedited editing changed saving saved error'

var editable = {
    facets: {},
    state: 'unedited',
    doc_id: '',
    items: {}
}

// Get Doc ID
var doc_url = document.createElement('a')
doc_url.href = window.location.href
var doc_id = doc_url.pathname.replace('/docs/', '')
editable.doc_id = doc_id


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
            form_field = '<input type="text" id="' + editable_id + '" data-name="' + name + '" class="editable-form-item form-control" value="' + original + '">'
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

        } else if ($elem.hasClass('source-link')) {
            form_field = '<input type="url" id="' + editable_id + '" data-name="' + name + '" class="editable-form-item form-control" placeholder="http://example.com/link-to-source" value="' + original + '">'
            parent.append(form_field)
        } else {
            console.log('Error unknown data type')
        }

        // Global state object
        editable.items[name] = {
            content: original,
            edited: false
        }
    } else {
        console.log('Editable field exists: ' + name)
    }
}

var enableEditableActions = function() {

    $('.editable-form-item').on('input', function(event) {

        var item_name = event.currentTarget.dataset.name
        var item_text = event.currentTarget.value

        // Update UI
        var updateEditableUI = function(item_name, state_class) {
            editable.state = state_class

            if (state_class == 'changed') {
                $('#button-editable-discard').removeClass('hide')
            } else {
                $('#button-editable-discard').addClass('hide')
                $('#button-editable-action').html('Start Editing')
            }
            $('#editable-bar').removeClass(editable_classes).addClass(state_class)
        }

        // Check other items
        var checkAllEdited = function() {

            console.log('inside checkAllEdited')
            var items_states = []

            $('.editable-form-item').each(function(key, val) {
                var check_item = $(val).data('name')
                items_states.push(editable.items[check_item].edited)
            })

            console.log(items_states)
            return items_states
        }

        // Item is not changed
        if (item_text == editable.items[item_name].content) {
            console.log('1.0 item is not changed')
            editable.items[item_name].edited = false
            $(event.currentTarget).removeClass('item-changed')

            // Other items are changed
            items_states = checkAllEdited()
            if (items_states.indexOf(true) > -1) {
                console.log('1.2 other fields are changed')
                updateEditableUI(item_name, 'changed')
            } else {
                console.log('1.3 no other fields changed reverting from chan ged')
                updateEditableUI(item_name, 'unedited')
            }

        }
        else if (item_text != editable.items[item_name].content) {
            console.log('2.0 this field is changed')
            updateEditableUI(item_name, 'changed')
            editable.items[item_name].edited = true
	    editable.items[item_name].changed_content = item_text

            $(event.currentTarget).addClass('item-changed')
            console.log(event.currentTarget)
        }
        else {
            console.log('3.0 ugh oh, im confused')
            updateEditableUI(item_name, false, 'editing')
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
}


var buildFacetAdd = function(modal) {

    $facet_type_list = $('#facet-type-list')

    $('#sidebar-details').find('div.facet').each(function() {
        var facet_type = $(this).find('strong.label').html()
        editable.facets[facet_type] = []

        var html_option = '<option value="' + facet_type + '">' + facet_type  + '</option>'
        $facet_type_list.append(html_option)

        var facet_items = $(this).find('a')
        facet_items.each(function() {
            var item = $(this).html()
            editable.facets[facet_type].push(item)

        })
    })
}

$(document).ready(function() {

    $('#button-editable-action').on('click', function() {

        // Not editing
        if (editable.state == 'unedited') {
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
        }
        // Has changes, saved
        else if (editable.state == 'changed') {

            $(this).html('Saving Edits ...')
            editable.state = 'saving'
            $('#editable-cancel').addClass('hide')
            $('#editable-bar').removeClass(editable_classes).addClass('saving')

            alert('Submitting changes to API')
	    $.post( "/edit_document", { edited: editable} );
	    
            editable.state = 'saved'
            stopEditingItems('saved')
        }
        else if (editable.state == 'saved') {

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
    })

    $('#facet-add-modal').on('show.bs.modal', function(eve) {

        // Hide Highligther button
        $('#efm-button').css('z-index', 10)

        // Button that triggered the modal
        var button = $(eve.relatedTarget)

        // Extract info from data-* attributes
        var recipient = button.data('whatever')

        // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
        // Update the modal's content. We'll use jQuery here, but you could use
        // a data binding library or other methods instead.
        var modal = $(this)
        //modal.find('.modal-body input').val(recipient)

        buildFacetAdd(modal)
    })

    $('#facet-add-modal').on('hide.bs.modal', function(eve) {
        $('#efm-button').css('z-index', 9999999999)
    })


    $('#modal-add-link').on('show.bs.modal', function(eve) {

        // Hide Highligther button
        $('#efm-button').css('z-index', 10)

        $('#modalAddLinkLabel').html('Add Link to This Document')
        $('#inputLinkUrlLabel').html('URL Links to Document')
        $('#inputLinkUrl').val()
        $('#buttonAddLink').html('Add Link')

        var button = $(eve.relatedTarget)
        var recipient = button.data('whatever')

        var modal = $(this)
    })
})
