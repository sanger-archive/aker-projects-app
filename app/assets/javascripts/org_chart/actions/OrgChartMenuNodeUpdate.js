(function($, undefined) {
  function OrgChartMenuNodeUpdate() {};


  window.OrgChartMenuNodeUpdate = OrgChartMenuNodeUpdate;

  var proto = OrgChartMenuNodeUpdate.prototype;

  proto.onUpdateNodes = function($node) {
    this.selectNode($node);
    // We get the nodeId of the currently selected node

    var url = '/nodes/'+this.selectedNode().attr('id');

    // We call jQuery's load method to fetch the html content of /nodes/:id/edit.js
    // and load it into the modal body
    $('#editNodeModal').modal('show');
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
      .on('ajax:success', $.proxy(this.onSuccessfulFormUpdateNode, this))
      .on('ajax:error', function(e, data, status, xhr) {
        $('form', 'div.modal-body').render_form_errors('node', data.responseJSON);
      });
    $("[data-behavior~=selectize]", 'div.modal-body').each(window.aker.selectize_element);
  };

  proto.onSuccessfulFormUpdateNode = function(e, data, status, xhr) {
    // If the name has updated, we need to update the node
    this.selectedNode().find('div.title').text(data['name']);
    this.selectedNode().find('div.content').text(data['cost_code']);

    // Show a success message
    $('div.modal-body', '#editNodeModal').prepend('<div class="alert alert-success">Update successful</div>');

    // Setting a timeout so the user can see the update was successful just before closing
    // the modal window
    setTimeout(function() {
      $('#editNodeModal input').each(function(input) {
        $(input).val('');
      });
      $('#editNodeModal').modal('hide');
    }, 500);
  };

  proto.onUpdateNode = function(id, event) {
  };

  proto.updateNode = function(id, event) {
    return $.ajax({
        headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : '/api/v1/nodes/'+event.draggedNode[0].id+'/relationships/parent',
        type : 'PATCH',
        data : JSON.stringify({ data: { type: 'nodes', id: id }})
    }).then(
      $.proxy(this.onUpdateNode, this, id, event),
      $.proxy(this.onErrorConnection, this)
    ).then(
      $.proxy(this.keepTreeUpdate, this),
      $.proxy(this.onErrorConnection, this)
    );
  };

}(jQuery));
