# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class Concern
      def initialize(loader)
        @loader = loader
      end

      def call
        lazy_tracer = Orthoses::CallTracer::Lazy.new

        store = lazy_tracer.trace('ActiveSupport::Concern#class_methods') do
          @loader.call
        end

        lazy_tracer.captures.each do |capture|
          receiver_name = Orthoses::Utils.module_name(capture.method.receiver)
          next unless receiver_name

          class_methods_name = "#{receiver_name}::ClassMethods"
          members = members_prototype_of(class_methods_name)

          writer = ::RBS::Writer.new(out: StringIO.new)
          members.each do |member|
            writer.write_member(member)
          end
          out = writer.out
          # NOTE: Should I remove the method that is accidentally added in prototype rb?
          store[class_methods_name].concat(out.string.each_line.to_a)
        end

        store
      end

      def members_prototype_of(mod_name)
        mod = Object.const_get(mod_name)
        runtime = ::RBS::Prototype::Runtime.new(patterns: nil, env: nil, merge: false)
        type_name = ::RBS::TypeName.parse(mod_name)
        [].tap do |members|
          runtime.generate_methods(mod, type_name, members)
        end
      end
    end
  end
end
