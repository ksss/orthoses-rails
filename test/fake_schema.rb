FakeColumn = Struct.new(:type, :name, :null, keyword_init: true)
def FakeColumn.columns_hash
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
    def load_schema
    end

    def columns_hash
      FakeColumn.columns_hash
    end

    def attribute_types
      FakeColumn.columns_hash
    end

    def table_exists?
      true
    end
  end
end

# for rails v7.2
module ActiveModel
  module AttributeRegistration
    module ClassMethods
      def attribute_types
        FakeColumn.columns_hash
      end
    end
  end
end
