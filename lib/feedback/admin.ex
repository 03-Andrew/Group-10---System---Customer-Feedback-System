defmodule Feedback.Admin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feedback.{Admin, Repo}

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


  def add_admin(params \\ %{}) do
    %Admin{}
    |> changeset(params)
    |> Repo.insert()
  end

end
