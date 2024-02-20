defmodule Feedback.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :rating, :integer
      add :caption, :string
      add :comments, :string
      add :timestamp, :utc_datetime
      add :customer_id, references(:customer)
      timestamps()
    end
  end
end
