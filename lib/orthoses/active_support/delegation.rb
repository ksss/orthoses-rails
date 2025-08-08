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
        delegate = CallTracer::Lazy.new
        store = delegate.trace('Module#delegate') do
          @loader.call
        end

        resource = Resource.new(store)

        delegate.captures.each do |capture|
          receiver_name = Utils.module_name(capture.method.receiver) or next
          receiver_content = store[receiver_name]
          prefix = capture.argument[:private] ? "private " : ""

          case capture.argument[:to]
          # delegate :foo, to: Foo
          when Module
            to_module_name = Utils.module_name(capture.argument[:to]) or next
            capture.argument[:methods].each do |arg|
              if sig = resource.build_signature(to_module_name, arg, :singleton, false)
                receiver_content << "# defined by `delegate` to: #{to_module_name}"
                receiver_content << "#{prefix}#{sig}"
              else
                Orthoses.logger.warn("[ActiveSupport::Delegation] Ignore since missing type for #{to_module_name}.#{arg.inspect} in #{capture.argument.inspect}")
              end
            end
          else
            to_name = capture.argument[:to].to_s.to_sym
            tag, to_return_type = resource.find(receiver_name, to_name, :instance, false)
            if tag == :multi
              to_return_type = if to_return_type.length == 1
                to_return_type.first.type.return_type
              else
                nil
              end
            end

            case to_return_type
            when nil, RBS::Types::Bases::Any
              # no type found
              capture.argument[:methods].each do |method|
                receiver_content << "# defined by `delegate` to: #{to_return_type}##{to_name}"
                receiver_content << "#{prefix}def #{method}: (?) -> untyped"
              end
            else
              # found return type in store or env
              to_typename = to_return_type.name.relative!.to_s
              capture.argument[:methods].each do |method|
                if sig = resource.build_signature(to_typename, method, :instance, true)
                  receiver_content << "# defined by `delegate` to #{to_return_type}##{to_name}"
                  receiver_content << "#{prefix}#{sig}"
                else
                  Orthoses.logger.warn("[ActiveSupport::Delegation] Ignore since missing type for #{to_typename}##{method.inspect} in #{capture.argument.inspect}")
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
          typename = ::RBS::TypeName.parse(mod_name).absolute!

          if definition_method = build_definition(typename, kind)&.methods&.[](name)
            # found in env
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
            raise "bug"
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
                return [:multi, member.overloads.map { |o| o.method_type }]
              else
                method_type = member.overloads.map(&:method_type).find do |method_type|
                  is_untyped_function = defined?(RBS::Types::UntypedFunction) && method_type.type.is_a?(RBS::Types::UntypedFunction)
                  is_untyped_function || (method_type.type.required_positionals.empty? && method_type.type.required_keywords.empty?)
                end
                next unless method_type
                return [:single, method_type.type.return_type]
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
              raise "bug: #{member.class} is not supported yet"
            end
          end

          nil
        end
      end
    end
  end
end
