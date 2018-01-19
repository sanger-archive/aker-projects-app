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
    $('#editNodeModal').on('shown.bs.modal', $.proxy(this.onShownModal, this, this.loadDataReleaseStrategies()));

    $('div.modal-content', '#editNodeModal').load(url+ '/edit.js', $.proxy(this.onLoadUpdateNodeForm, this))
  };

  proto.onShownModal = function(promiseDataRelease) {
    return promiseDataRelease.then($.proxy(this.onLoadDataReleaseStrategies, this));
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

  proto.addDataReleaseOptionToSelect = function(select, id, name, selected) {
    var option = $('<option></option>');
    option.html(name)
    option.attr('value', id);
    option.attr('selected', selected);
    select.append(option);
    return option;
  };

  proto.onLoadDataReleaseStrategies = function(json) {
    //return;
    var select = $('#node_form_data_release_strategy_id');
    var selectedValue = select.val();
    var selectionMade = false;

    select.html('');

    var noStrategy = this.addDataReleaseOptionToSelect(select, "", 'No strategy', !selectedValue);

    for (var i=0; i<json.length; i++) {
      var option = this.addDataReleaseOptionToSelect(select, json[i].id, json[i].name, (json[i].id === selectedValue))
      if (option.attr('selected')) {
        selectionMade = true; 
      }
    }

    if ((!selectionMade) && (selectedValue)) {
      this.addDataReleaseOptionToSelect(select, selectedValue, 'ERROR - Selected ID not found in sequencescape', true);
    }
    select.attr('disabled', false);
  };

  proto.loadDataReleaseStrategies = function() {
    return $.ajax({
      url: Routes.data_release_strategies_path(), 
      method: 'GET'
    });
  };

  proto.onSuccessfulFormUpdateNode = function(e, data, status, xhr) {
    // If the node has updated, we need reload the tree to show changes
    this.loadTree();

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
      $.proxy(this.onErrorConnection, this)
    ).then(
      $.proxy(this.keepTreeUpdate, this),
      $.proxy(this.onErrorConnection, this)
    );
  };

}(jQuery));
