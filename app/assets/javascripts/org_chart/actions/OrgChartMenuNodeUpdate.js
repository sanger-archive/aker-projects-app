(function($, undefined) {
  function OrgChartMenuNodeUpdate() {};


  window.OrgChartMenuNodeUpdate = OrgChartMenuNodeUpdate;

  var proto = OrgChartMenuNodeUpdate.prototype;

  proto.onUpdateNodes = function(e) {
    // We get the nodeId of the currently selected node

    var url = '/nodes/'+$('#selected-node').data('node')[0].id; 

    // We call jQuery's load method to fetch the html content of /nodes/:id/edit.js
    // and load it into the modal body
    $('div.modal-body', '#editNodeModal').load(url+ '/edit.js', $.proxy(this.onLoadUpdateNodeForm, this));
  };

  proto.onLoadUpdateNodeForm = function(response, status, xhr) {
    $('form', 'div.modal-body')
      .on('ajax:before', function() {
        $(this).clear_form_errors();
      })
      .on('ajax:beforeSend', function(event, xhr, settings) {
        xhr.setRequestHeader('Accept', 'application/json');
      })
      .on('ajax:success', $.proxy(this.onUpdateNode, this))
      .on('ajax:error', function(e, data, status, xhr) {
        $('form', 'div.modal-body').render_form_errors('node', data.responseJSON);
      })
  };

  proto.onUpdateNode = function(e, data, status, xhr) {
    // If the name has updated, we need to update the node
    $('#selected-node').data('node').find('div.title').text(data['name']);
    $('#selected-node').data('node').find('div.content').text(data['cost_code']);

    // Show a success message
    $('div.modal-body', '#editNodeModal').prepend('<div class="alert alert-success">Update successful</div>');

    // Setting a timeout so the user can see the update was successful just before closing
    // the modal window
    setTimeout(function() {
      $('#editNodeModal input').each(function(input) {
        $(input).val('');
      });
      $('#editNodeModal').modal('hide');
    }, 1000);
  };

  proto.onSuccessfulUpdateNode = function(id, event) {
    var dropNode = $('#'+id+'.node');
    var draggedNode = $('#'+event.draggedNode[0].id+'.node');
  };  

  proto.updateNode = function(id, event) {
    return this.keepTreeUpdate().then($.proxy(function() {
      return $.ajax({
        headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : '/api/v1/nodes/'+event.draggedNode[0].id+'/relationships/parent',
        type : 'PATCH',
        data : JSON.stringify({ data: { type: 'nodes', id: id }})
      }).then($.proxy(this.onSuccessfulUpdateNode, this, id, event), $.proxy(this.onErrorConnection, this));
    }, this));
  };

}(jQuery));
