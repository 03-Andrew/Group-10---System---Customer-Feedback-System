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

  def add_response_types do
    add_response(%{status: "Not Responded"})
    add_response(%{status: "Responded"})
  end


end
