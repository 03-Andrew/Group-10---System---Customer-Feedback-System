defmodule Feedback.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customer) do
      add :name, :string
      add :username, :string
      add :email, :string, unique: true
      add :password, :string
    end
  end
end
