(function($, undefined) {
  function OrgChartMenuNodeUpdate() {};


  window.OrgChartMenuNodeUpdate = OrgChartMenuNodeUpdate;

  var proto = OrgChartMenuNodeUpdate.prototype;

  proto.onUpdateNodes = function($node) {
    this.selectNode($node);
    // We get the nodeId of the currently selected node

    var url = Routes.node_path(this.selectedNode().attr('id'));

    // We call jQuery's load method to fetch the html content of /nodes/:id/edit.js
    // and load it into the modal body
    $('#editNodeModal').modal('show');

    // It will wait 10 seconds to get the form from the server; otherwise it will display an error message
    $.ajax(url+ '/edit.js', {
      timeout: 10000,
      dataType: 'html',
      success: $.proxy(function(response) {
        $('div.modal-content', '#editNodeModal').html(response);
        this.onLoadUpdateNodeForm();
      }, this),
      error: function() {
        $('div.modal-body', '#editNodeModal').html('There was an error while trying to obtain the form. Please contact the administrator');
      }
    });
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
        $('form', 'div.modal-body').render_form_errors('node_form', data.responseJSON);
      });
    $("[data-behavior~=selectize]", 'div.modal-body').each(window.aker.selectize_element);
  };

  proto.onSuccessfulFormUpdateNode = function(e, data, status, xhr) {
    // Show a success message
    $('div.modal-body', '#editNodeModal').prepend('<div class="alert alert-success">Update successful</div>');

    // Setting a timeout so the user can see the update was successful just before closing
    // the modal window
    setTimeout(function() {
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
        url : Routes.api_v1_node_relationships_parent_path(event.draggedNode[0].id),
        type : 'PATCH',
        data : JSON.stringify({ data: { type: 'nodes', id: id }})
    }).then(
      $.proxy(this.onUpdateNode, this, id, event),
      function(response, codeId, status) {
        this.reloadTree();
        this.onErrorConnection(response, codeId, status);
      }.bind(this)
    )
  };

}(jQuery));
