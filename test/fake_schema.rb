module ::ActiveRecord
  module AttributeMethods::PrimaryKey::ClassMethods
    def get_primary_key(base_name)
      "id"
    end
  end

  module ModelSchema::ClassMethods
    FakeColumn = Struct.new(:type, :name, :null, keyword_init: true)

    def load_schema
    end

    def columns_hash
      {
        id: FakeColumn.new(
          name: :id,
          null: false,
          type: :integer,
        ),
        name: FakeColumn.new(
          name: :name,
          null: false,
          type: :string,
        ),
        confirmed: FakeColumn.new(
          name: :confirmed,
          null: true,
          type: :boolean,
        ),
      }
    end
  end
end