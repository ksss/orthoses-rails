module TimeWithZoneTest
  def test_time_with_zone(t)
    store = Orthoses::ActiveSupport::TimeWithZone.new(->(){
      Orthoses::Utils.new_store
    }).call
    store["ActiveSupport::TimeWithZone"].header = "class ActiveSupport::TimeWithZone"

    loader = RBS::EnvironmentLoader.new
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
      definetion_builder.build_instance(TypeName("::Time"))
      definetion_builder.build_instance(TypeName("::ActiveSupport::TimeWithZone"))
    rescue => err
      t.error("\n```rbs\n#{store["ActiveSupport::TimeWithZone"].to_rbs}```\n#{err.inspect}")
    end
  end
end
