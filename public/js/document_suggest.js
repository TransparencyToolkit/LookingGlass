// CAPTCHA
function gen_captcha() {
  var num1 = (Math.ceil(Math.random() * 10)-1).toString()
  var num2 = (Math.ceil(Math.random() * 10)-1).toString()
  var num3 = (Math.ceil(Math.random() * 10)-1).toString()
  var num4 = (Math.ceil(Math.random() * 10)-1).toString()
  var num5 = (Math.ceil(Math.random() * 10)-1).toString()
  var num6 = (Math.ceil(Math.random() * 10)-1).toString()
  var new_code = (num1 + num2 + num3 + num4 + num5 + num6)
  $('#captcha_code').html(new_code)
}


// jQuery redirect plugin
$.extend({
	redirectPost: function(url, args) {
		var form = $('<form></form>')
		form.attr("method", "post")
		form.attr("action", url)
		$.each(args, function(key, value) {
			var field = $('<input></input>')
			field.attr("type", "hidden")
			field.attr("name", key)
			field.attr("value", value)
			form.append(field)
		})
		$(form).appendTo('body').submit()
	}
})


$(function() {

	gen_captcha()
	$('#url').val('')
	$('#title').val('')
	$('#keywords').val('')
	$('#email_pgp').val('')
	$('#captcha').val('')

	$('#document-suggest-form').submit(function(e) {

		e.preventDefault()
		var color_valid = "#62C947"
		var color_invalid = "#C61C1C"

		// Validate URL
		var url_text = $("#url").val()
		var url_valid = /(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z‌​]{2,6}\b([-a-zA-Z0-9‌​@:%_\+.~#?&=]*)/g
		if (url_valid.test(url_text)) {
		  $("#url").css({ "color": color_valid, "border-color": color_valid })
		} else {
		  $("#url").css({ "color": color_invalid, "border-color": color_invalid })
		}
	 
		// Validate CAPTCHA
		var captcha_code = $("#captcha_code").text()
		var captcha = $("#captcha").val()
		if (captcha_code == captcha) {
		  $("#captcha").css({ "color": color_valid, "border-color": color_valid })
		}
		else {
		  $("#captcha").css({ "color": color_invalid, "border-color": color_invalid })
		}

		// Send POST if valid
	    if ((!url_valid.test(url_text)) && (captcha_code == captcha)) {
	        var form_data = { url: $("#url").val(),
		        	  title: $('#title').val(),
			          keywords: $('#keywords').val(),
				  email_pgp: $('#email_pgp').val()
				}
		$.redirectPost('/document_submit/', form_data)
		window.location = "/document_sent"
		} else if ((url_valid.test(url_text)) || (captcha_code !== captcha)) {
			console.log('not valid')
			return false
		}
	})       
})
