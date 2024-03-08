defmodule Feedback.Customer do
  alias Feedback.{Customer, Repo}
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "customer" do
    field :name, :string
    field :username, :string
    field :email, :string
    field :password, :string
  end


  @doc false
  def changeset(customer, params) do
    customer
    |> cast(params, [:name, :username, :email, :password])
    |> validate_required([:name, :email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:password, min: 6)
  end


  def add_customer(params \\ %{}) do
    %Customer{}
    |> Customer.changeset(params)
    |> Repo.insert()
  end

  def delete_customer_by_id(customer_id) do
    case Repo.get(Customer, customer_id) do
      nil ->
        {:error, "Customer not found"}
      customer ->
        Repo.delete(customer)
        {:ok, "Customer deleted successfully"}
    end
  end


  def edit_customer_field(customer, field, value) do
    case customer do
      nil ->
        {:error, "Customer not found"}
      _ ->
        changeset = Customer.changeset(customer, %{field => value})

        case Repo.update(changeset) do
          {:ok, _updated_customer} ->
            IO.puts("Edited field")
          {:error, _changeset} ->
            if not String.match?(value, ~r/@/), do: IO.puts("Email has no '@'")
        end
    end
  end

  def change_password(customer, old_pass, new_pass) do
    case old_pass == customer.password do
      true ->
          case customer do
        nil ->
          {:error, "Customer not found"}
        _ ->
          changeset = Customer.changeset(customer, %{:password => new_pass})

          case Repo.update(changeset) do
            {:ok, _updated_customer} ->
              IO.puts("Password Changed")
            {:error, _changeset} ->
              IO.puts("Error")
          end
      end
      false ->
        {:error, "Incorrect old password"}
        IO.puts("Incorrct Password")
    end
  end



  def get_all_customers do
    Repo.transaction(fn ->
      Customer
      |> Repo.stream()
      |> Stream.each(&print_customer/1)
      |> Stream.run()
    end)
  end


  defp print_customer(customer) do
    formatted_customer = format_customer(customer)
    IO.puts(formatted_customer)
  end

  defp format_customer(customer) do
    " \n|ID: #{customer.id} |Name: #{customer.name} |Username: #{customer.username} |Email: #{customer.email} |"
  end


  def get_customer_by_email(email) do
    from(c in Customer, where: c.email == ^email) |> Repo.one()
  end

  def get_customer_email(email) do
    customer_records = from(c in Customer, where: c.email == ^email) |> Repo.all()
    customer_count = Enum.count(customer_records)
    customer_count
  end

  def get_customer_by_id(id) do
    from(c in Customer, where: c.id == ^id) |> Repo.one()
  end
end
