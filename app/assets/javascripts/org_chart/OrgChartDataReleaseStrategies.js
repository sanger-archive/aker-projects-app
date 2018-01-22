(function($,undefined) {
  function OrgChartDataReleaseStrategies() {
    this.attachDataReleaseHandlers();
  }

  window.OrgChartDataReleaseStrategies = OrgChartDataReleaseStrategies;

  var proto = OrgChartDataReleaseStrategies.prototype;

  proto.attachDataReleaseHandlers = function() {
    var method = this.onUpdateNodes;

    // We will add more actions after the execution of onUpdateNodes
    this.onUpdateNodes = $.proxy(function() {

      var value = method.apply(this, arguments);

      // Whenever onUpdateNodes is called we will send a request to get the data release strategies (that is why we execute 
      // loadDataReleaseStrategies here), but we will not render its contents (onLoadDataReleaseStrategies) until 
      // after the modal has been totally generated and displayed (which it happens when event shown.bs.modal is thrown). That
      // is why in onShownDataReleaseInModal we attach onLoadDataReleaseStrategies to the .then() for the returned promise ($.ajax)
      $('#editNodeModal').on('shown.bs.modal', $.proxy(this.onShownDataReleaseInModal, this, this.loadDataReleaseStrategies()));

      return value;
    }, this);
  };

  // Attaches the rendering of the data release options to the resolution of the promise passed as argument 
  // (in the current code this promise is the ajax call to the data release endpoint)
  proto.onShownDataReleaseInModal = function(promiseDataRelease) {
    return promiseDataRelease.then(
      $.proxy(this.onLoadDataReleaseStrategies, this),
      $.proxy(this.onErrorLoadDataReleaseStrategies, this)
    );
  };

  // Builds one HTML option for the data release Select
  proto.addDataReleaseOptionToSelect = function(select, id, name, selected) {
    var option = $('<option></option>');
    option.html(name)
    option.attr('value', id);
    option.attr('selected', selected);
    select.append(option);
    return option;
  };

  proto.onErrorLoadDataReleaseStrategies = function() {
    var select = $('#node_form_data_release_strategy_id');
    var selectedValue = select.val();
    var selectedText = $("option:selected", select).text();

    select.html('');

    var noStrategy = this.addDataReleaseOptionToSelect(select, "", 'No strategy', selectedValue=='');
    if (selectedValue !=='') {
      this.addDataReleaseOptionToSelect(select, selectedValue, selectedText, true);
    }
    select.attr('disabled', false);
  };

  // Renders the HTML for the select with the different data release strategies that we got from the AJAX response
  proto.onLoadDataReleaseStrategies = function(json) {
    var select = $('#node_form_data_release_strategy_id');
    var selectedValue = select.val();
    var selectedText = $("option:selected", select).text();
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
      this.addDataReleaseOptionToSelect(select, selectedValue, selectedText, true);
      //this.addDataReleaseOptionToSelect(select, selectedValue, 'ERROR - Selected ID not found in sequencescape', true);
    }
    select.attr('disabled', false);
  };

  // Performs an ajax request to the data release endpoint and returns a promise
  proto.loadDataReleaseStrategies = function() {
    return $.ajax({
      url: Routes.data_release_strategies_path(), 
      cache: false,
      method: 'GET'
    });
  };

}(jQuery));