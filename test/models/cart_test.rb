require 'test_helper'

class CartTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :products
  test "Add unique products" do
    cart = Cart.create
    cart.add_product(products(:ruby).id).save!
    cart.add_product(products(:python).id).save!
    assert_equal 2, cart.line_items.size
    assert_equal (products(:ruby).price + products(:python).price), cart.total_price
  end
  
  test "Add duplicate products" do
    cart = Cart.create
    cart.add_product(products(:python).id).save!
    cart.add_product(cart.line_items.first.product.id).save!
    # Reload to reflect database change
    cart.reload 
    assert_equal (products(:python).price * 2), cart.total_price
    assert_equal 1, cart.line_items.size
  end
end
