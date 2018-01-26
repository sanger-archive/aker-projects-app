(function($,undefined) {
  function OrgChartDataReleaseStrategies() {
    this._selectSelectorCss = '#node_form_data_release_strategy_id';
    this.attachDataReleaseHandlers();
  }

  window.OrgChartDataReleaseStrategies = OrgChartDataReleaseStrategies;

  var proto = OrgChartDataReleaseStrategies.prototype;

  proto.attachDataReleaseHandlers = function() {
    var method = this.onLoadUpdateNodeForm;

    // We will add more actions after the execution of onUpdateNodes
    this.onLoadUpdateNodeForm = $.proxy(function() {

      var value = method.apply(this, arguments);

      if ($(this._selectSelectorCss).data('psd-async') == true) {
        this.onShownModal(this.loadDataReleaseStrategies());
      }

      return value;
    }, this);
  };

  proto.cached = function() {
    return ($(this._selectSelectorCss).data('psd-cached') == true);
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

  // Removes all content from the select
  proto.resetSelect = function(select) {
    select.html('');
  };

  // Attaches the rendering of the data release options to the resolution of the promise passed as argument 
  // (in the current code this promise is the ajax call to the data release endpoint)
  // Adds the spinner to the modal.  
  proto.onShownModal = function(promiseDataRelease) {
    var select = $(this._selectSelectorCss);

    this.showSpinner();    

    this._isDisabledAttributeForSelect = !!select.attr('disabled');

    select.attr('disabled', true);
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

  proto.onErrorLoadDataReleaseStrategies = function(event) {
    var select = $(this._selectSelectorCss);
    var selectedValue = select.val();
    var selectedText = $("option:selected", select).text();

    this.resetSelect(select);

    var noStrategy = this.addDataReleaseOptionToSelect(select, "", 'No strategy', selectedValue=='');
    if (selectedValue !=='') {
      this.addDataReleaseOptionToSelect(select, selectedValue, selectedText, true);
    }
    select.attr('disabled', this._isDisabledAttributeForSelect);
    this.removeSpinner();
    this.showError('HTTP '+event.status+' - '+event.statusText);
  };

  proto.showError = function(text) {
    $('form', 'div.modal-body').render_form_errors('node_form', {data_release_strategy_id: [text]});
  }

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
    select.attr('disabled', this._isDisabledAttributeForSelect);
    this.removeSpinner();
    this._cachedDataReleases = json;
  };

  // Performs an ajax request to the data release endpoint and returns a promise
  proto.loadDataReleaseStrategies = function() {
    if (this.cached() && (this._cachedDataReleases)) {
      return new $.Deferred().resolve(this._cachedDataReleases);
    }
    return $.ajax({
      url: Routes.data_release_strategies_path(), 
      cache: true,
      method: 'GET'
    });
  };

}(jQuery));