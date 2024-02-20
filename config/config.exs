import Config

config :feedback, Feedback.Repo,
  database: "feedback_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  loggers: [{Ecto.LogEntry, :log, [:error]}]

config :logger, level: :info
config :ecto, loggers: [{Ecto.LogEntry, :log, :error}]


config :feedback, ecto_repos: [Feedback.Repo]
