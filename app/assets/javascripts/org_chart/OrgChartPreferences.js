(function($, undefined) {
  var SAVE_URL = Routes.tree_layouts_path();
  var RESTORE_URL = Routes.tree_layouts_path();
  var DELETE_URL = Routes.tree_layouts_path();

  function OrgChartPreferences() {
    this.attachPreferencesHandlers();
  };

  window.OrgChartPreferences = OrgChartPreferences;

  var proto = OrgChartPreferences.prototype;

  proto.attachPreferencesHandlers = function() {
    $('[data-user-preferences-expand]').on('click', $.proxy(function() {
      this.loadTree({restoreStateRequested: false}).then($.proxy(this.saveUserConfig, this));
    }, this));
    $(this).on('orgchart.restoreStateRequested', $.proxy(function(event, opts) {
      $('.edge').on('click', $.proxy(function() {
        setTimeout($.proxy(this.saveUserConfig, this), 500);
      }, this));
      if ((!opts) || (!!opts.restoreStateRequested)) {
        this.restoreUserConfig();  
      }
    }, this)); 
  };

  proto.onSaveUserConfig = function() {
    //this.info('Tree layout saved')
  };

  proto.onErrorSaveUserConfig = function() {
    this.alert('There was a problem while saving tree layout for current user');
  };

  proto.onRestoreUserConfig = function(json) {
    var layout = this.parseLayout(json[0]);
    var success = this.applyLayout(layout);
    if (layout) {
      //this.info('Tree layout restored');
      return layout;
    } else {
      this.onErrorRestoreUserConfig();  
    }
  };

  proto.onErrorRestoreUserConfig = function() {
    this.alert('There was a problem while restoring tree layout for current user');
  };

  proto.parseLayout = function(json) {
    if (!json) {
      return null;
    }
    return JSON.parse(json.tree_layout.layout);
  };

  proto.storeLayoutValue = function (rel, action, memo, node) {
    var $node = $(node);
    var state = $('#tree-view').orgchart('getNodeState', $node, rel);
    if (state.exist && !state.visible) {
      memo[action].push($node.attr('id'));
    }
  }

  proto.getLayout = function() {
    return $('.node').filter($.proxy(function(pos, node) { 
      return this.isVisibleNode(node); 
    }, this)).toArray().reduce($.proxy(function(memo,node) {
      this.storeLayoutValue('parent','hideParent', memo, node);
      this.storeLayoutValue('children','hideChildren', memo, node);
      this.storeLayoutValue('siblings','hideSiblings', memo, node);
      return memo;
    }, this), {'hideParent': [], 'hideChildren': [], 'hideSiblings': []});
  };

  proto.serializeLayout = function() {
    return JSON.stringify({tree_layout: {layout: JSON.stringify(this.getLayout())}});
  };


  proto.isVisibleNode = function(node) {
    var $node = $(node);
    return !($node.hasClass('slide-up') || $node.hasClass('slide-down') || 
    $node.hasClass('slide-left') || $node.hasClass('slide-right'));
  };

  proto._applyLayoutAction = function($node, action) {
    if ($node && ($node.length>0)) {
      if (this.isVisibleNode($node)) {
        $('#tree-hierarchy').orgchart(action, $node);
      }
    }
  };

  proto.applyLayout = function(layout) {
    var id;
    var keys = ['hideParent', 'hideChildren', 'hideSiblings'];

    for (var j=0; j<keys.length; j++) {
      var key = keys[j];
      if (layout && layout[key]) {
        for (var i=0; i<layout[key].length; i++) {
          id = layout[key][i]
          var $node = $(document.getElementById(id));
          this._applyLayoutAction($node, key);
        }
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