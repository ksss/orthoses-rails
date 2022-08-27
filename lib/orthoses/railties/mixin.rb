module Orthoses
  module Railties
    class Mixin
      class MultiTracer
        module Hook
          def include(*mods)
            super
          end
          def extend(*mods)
            super
          end
          def prepend(*mods)
            super
          end
        end

        class MiniTracer
          attr_reader :captures

          def initialize
            @depth = []
            @captures = []
            @tp = TracePoint.new(:call) do |tp|
              if @depth.length > 0
                @captures << [tp.self, tp.method_id, tp.binding.local_variable_get(:mods)]
              end
            end
          end

          def trace(target:, &block)
            @tp.enable(target: target, &block)
          end

          def push
            @depth << true
          end

          def pop
            @depth.pop
          end
        end

        def initialize
          ::Module.prepend(Hook)
          @run = LazyTracePoint.new(:call, :return) do |tp|
            case tp.event
            when :call
              @include.push
              @extend.push
              @prepend.push
            when :return
              @include.pop
              @extend.pop
              @prepend.pop
            end
          end
          @include = MiniTracer.new
          @extend = MiniTracer.new
          @prepend = MiniTracer.new
        end

        def trace
          @run.enable(target: 'ActiveSupport::LazyLoadHooks#execute_hook') do
            @include.trace(target: Hook.instance_method(:include)) do
              @extend.trace(target: Hook.instance_method(:extend)) do
                @prepend.trace(target: Hook.instance_method(:prepend)) do
                  yield
                end
              end
            end
          end
        end

        def captures
          @include.captures.concat(@extend.captures).concat(@prepend.captures)
        end
      end # MultiTracer

      def initialize(loader, callback:)
        @loader = loader
        @callback = callback
      end

      def call
        multi_tracer = MultiTracer.new
        store = multi_tracer.trace do
          @loader.call
        end

        railties_mixin = Utils.new_store

        multi_tracer.captures.each do |base_mod, how, mods|
          base_mod_name = Utils.module_name(base_mod) or next
          mod_names = mods.map { |mod| Utils.module_name(mod) }.compact
          mod_names.each do |mod_name|
            store[base_mod_name].delete("#{how} #{mod_name}")
            railties_mixin[base_mod_name] << "#{how} #{mod_name}"
          end
        end

        @callback.call(railties_mixin)

        store
      end
    end
  end
end
