# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class Delegation
      def initialize(loader)
        @loader = loader
      end

      def resolve_type_by_name(members, name)
        members.each do |member|
          case member
          when RBS::AST::Members::MethodDefinition
            next unless member.name == name && member.kind == :instance
            type = member.types.find do |method_type|
              method_type.type.required_positionals.empty? && method_type.type.required_keywords.empty?
            end
            next unless type
            return type.type.return_type
          when RBS::AST::Members::InstanceVariable
            next unless member.name == name
            return member.type
          when RBS::AST::Members::Attribute
            next unless member.name == name && member.kind == :instance
            return member.type
          when RBS::AST::Members::Alias
            next unless member.new_name == name && member.kind == :instance
            return resolve_type_by_name(members, member.old_name)
          when RBS::AST::Members::Mixin, RBS::AST::Members::LocationOnly
            return nil
          else
            binding.irb
          end
        end
        nil
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

        delegate.result.each do |method, argument|
          receiver_name = Utils.module_name(method.receiver) or next
          content = store[receiver_name]
          case argument[:to]
          when Module
            to_module_name = Utils.module_name(argument[:to]) or next
            argument[:methods].each do |arg|
              t = resolve_type_by_name(store[to_module_name].to_decl.members, arg)
              next unless t
              binding.irb
              content << "def #{arg}: #{t.types.join(' | ')}"
            end
          else
            to_name = argument[:to].to_s.to_sym
            to_type = resolve_type_by_name(content.to_decl.members, to_name)
            case to_type
            when RBS::Types::Bases::Any, nil
              argument[:methods].each do |method|
                content << "# defined by `delegate` to: :#{to_name}(#{to_type})"
                content << "def #{method}: (*untyped, **untyped) -> untyped"
              end
            else
              members = store[to_type.name.relative!.to_s].to_decl.members
              argument[:methods].each do |method|
                return_types = resolve_type_by_name(members, method)
                content << "# defined by `delegate` to: :#{to_name}(#{to_type})"
                case return_types
                when RBS::Types::Bases::Any, nil
                  content << "def #{method}: (*untyped, **untyped) -> untyped"
                else
                  binding.irb
                  content << "def #{method}: #{return_types.join(' | ')}"
                end
              end
            end
          end
        end

        store
      end
    end
  end
end
