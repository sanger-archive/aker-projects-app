class EventMessage

  def initialize(params)
    @node = params[:node]
    @user = params[:user]
    @event = params[:event]
  end

  def trace_id
    ZipkinTracer::TraceContainer.current&.next_id&.trace_id&.to_s
  end

  def roles
    r = [
      {
        role_type: "project",
        subject_type: "project",
        subject_friendly_name: @node.name,
        subject_uuid: @node.node_uuid,
      },
    ]
    parent_node = @node.parent
    if parent_node
      r.push(
        {
          role_type: "parent project",
          subject_type: "project",
          subject_friendly_name: parent_node.name,
          subject_uuid: parent_node.node_uuid,
        }
      )
    end
    return r
  end

  def metadata
    {
      node_id: @node.id,
      zipkin_trace_id: trace_id,
      owner: @node.owner_email,
      description: @node.description,
      cost_code: @node.cost_code,
      deactivated_datetime: @node.deactivated_datetime,
      deactivated_by: @node.deactivated_by,
    }
  end

  def generate_json
    {
      event_type: "aker.events.project.#{@event}",
      lims_id: "aker",
      uuid: SecureRandom.uuid,
      timestamp: Time.now.utc.iso8601,
      user_identifier: @user,
      roles: roles,
      metadata: metadata,
    }.to_json
  end

end
