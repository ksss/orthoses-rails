begin
  require 'test_helper'
rescue LoadError
end

module ApplicationTest
  def test_check_typo_only(t)
    Orthoses::Rails::Application.new(
      Orthoses::Store.new(->{})
    ).call
  end
end
