# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $("#docs").dataTable dom: 'C<"clear">Rlfrtip', bFilter: false, columnDefs: [
    {
      targets: [4..12]
      visible: false
    }
  ]
  return

jQuery ->
  $('#ftypes').change ->
    chosen = $('#ftypes :selected').text()
    if chosen == "Title"
      $('.searchin').hide()
      $('#title').show()
    else if chosen == "All"
      $('.searchin').hide()
      $('#q').show()
    else if chosen == "Description"
      $('.searchin').hide()
      $('#aclu_desc').show()
    else if chosen == "Document"
      $('.searchin').hide()
      $('#doc_text').show()
    else if chosen == "Programs"
      $('.searchin').hide()
      $('#programs').show()
    else if chosen == "Codewords"
      $('.searchin').hide()
      $('#codewords').show()
