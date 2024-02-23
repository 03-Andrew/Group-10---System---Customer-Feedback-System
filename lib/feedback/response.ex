defmodule Feedback.Response do
  alias Feedback.{Response, Repo}
  use Ecto.Schema
  import Ecto.Changeset

  schema "response_status" do
    field :status, :string
  end

  @doc false
  def changeset(response_status, attrs) do
    response_status
    |> cast(attrs, [:status])
    |> validate_required([:status])

  end

  def add_response(params \\ %{}) do
    %Response{}
    |> changeset(params)
    |> Repo.insert()
  end

end
