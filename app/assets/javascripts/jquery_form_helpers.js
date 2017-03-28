$.fn.render_form_errors = function(model_name, errors) {
  var form = this;
  this.clear_form_errors();

  $.each(errors, function(field, messages) {
    // Rails forms always give form inputs the name "model[attribute]" e.g. name="node[description]"
    var nodeName = model_name + "[" + field + "]"

    // :input will return any kind of form input
    // See http://api.jquery.com/input-selector/
    var input = $(':input[name="' + nodeName + '"]' ,form);

    input.closest('.form-group').addClass('has-error')
    input.parent().append('<span class="help-block">' + messages.join('<br />') + '</span>')
  })
}

$.fn.clear_form_errors = function() {
  this.find('.form-group').removeClass('has-error')
  this.find('span.help-block').remove()
}
