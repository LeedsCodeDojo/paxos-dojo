defmodule Paxos.Learner do
    use GenServer
    require Logger

    alias Paxos.Messenger
    alias Paxos.StateStore

    @timer 100

    ## Public API

    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    ## GenServer Callbacks below

    # If we get restarted because we get an error while retrieving a message,
    # we want to recover our state from the StateStore.
    def init(_args) do
      state = StateStore.retrieve
      {:ok, state, @timer}
    end

    # This gets called each time @timer counts down (in milliseconds).
    #
    def handle_info(:timeout, state) do
      Logger.debug fn -> "State: #{inspect state}" end

      {:ok, %{"type" => "accepted", "timePeriod" => time_period, "by" => by, "value" => value}} = Messenger.get
      Logger.debug fn -> "time: #{inspect time_period}, by: #{inspect by}, value: #{inspect value}" end

      Enum.each(state, fn(message) ->
        case message do
          {^time_period, found_by} when found_by != by ->
            Logger.info fn -> "Learned value: #{inspect value} from #{inspect found_by} and #{inspect by}" end
            {:ok, value}
          _ ->
            :nothing_learned
        end
      end)

      new_state = case Enum.member?(state, {time_period, by}) do
        true -> state
        false -> [{time_period, by} | state]
      end
        

      {:noreply, new_state, @timer}
    end

    # If we crash, the supervisor will call our 'terminate' function to let us
    # do any tidying up.  In this case, we'll store our current state in the StateStore.
    def terminate(_reason, state) do
      StateStore.store(state)
      :ok
    end
end
