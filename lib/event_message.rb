# frozen_string_literal: true

# A message for the event queue.
# The information in the event describes the current state of a node.
# Use generate_json to get the data to put on the queue.
class EventMessage
  attr_reader :node, :user, :event

  ROUTING_KEY = 'aker.events.study-management'

  def initialize(params)
    @node = params[:node]
    @user = params[:user]
    @event = params[:event]
    @event_uuid = SecureRandom.uuid
    @trace_id = ZipkinTracer::TraceContainer.current&.next_id&.trace_id&.to_s
    @timestamp = Time.now
  end

  def roles
    r = [
      {
        role_type: 'project',
        subject_type: 'project',
        subject_friendly_name: @node.name,
        subject_uuid: @node.node_uuid
      }
    ]
    parent_node = @node.parent
    if parent_node
      r.push(
        role_type: 'parent project',
        subject_type: 'project',
        subject_friendly_name: parent_node.name,
        subject_uuid: parent_node.node_uuid
      )
    end
    r
  end

  def metadata
    {
      node_id: @node.id,
      zipkin_trace_id: @trace_id,
      owner_email: @node.owner_email,
      description: @node.description,
      cost_code: @node.cost_code,
      deactivated_datetime: @node.deactivated_datetime&.utc&.iso8601,
      deactivated_by: @node.deactivated_by,
      data_release_uuid: @node.data_release_strategy_id
    }
  end

  def generate_json
    {
      event_type: "aker.events.project.#{@event}",
      lims_id: 'aker',
      uuid: @event_uuid,
      timestamp: @timestamp.utc.iso8601,
      user_identifier: @user,
      roles: roles,
      metadata: metadata
    }.to_json
  end
end
