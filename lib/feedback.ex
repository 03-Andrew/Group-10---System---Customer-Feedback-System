defmodule Feedback do
  alias Feedback.Customer
  alias Feedback.{Feedback, Customer, Admin, Repo}

  def start do
    main_menu()
  end

  defp menu_print1 do
    IO.puts("╭───────────────────────────────────╮\n"<>
            "│          Feedback System          │\n"<>
            "╰───────────────────────────────────╯\n"<>
            "      (1) Log in                     \n"<>
            "      (2) Create Account             \n"<>
            "      (3) View Feedbacks as guest    \n"<>
            "      (4) Admin                      \n"<>
            "      (5) Exit                       \n")
  end

  defp customer_print(customer) do
    IO.puts("╭───────────────────────────────────╮\n"<>
            "│          Feedback System          │\n"<>
            "╰───────────────────────────────────╯\n"<>
            "      Hi #{customer.username}        \n"<>
            "               Menu:                 \n"<>
            "      (1) Add Feedback               \n"<>
            "      (2) View All Feedbacks         \n"<>
            "      (3) View All my Feedbacks      \n"<>
            "      (4) Edit Feedback              \n"<>
            "      (5) Edit Customer Details      \n"<>
            "      (6) Delete Feedback            \n"<>
            "      (7) Log out                    \n"<>
            "                                      ")
  end
  defp admin_print do
    IO.puts("╭───────────────────────────────────╮\n"<>
            "│              Admin                │\n"<>
            "╰───────────────────────────────────╯\n"<>
            "      (1) view all customers         \n"<>
            "      (2) view all feedbacks         \n"<>
            "      (3) respond to feedbacks       \n"<>
            "      (4) Back to menu               \n")

  end

  defp feedback_print do
    IO.puts("╭───────────────────────────────────╮\n"<>
            "│          Add a feedback           │\n"<>
            "╰───────────────────────────────────╯\n")

  end

  # --------------------------------------------------------------------------------------------------------
  # ---------------------------------------------Main Menu-----------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def main_menu do
    menu_print1()
    option = input("What do you want to do: ")
    |> String.to_integer()
    option(option)
  end

  defp option(1), do: login() # (1) Log in

  defp option(2), do: create_account() # (2) Create Account

  defp option(3) do
    Feedback.get_all_feedbacks() # (3) View Feedbacks as guest
    option_page()
  end

  defp option(4), do: admin_login() # (4) Admin

  defp option(5), do: :ok

  defp option(_) do
    IO.puts("Invalid option")
    main_menu()
  end

  # --------------------------------------------------------------------------------------------------------
  # ---------------------------------------------Log in-----------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def login do
    email =
      input("Email: ")
      |> get_customer_by_email()

    case email do
      nil ->
        IO.puts("User not found.")
      customer ->
        attempt_login(customer)
    end
  end

  defp get_customer_by_email(email) do
    Customer.get_customer_by_email(email)
  end

  defp attempt_login(nil) do
    IO.puts("User not found.")
  end

  defp attempt_login(%Customer{} = customer) do
    password = input("Password: ")
    if password == customer.password do
      IO.puts("Login successful.")
      customer_page(customer)
    else
      IO.puts("Invalid password.")
    end
  end

  # --------------------------------------------------------------------------------------------------------
  # -----------------------------------------Create Account-------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def create_account do
    IO.puts("Enter user details:")
    name = input("Name: ")
    username = input("UserName: ")
    email = input("Email: ")
    password = input("Password: ")
    confirm_pass = input("Confirm Pass: ")

    case password do
      ^confirm_pass ->
        case Customer.add_customer(%{name: name, username: username, email: email, password: password}) do
          {:ok, _user} ->
            IO.puts("User created successfully.")
            main_menu()
          _ ->
            if not String.match?(email, ~r/@/), do: IO.puts("Email has no '@'")
            if String.length(password) < 6, do: IO.puts("Password is less than 6")
            IO.puts("Failed to add customer")
        end
      _ ->
        IO.puts("Passwords do not match. Please try again.")
    end
  end

  # --------------------------------------------------------------------------------------------------------
  # ----------------------------------------------Admin-----------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def admin_login do
    username = input("Username: ")
    pass = input("Password: ")
    log_in_admin(username, pass)
  end

  defp log_in_admin(username, password) do
    case Repo.get_by(Admin, name: username, password: password) do
      %Admin{} = admin ->
        {:ok, admin}
        IO.puts("Logged in Successfully\n")
        admin_page()
      _ ->
        IO.puts("Invalid credentials")
        main_menu()
    end
  end


  def admin_page do
    admin_print()
    admin_op(input("Enter choice: "))
  end

  defp admin_op("1") do
    Customer.get_all_customers
    a_option_page()
  end

  defp admin_op("2") do
    Feedback.get_all_feedbacks()
    a_option_page()
  end

  defp admin_op("3") do
    Feedback.get_feedbacks_by_response(1)
    id = input("Enter feedback ID to respond to: ") |> String.to_integer()
    Feedback.edit_feedback_field(id, :response_status_id, 2)
    a_option_page()
  end

  defp admin_op("4"), do: main_menu()
  defp admin_op(_) do
    IO.puts("Invalid input")
    admin_page()
  end


  def a_option_page() do
    op = input("   (1) Admin Page   (2) Back to Menu\n")
    a_option(op)
  end

  defp a_option("1"), do: admin_page()
  defp a_option(_), do: main_menu()

  # --------------------------------------------------------------------------------------------------------
  # ----------------------------------------Create Feedback-------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def create_feedback(id) do
    feedback_print()
    feedback_data = get_feedback_data(id)
    Feedback.add_feedback(feedback_data)
  end

  defp get_feedback_data(id) do
    caption = input("Caption:\n  ")
    rate = input("Rate (0-5):\n  ")
    comment = input("Comment:\n  ")
    %{rating: String.to_integer(rate),caption: caption, comments: comment, responsestatus: "Not responded", customer_id: id}
  end

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------Edit Feedback-------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  def edit_feedback() do
    feedback_id = input("Enter feedback id: ") |> String.to_integer()
    IO.puts("Field to edit: \n   (1) Caption\n   (2) Rating\n   (3) Comment")

    op = edit_field(input("")|>String.to_integer())
    val = input("Enter new value: ")
    val =
    if op == :rating do
      val |> String.to_integer()
    else
      val
    end
    Feedback.edit_feedback_field(feedback_id, op, val)
  end

  @spec edit_field(1 | 2 | 3) :: :caption | :comment | :rating
  def edit_field(1), do: :caption
  def edit_field(2), do: :rating
  def edit_field(3), do: :comment


  # --------------------------------------------------------------------------------------------------------
  # ----------------------------------------Edit Customer-------------------------------------------------
  # --------------------------------------------------------------------------------------------------------


  def edit_customer_deets(customer) do
    IO.puts("Field to edit: \n   (1) Name\n   (2) Username\n   (3) Email\n   (4) Password")
    op = c_edit_field(input("") |> String.to_integer())
    handle_edit_operation(customer, op)
  end

  defp handle_edit_operation(customer, :password) do
    old_pass = input("Enter old password: ")
    new_pass = input("Enter new password: ")
    Customer.change_password(customer, old_pass, new_pass)
  end

  defp handle_edit_operation(customer, field) do
    val = input("Enter new value: ")
    Customer.edit_customer_field(customer, field, val)
  end

  defp c_edit_field(1), do: :name
  defp c_edit_field(2), do: :username
  defp c_edit_field(3), do: :email
  defp c_edit_field(4), do: :password
  defp c_edit_field(_), do: :ok
  # --------------------------------------------------------------------------------------------------------
  # ----------------------------------------Customer Page---------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def customer_page(customer) do
    customer_print(customer)
    option = input("What do you want to do: ") |> String.to_integer()
    option(option, customer)
  end

  defp option(1, customer) do
    create_feedback(customer.id)
    option_page(customer)
  end

  defp option(2, customer) do
    Feedback.get_all_feedbacks()
    option_page(customer)
  end

  defp option(3 , customer) do
    Feedback.get_feedbacks_by_customer(customer.id)
    option_page(customer)
  end

  defp option(4, customer) do
    Feedback.get_feedbacks_by_customer(customer.id)
    edit_feedback()
    option_page(customer)
  end

  defp option(5, customer) do
    edit_customer_deets(customer)
    option_page(customer)
  end

  defp option(6, customer) do
    id = input("Enter Feedback id to delete: ") |> String.to_integer()
    Feedback.delete_feedback_by_id(id, customer.id)
    option_page(customer)
  end

  defp option(_,customer) do
    IO.puts("Invalid option")
    customer_page(customer)
  end



  def option_page do
    op = input("   (1) Back to menu\n")
    if op == "1", do: main_menu()
  end

  def option_page(customer) do
    op = input("   (1) Back to account   (2) Back to menu\n")
    |> String.to_integer()
    option2(op, customer)
  end

  defp option2(1, customer) do
    customer_page(customer)
  end
  defp option2(2, _customer) do
    main_menu()
  end
  defp option2(_, customer) do
    IO.puts("Invalid input")
    customer_page(customer)
  end

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------Edit Customer-------------------------------------------------
  # --------------------------------------------------------------------------------------------------------
  def edit_customer() do
    feedback_id = input("Enter feedback id: ") |> String.to_integer()
    IO.puts("Field to edit: \n   (1) Caption\n   (2) Rating\n   (3) Comment")

    op = edit_field(input("")|>String.to_integer())
    val = input("Enter new value: ")
    val =
    if op == :rating do
      val |> String.to_integer()
    else
      val
    end
    Feedback.edit_feedback_field(feedback_id, op, val)
    IO.puts("Edited feedback")
  end





  def edit_c_field(1) do
    :name
  end

  def edit_c_field(2) do
    :username
  end

  def edit_c_field(3) do
    :email
  end

  defp input(prompt) do
    IO.gets(prompt)
    |> String.trim
  end
end

  # def log_in do
  #   email = input("Email: ")
  #   password = input("Password: ")
  #   customer = Customer.get_customer_by_email(email)
  #   case customer do
  #     nil ->
  #       IO.puts("User not found.")
  #     %Customer{} = customer ->
  #       if password == customer.password do
  #         IO.puts("Login successful.")
  #         customer_page(customer)
  #       else
  #         IO.puts("Invalid password.")
  #       end
  #   end
  # end
  #  def test_add_feedback do
  #   current_time_utc = DateTime.utc_now()
  #   current_time_philippine = Timex.shift(current_time_utc, hours: 😎
  #   Feedback.add_feedback(%{rating: 4, caption: "My 2nd trip", comments: "It was so fun", timestamp: current_time_philippine, customer_id: 2});
  # end
  # def test_add_customer do
  #   Customer.add_customer(%{name: "Jay Maxey", username: "Max", email: "jay@email.com", password: "123456789"})
  # end
