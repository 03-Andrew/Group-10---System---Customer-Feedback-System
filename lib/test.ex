defmodule Test do
  alias Feedback.{Feedback, Customer, Response}

  def test_add_customer do
    Customer.add_customer(%{name: "Maxey", username: "Bob", email: "bob@email.com", password: "123456789"})
  end
  def test_add_feedback do
    Feedback.add_feedback(%{rating: 4, caption: "My 2nd trip", comments: "It was so fun", response_status_id: 1, customer_id: 1});
  end

  def test_add_response do
    Response.add_response(%{status: "Not Responded"})
  end

  def test_get_feedback_by do
    Feedback.get_feedbacks_by_customer(1)
  end

  def get_all_feedback do
    Feedback.get_all_feedbacks()
  end

  def test_edit_feedback do
    Feedback.edit_feedback_field(1, :response_status_id, 2)
  end

  def test_delete do
    Feedback.delete_feedback_by_id(2,1)
  end

  def test_get_by_id do
    Customer.get_customer_by_id(1)
  end
end
