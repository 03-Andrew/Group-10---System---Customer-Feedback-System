defmodule Feedback.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def up do
    execute "SET TIME ZONE 'Asia/Manila'"
    create table(:feedback) do
      add :rating, :integer
      add :caption, :string
      add :comments, :string
      add :response_status_id, references(:response_status)
      add :customer_id, references(:customer)
      timestamps()
    end
  end

  def down do
    drop table(:feedback)
    execute "RESET TIME ZONE"
  end
end
