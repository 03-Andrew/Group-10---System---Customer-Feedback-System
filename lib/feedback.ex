defmodule Feedback do
  alias Feedback.{Feedback, Customer}
  alias Customer

  def start do
    main_menu()
  end

  # Main menu
  def main_menu do
    IO.puts("╭───────────────────────────────────╮\n"<>
            "│          Feedback System          │\n"<>
            "╰───────────────────────────────────╯\n"<>
            "      (1) Log in                     \n"<>
            "      (2) Create Account             \n"<>
            "      (3) View Feedbacks as guest    \n"<>
            "      (4) Admin                      \n"<>
            "      (5) Exit                       \n")

    option = input("What do you want to do: ")
    |> String.to_integer()
    option(option)

  end

  defp option(1), do: login()

  defp option(2), do: create_account()

  defp option(3) do
    Feedback.get_all_feedbacks()
    main_menu()
  end

  defp option(4), do: System.halt(0)

  defp option(5), do: System.halt(0)

  defp option(_) do
    IO.puts("Invalid option")
    main_menu()
  end


  #Log in code
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

  #Create account
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
          _ ->
            if not String.match?(email, ~r/@/), do: IO.puts("Email has no '@'")
            if String.length(password) < 6, do: IO.puts("Password is less than 6")
            IO.puts("Failed to add customer")
        end
      _ ->
        IO.puts("Passwords do not match. Please try again.")
    end
  end

  #creating a feedback
  def create_feedback(id) do
    IO.puts("╭───────────────────────────────────╮")
    IO.puts("│          Add a feedback           │")
    IO.puts("╰───────────────────────────────────╯")
    feedback_data = get_feedback_data(id)
    Feedback.add_feedback(feedback_data)
  end

  defp get_feedback_data(id) do
    caption = input("Caption:\n  ")
    rate = input("Rate (0-5):\n  ")
    comment = input("Comment:\n  ")
    current_time_utc = DateTime.utc_now()
    current_time_philippine = Timex.shift(current_time_utc, hours: 8)

    %{rating: String.to_integer(rate),caption: caption,
      comments: comment,timestamp: current_time_philippine, customer_id: id
    }
  end

  # Customer_page
  def customer_page(customer) do
    IO.puts("╭───────────────────────────────────╮")
    IO.puts("│          Feedback System          │")
    IO.puts("╰───────────────────────────────────╯")
    IO.puts("      Hi #{customer.username}")
    IO.puts("               Menu:               ")
    IO.puts("      (1) Add Feedback             ")
    IO.puts("      (2) View All Feedbacks       ")
    IO.puts("      (3) View All my Feedbacks    ")
    IO.puts("      (4) Edit Feedback            ")
    IO.puts("      (5) Edit Customer Details    ")
    IO.puts("      (6) Log out                  ")
    IO.puts("                                   ")

    option = input("What do you want to do: ") |> String.to_integer()
    option(option, customer)
  end

  defp option(1, customer) do
    create_feedback(customer.id)
    |>customer_page()
  end

  defp option(2, customer) do
    Feedback.get_all_feedbacks()
    customer_page(customer)
  end

  defp option(3 , customer) do
    create_feedback(customer.id)
    |>customer_page()
  end

  defp option(4, customer) do
    create_feedback(customer.id)
    |>customer_page()
  end

  defp option(5, customer) do
    Feedback.get_feedbacks_by_customer(customer.id)
    customer_page(customer)
  end

  defp option(6, _customer), do: main_menu()

  defp option(_,customer) do
    IO.puts("Invalid option")
    customer_page(customer)
  end





  defp input(prompt) do
    IO.gets(prompt)
    |> String.trim
  end

  def get_all do
    Customer.get_all_customers()
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
  #   current_time_philippine = Timex.shift(current_time_utc, hours: 8)
  #   Feedback.add_feedback(%{rating: 4, caption: "My 2nd trip", comments: "It was so fun", timestamp: current_time_philippine, customer_id: 2});
  # end
  # def test_add_customer do
  #   Customer.add_customer(%{name: "Jay Maxey", username: "Max", email: "jay@email.com", password: "123456789"})
  # end
