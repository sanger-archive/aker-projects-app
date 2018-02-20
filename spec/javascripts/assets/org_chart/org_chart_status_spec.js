describe("OrgChartStatus", function() {
  it('is able to connect using websockets', function(done) {
    OrgChartStatus.prototype.onConnectWebSocket = sinon.stub().returns(new $.Deferred());
    var status = new OrgChartStatus();
    expect(status.onConnectWebSocket.called).to.be(false);

    setTimeout(function() {
      expect(status.onConnectWebSocket.calledOnce).to.be(true);
      done();
    }, 1000);
  });

  it('receives update messages from websockets', function(done) {
    OrgChartStatus.prototype.onReceiveWebSocketsMessage = sinon.stub().returns(new $.Deferred());
    OrgChartStatus.prototype.keepTreeUpdate = sinon.stub().returns(new $.Deferred());
    var status = new OrgChartStatus();
    expect(status.onReceiveWebSocketsMessage.called).to.be(false);
    Teaspoon.hook('cable_message', ["TheBigTree", {notifyChanges: true}])
    setTimeout(function() {
      expect(status.onReceiveWebSocketsMessage.called).to.be(true);
      expect(status.keepTreeUpdate.called).to.be(true);
      done();
    }, 1000);
  })
  it('does not update from websockets if the message received does not indicate it', function(done) {
    OrgChartStatus.prototype.onReceiveWebSocketsMessage = sinon.stub().returns(new $.Deferred());
    OrgChartStatus.prototype.keepTreeUpdate = sinon.stub().returns(new $.Deferred());
    var status = new OrgChartStatus();
    expect(status.onReceiveWebSocketsMessage.called).to.be(false);
    Teaspoon.hook('cable_message', ["TheBigTree", {notifyChanges: false}])
    setTimeout(function() {
      expect(status.onReceiveWebSocketsMessage.called).to.be(true);
      expect(status.keepTreeUpdate.called).to.be(false);
      done();
    }, 1000);
  });

})  
