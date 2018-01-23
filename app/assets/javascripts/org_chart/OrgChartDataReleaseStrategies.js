(function($,undefined) {
  function OrgChartDataReleaseStrategies() {
    this._selectSelectorCss = '#node_form_data_release_strategy_id';
    this.attachDataReleaseHandlers();
  }

  window.OrgChartDataReleaseStrategies = OrgChartDataReleaseStrategies;

  var proto = OrgChartDataReleaseStrategies.prototype;

  proto.attachDataReleaseHandlers = function() {
    var method = this.onUpdateNodes;

    // We will add more actions after the execution of onUpdateNodes
    this.onUpdateNodes = $.proxy(function() {

      var value = method.apply(this, arguments);

      if (typeof this._previousShownHandler !== 'undefined') {
        $('#editNodeModal').off('shown.bs.modal', this._previousShownHandler);
        delete(this._previousShownHandler);
      }      
      // Whenever onUpdateNodes is called we will send a request to get the data release strategies (that is why we execute 
      // loadDataReleaseStrategies here), but we will not render its contents (onLoadDataReleaseStrategies) until 
      // after the modal has been totally generated and displayed (which it happens when event shown.bs.modal is thrown). That
      // is why in onShownDataReleaseInModal we attach onLoadDataReleaseStrategies to the .then() for the returned promise ($.ajax)
      var handler = $.proxy(this.onShownModal, this, this.loadDataReleaseStrategies());
      $('#editNodeModal').on('shown.bs.modal', handler);
      this._previousShownHandler = handler;

      return value;
    }, this);
  };

  proto.showSpinner = function() {
    var select = $(this._selectSelectorCss);
    var spinner = $('<span class="fa-li fa fa-spinner fa-spin" style="position:static;"></span>');

    $('label', select.parent()).append(spinner);
  };

  proto.removeSpinner = function() {
    var select = $(this._selectSelectorCss);
    $('.fa-spinner', select.parent()).remove();;
  };

  // Attaches the rendering of the data release options to the resolution of the promise passed as argument 
  // (in the current code this promise is the ajax call to the data release endpoint)
  // Adds the spinner to the modal.  
  proto.onShownModal = function(promiseDataRelease) {
    this.showSpinner();

    return promiseDataRelease.then(
      $.proxy(this.onLoadDataReleaseStrategies, this),
      $.proxy(this.onErrorLoadDataReleaseStrategies, this)
    );
  };

  // Builds one HTML option for the data release Select
  proto.addDataReleaseOptionToSelect = function(select, id, name, selected, title) {
    var option = $('<option></option>');
    option.html(name)
    option.attr('value', id);
    option.attr('selected', selected);
    if (title) {
      option.attr('title', title);
    }
    select.append(option);
    return option;
  };

  proto.onErrorLoadDataReleaseStrategies = function() {
    var select = $(this._selectSelectorCss);
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
    var select = $(this._selectSelectorCss);
    var selectedValue = select.val();
    var selectedText = $("option:selected", select).text();
    var selectionMade = false;

    // Title is the tooltip that is displayed on mouse over containing the full name for the option selected (which is
    // useful when the label_to_display is a truncated string)
    var selectedTitle = select.attr('title');    
    
    select.html('');


    var noStrategy = this.addDataReleaseOptionToSelect(select, "", 'No strategy', !selectedValue);

    for (var i=0; i<json.length; i++) {
      var option = this.addDataReleaseOptionToSelect(select, json[i].id, json[i].label_to_display, (json[i].id === selectedValue), json[i].name)
      if (option.attr('selected')) {
        select.attr('title', json[i].name);
        selectionMade = true;
      }
    }

    if ((!selectionMade) && (selectedValue)) {
      this.addDataReleaseOptionToSelect(select, selectedValue, selectedText, true, selectedTitle);
      //this.addDataReleaseOptionToSelect(select, selectedValue, 'ERROR - Selected ID not found in sequencescape', true);
    }
    select.attr('disabled', false);
    this.removeSpinner();
    this._cachedDataReleases = json;
  };

  // Performs an ajax request to the data release endpoint and returns a promise
  proto.loadDataReleaseStrategies = function() {
    if (this._cachedDataReleases) {
      return new $.Deferred().resolve(this._cachedDataReleases);
    }
    return $.ajax({
      url: Routes.data_release_strategies_path(), 
      cache: true,
      method: 'GET'
    });
  };

}(jQuery));