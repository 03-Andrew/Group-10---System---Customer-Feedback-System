defmodule Feedback.Repo.Migrations.CreateResponseStatus do
  use Ecto.Migration
  def change do
    create table(:response_status) do
      add :status, :string
    end
  end
end
