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

