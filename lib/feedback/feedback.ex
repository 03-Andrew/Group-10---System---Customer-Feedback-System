defmodule Feedback.Feedback do
  alias Feedback.{Customer ,Feedback, Repo, Response}
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query


  schema "feedback" do
    field :rating, :integer
    field :caption, :string
    field :comments, :string
    belongs_to :response_status, Response
    belongs_to :customer, Customer
    timestamps()
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:rating, :caption, :comments, :response_status_id, :customer_id])
    |> validate_number(:rating, greater_than: 0, less_than_or_equal_to: 5)
    |> validate_length(:comments, max: 255)
  end

  # Create
  def add_feedback(params \\ %{}) do
    case %Feedback{}
        |> Feedback.changeset(params)
        |> Repo.insert() do
      {:ok, _feedback} ->
        IO.puts("Successfully Added")
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # View
  def get_all_feedbacks do
    Feedback
    |> Repo.all()
    |> Repo.preload([:customer, :response_status])
    |> Enum.each(&print_feedback/1)
  end

  def get_feedbacks_by_customer(customer_id) do
    case Feedback |> where([f], f.customer_id == ^customer_id) |> Repo.all() do
      [] ->
        IO.puts("No feedbacks")
      feedbacks ->
        feedbacks
        |> Repo.preload([:customer, :response_status])
        |> Enum.each(&print_feedback/1)
    end
  end

  def get_feedbacks_by_response(response_id) do
    case Feedback
        |> where([f], f.response_status_id == ^response_id)
        |> Repo.all() do
      [] ->
        :no_feedbacks
      feedbacks ->
        feedbacks
        |> Repo.preload([:customer, :response_status])
        |> Enum.each(&print_feedback/1)
    end
  end



  defp print_feedback(feedback) do
    formatted_feedback = format_feedback(feedback)
    IO.puts(formatted_feedback)
  end

  defp format_feedback(feedback) do
    customer = feedback.customer
    status = feedback.response_status
    rating_stars = String.duplicate("★ ", feedback.rating)
    rating_spaces = String.duplicate("☆ ", 5 - feedback.rating)

    caption = "#{feedback.caption || "No Caption"}"
    by = "#{customer.username}"
    rating = "#{rating_stars}#{rating_spaces}"
    comment = "#{feedback.comments || "No Comment"}"

    "| ID: #{feedback.id} | Caption: #{caption} | By: #{by} | Rating: #{rating} (#{feedback.rating}/5) | Inserted At: #{feedback.inserted_at} | Response: #{status.status} |\n| Comment: #{comment} \n"
  end

  # Edit
  @spec edit_feedback_field(any(), any(), any()) :: <<_::160>> | {:error} | {:error, <<_::168>>}
  def edit_feedback_field(feedback_id, field, value) do
    feedback = Repo.get(Feedback, feedback_id)
    case feedback do
      nil ->
        {:error, "Feedback id not found"}
      _ ->
        changeset = Feedback.changeset(feedback, %{field => value})

        case Repo.update(changeset) do
          {:ok, _updated_feedback} ->
            if field == :response_status_id do
              IO.puts("Responded to feedback")
            else
              IO.puts("Successfully edited")
            end
          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  #Delete
  def delete_feedback_by_id(feedback_id, customer_id) do
    case Repo.get(Feedback, feedback_id) do
      %Feedback{} = feedback when customer_id == feedback.customer_id ->
        case Repo.delete(feedback) do
          {:ok, _deleted_feedback} ->
            IO.puts("Feedback with ID #{feedback_id} deleted successfully")
          {:error, _changeset} ->
            IO.puts("Failed to delete feedback")
        end

      %Feedback{} = _feedback ->
        IO.puts("User does not own the feedback with ID #{feedback_id}")

      nil ->
        IO.puts("Feedback with ID #{feedback_id} not found")
    end
  end

  def delete_feedback_by_customer_id(customer_id) do
    feedbacks = Repo.all(Feedback)
    feedbacks_to_delete = Enum.filter(feedbacks, fn feedback -> feedback.customer_id == customer_id end)

    if Enum.empty?(feedbacks_to_delete) do
      IO.puts("No feedback found for customer with ID #{customer_id}")
    else
      Enum.each(feedbacks_to_delete, fn feedback ->
        case Repo.delete(feedback) do
          {:ok, _deleted_feedback} ->
            IO.puts("Feedback with ID #{feedback.id} deleted successfully")
          {:error, _changeset} ->
            IO.puts("Failed to delete feedback with ID #{feedback.id}")
        end
      end)
    end
  end


  def truncate_feedback_table do
    Feedback
    |> Repo.delete_all()
  end
end
