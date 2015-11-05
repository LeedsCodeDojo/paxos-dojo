defmodule Paxos do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Paxos.StateStore, []),
      worker(Paxos.Messenger, []),
      worker(Paxos.Learner, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, max_restarts: 900, max_seconds: 300, name: Paxos.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
