(function($, undefined) {
  var SAVE_URL = "/tree_layouts";
  var RESTORE_URL = "/tree_layouts";
  var DELETE_URL = "/tree_layouts";

  function OrgChartPreferences() {
    this.attachPreferencesHandlers();
  };

  window.OrgChartPreferences = OrgChartPreferences;

  var proto = OrgChartPreferences.prototype;

  proto.attachPreferencesHandlers = function() {
    $('button[data-user-preferences-save]').on('click', $.proxy(this.saveUserConfig, this));
    $('button[data-user-preferences-restore]').on('click', $.proxy(this.restoreUserConfig, this));
    $('button[data-user-preferences-delete]').on('click', $.proxy(this.deleteUserConfig, this));
  };

  proto.onSaveUserConfig = function() {
    this.info('Tree layout saved')
  };

  proto.onErrorSaveUserConfig = function() {
    this.alert('There was a problem while saving tree layout for current user');
  };

  proto.onRestoreUserConfig = function(json) {
    var layout = this.parseLayout(json[0]);
    var success = this.applyLayout(layout);
    if (success) {
      this.info('Tree layout restored');
    } else {
      this.onErrorRestoreUserConfig();  
    }
  };

  proto.onErrorRestoreUserConfig = function() {
    this.alert('There was a problem while restoring tree layout for current user');
  };

  proto.parseLayout = function(json) {
    return JSON.parse(json.tree_layout.layout);
  };

  function getIdsForNodesWithCss(cssSelector) {
    return $(cssSelector).map(function(pos, n) { return n.id;}).toArray();
  }

  proto.getLayout = function() {
    return {
      'slide-left': getIdsForNodesWithCss('.node.slide-left'),
      'slide-right': getIdsForNodesWithCss('.node.slide-right'),
      'slide-up': getIdsForNodesWithCss('.node.slide-up'),
      'slide-down': getIdsForNodesWithCss('.node.slide-down')
    }
  };

  proto.serializeLayout = function() {
    return JSON.stringify({tree_layout: {layout: JSON.stringify(this.getLayout())}});
  };

  proto.applyLayout = function(layout) {
    var id;

    for (var key in layout) {
      for (var i=0; i<layout[key].length; i++) {
        id = layout[key][i]
        var node = document.getElementById(id);
        $(node).addClass(key);
      }
    }
    return true;
  };

  proto.saveUserConfig = function() {
    return $.ajax({
      headers : {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json'
      },
      method: 'POST',
      url: SAVE_URL, 
      data: this.serializeLayout()
    }).then(
      $.proxy(this.onSaveUserConfig, this), 
      $.proxy(this.onErrorSaveUserConfig, this)
    );
  };

  proto.deleteUserConfig = function() {
    return $.ajax({
      headers : {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json'
      },      
      method: 'DELETE',
      url: DELETE_URL
    }).then(
      $.proxy(this.onDeleteUserConfig, this), 
      $.proxy(this.onErrorDeleteUserConfig, this)
    );
  };

  proto.onDeleteUserConfig = function() { this.info('Tree layout deleted')};
  proto.onErrorDeleteUserConfig = function() { this.alert('Error while deleting tree layout')};

  proto.restoreUserConfig = function() {
    return $.ajax({
      headers : {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json'
      },      
      method: 'GET',
      url: RESTORE_URL
    }).then(
      $.proxy(this.onRestoreUserConfig, this), 
      $.proxy(this.onErrorRestoreUserConfig, this)
    );
  };

})(jQuery);