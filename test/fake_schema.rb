FakeColumn = Struct.new(:type, :name, :null, keyword_init: true)
def FakeColumn.attribute_types
  {
    "id" => FakeColumn.new(
      name: :id,
      null: false,
      type: :integer,
    ),
    "name" => FakeColumn.new(
      name: :name,
      null: false,
      type: :string,
    ),
    "confirmed" => FakeColumn.new(
      name: :confirmed,
      null: true,
      type: :boolean,
    ),
  }
end

module ::ActiveRecord
  module AttributeMethods::PrimaryKey::ClassMethods
    def get_primary_key(base_name)
      "id"
    end
  end

  module ModelSchema::ClassMethods

    def attribute_types
      FakeColumn.attribute_types
    end
  end
end

module ActiveModel
  module AttributeRegistration
    module ClassMethods
      def attribute_types
        FakeColumn.attribute_types
      end
    end
  end
end
