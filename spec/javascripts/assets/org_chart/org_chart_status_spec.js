describe("OrgChartStatus", function() {
  it('resets the tree at beginning', function(done) {
    OrgChartStatus.prototype.resetTree = sinon.stub().returns(new $.Deferred());
    OrgChartStatus.prototype.keepTreeUpdate = sinon.stub().returns(new $.Deferred());
    var status = new OrgChartStatus();

    setTimeout(function() {
      expect(status.resetTree.calledOnce).to.be(true);
      done()
    }, 1000);
  });

})  
