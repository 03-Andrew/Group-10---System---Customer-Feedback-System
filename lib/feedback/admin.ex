defmodule Feedback.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admin" do
    field :name, :string
    field :email, :string
    field :password, :string
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
  end
end
