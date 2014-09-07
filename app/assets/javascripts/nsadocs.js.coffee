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
    else if chosen == "Creation Date"
      $('.searchin').hide()
      $('#creation_date').show()
    else if chosen == "Document Type"
      $('.searchin').hide()
      $('#type').show()
    else if chosen == "Records Collected"
      $('.searchin').hide()
      $('#records_collected').show()
    else if chosen == "Legal Authority"
      $('.searchin').hide()
      $('#legal_authority').show()
    else if chosen == "Countries"
      $('.searchin').hide()
      $('#countries').show()
    else if chosen == "SIGADS"
      $('.searchin').hide()
      $('#sigads').show()
    else if chosen == "Release Date"
      $('.searchin').hide()
      $('#release_date').show()
    else if chosen == "Released By"
      $('.searchin').hide()
      $('#released_by').show()

