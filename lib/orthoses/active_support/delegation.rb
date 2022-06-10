# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class Delegation
      def initialize(loader)
        @loader = loader
      end

      # def delegate(*methods, to: nil, prefix: nil, allow_nil: nil, private: nil)
      # def delegate_missing_to(target, allow_nil: nil)
      def call
        target_method = begin
          ::Module.method(:delegate)
        rescue NameError => err
          Orthoses.logger.warn("Run `require 'active_support/core_ext/module/delegation'` and retry because #{err}")
          require 'active_support/core_ext/module/delegation'
          retry
        end
        delegate = CallTracer.new
        store = delegate.trace(target_method) do
          @loader.call
        end

        resource = Resource.new(store)

        delegate.captures.each do |capture|
          receiver_name = Utils.module_name(capture.method.receiver) or next
          receiver_content = store[receiver_name]
          case capture.argument[:to]
          when Module
            to_module_name = Utils.module_name(capture.argument[:to]) or next
            capture.argument[:methods].each do |arg|
              if sig = resource.build_signature(to_module_name, arg, :singleton, false)
                receiver_content << "# defined by `delegate` to: #{to_module_name}"
                receiver_content << sig
              else
                Orthoses.logger.warn("[ActiveSupport::Delegation] Ignore #{arg.inspect}")
              end
            end
          else
            to_name = capture.argument[:to].to_s.to_sym
            tag, to_return_type = resource.find(receiver_name, to_name, :instance, false)
            raise "bug" if tag == :multi
            if to_return_type.nil?
              Orthoses.logger.warn("[ActiveSupport::Delegation] Ignore #{capture.argument.inspect}")
              next
            end
            if to_return_type.instance_of?(RBS::Types::Bases::Any)
              capture.argument[:methods].each do |method|
                receiver_content << "# defined by `delegate` to: :#{to_name}(#{to_return_type})"
                receiver_content << "def #{method}: (*untyped, **untyped) -> untyped"
              end
            else
              to_typename = to_return_type.name.relative!.to_s
              capture.argument[:methods].each do |method|
                if sig = resource.build_signature(to_typename, method, :instance, true)
                  receiver_content << "# defined by `delegate` to: :#{to_name}(#{to_return_type})"
                  receiver_content << sig
                else
                  Orthoses.logger.warn("[ActiveSupport::Delegation] Ignore #{method.inspect}")
                end
              end
            end
          end
        end

        store
      end

      private

      class Resource
        def initialize(store)
          @store = store
          env = Orthoses::Utils.rbs_environment(collection: true)
          @definition_builder = RBS::DefinitionBuilder.new(env: env)
        end

        def find(mod_name, name, kind, argument)
          typename = TypeName(mod_name).absolute!

          if definition_method = build_definition(typename, kind)&.methods&.[](name)
            return [:multi, definition_method.defs.map(&:type)]
          end
          resolve_type_by_name(@store[mod_name].to_decl.members, name, kind, argument)
        end

        def build_definition(typename, kind)
          case kind
          when :instance
            @definition_builder.build_instance(typename)
          when :singleton
            @definition_builder.build_singleton(typename)
          else
            raise "big"
          end
        rescue RuntimeError => e
          if e.message.match?(/\AUnknown name for/)
            nil
          else
            raise
          end
        end

        def build_signature(mod_name, name, kind, argument)
          tag, type = find(mod_name, name, kind, argument)
          case tag
          when :single
            "def #{name}: () -> #{type}"
          when :multi
            "def #{name}: #{type.join(' | ')}"
          else
            nil
          end
        end

        private

        def resolve_type_by_name(members, name, kind, argument)
          members.each do |member|
            case member
            when RBS::AST::Members::MethodDefinition
              next unless member.name == name && member.kind == kind
              if argument
                return [:multi, member.types]
              else
                type = member.types.find do |method_type|
                  method_type.type.required_positionals.empty? && method_type.type.required_keywords.empty?
                end
                next unless type
                return [:single, type.type.return_type]
              end
            when RBS::AST::Members::Var
              next unless member.name == name
              return [:single, member.type]
            when RBS::AST::Declarations::Constant
              next unless member.name.to_s.to_sym == name
              return [:single, member.type]
            when RBS::AST::Members::Attribute
              next unless member.name == name && member.kind == kind
              return [:single, member.type]
            when RBS::AST::Members::Alias
              next unless member.new_name == name && member.kind == kind
              return resolve_type_by_name(members, member.old_name, kind, argument)
            when RBS::AST::Members::Mixin, RBS::AST::Members::LocationOnly
              next
            else
              binding.irb
            end
          end

          nil
        end
      end
    end
  end
end
