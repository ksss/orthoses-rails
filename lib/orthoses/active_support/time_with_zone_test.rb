module TimeWithZoneTest
  def test_time_with_zone(t)
    store = Orthoses::ActiveSupport::TimeWithZone.new(->(){
      Orthoses::Utils.new_store.tap do |store|
        store["Time"] << "def defined_method: () -> void"
      end
    }).call
    store["ActiveSupport::TimeWithZone"].header = "class ActiveSupport::TimeWithZone"

    loader = RBS::EnvironmentLoader.new
    loader.add(library: 'date')
    env = RBS::Environment.from_loader(loader)
    RBS::Parser.parse_signature(<<~RBS).each do |decl|
      module ActiveSupport
        class TimeZone
        end
        class Duration
        end
      end
      module DateAndTime
        module Calculations
        end
        module Compatibility
        end
        module Zones
        end
      end
      module JSON
        class State
        end
      end
    RBS
      env << decl
    end
    RBS::Parser.parse_signature(store["Time"].to_rbs).each do |decl|
      env << decl
    end
    RBS::Parser.parse_signature(store["ActiveSupport::TimeWithZone"].to_rbs).each do |decl|
      env << decl
    end

    definetion_builder = RBS::DefinitionBuilder.new(env: env.resolve_type_names)
    begin
      unless definetion_builder.build_instance(TypeName("::Time")).methods[:defined_method].instance_of?(RBS::Definition::Method)
        t.error("#defined_method was dropped.")
      end
    rescue => err
      t.error("\n```rbs\n#{store["Time"].to_rbs}```\n#{err.inspect}")
    end
    begin
      definetion_builder.build_instance(TypeName("::ActiveSupport::TimeWithZone"))
    rescue => err
      t.error("\n```rbs\n#{store["ActiveSupport::TimeWithZone"].to_rbs}```\n#{err.inspect}")
    end
  end
end
