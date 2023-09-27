# frozen_string_literal: true

module EventLoggerRails
  module Extensions
    ##
    # Provides event logging with relevant model data.
    module Loggable
      def log_event(event, level = :warn, **data)
        logger_trace.disable if instance_variable_defined?(:@logger_call_stack)
        EventLoggerRails.log(event, level, data.merge(optional_data).merge(trace_data))
      end

      def trace_and_log_event(event, level = :warn, **data)
        logger_trace.enable
        yield
        logger_trace.disable
        log_event(event, level, **data)
      end

      private

      def logger_trace
        @logger_trace ||= TracePoint.new(:call) do |trace_point|
          logger_call_stack << details_for_trace(trace_point)
        end
      end

      def details_for_trace(trace_point)
        {
          class: trace_point.defined_class,
          method: trace_point.method_id,
          parameters: trace_point.parameters.map do |type, name|
            value = trace_point.binding.local_variable_get(name)
            [type, name, value]
          end,
          path: trace_point.path.sub(%r{^#{Regexp.escape(Rails.root.to_s)}/}, '')
        }
      end

      def logger_call_stack
        @logger_call_stack ||= []
      end

      def trace_data
        {
          trace: logger_call_stack[0..-3]
        }
      end

      def optional_data
        {}
      end
    end
  end
end
