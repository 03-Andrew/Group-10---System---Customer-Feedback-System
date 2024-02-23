defmodule Feedback.Repo.Migrations.CreateAdmin do
  use Ecto.Migration

  def change do
    create table(:admin) do
      add :name, :string
      add :email, :string, unique: true
      add :password, :string
    end
  end
end
