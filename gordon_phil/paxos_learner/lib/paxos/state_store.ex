defmodule Paxos.StateStore do
    use GenServer

    ## Public API

    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def store(value) do
      GenServer.cast(__MODULE__, {:store, value})
    end

    def retrieve do
      GenServer.call(__MODULE__, :retrieve)
    end

    ## GenServer Callbacks below

    def init(_args) do
      state = []
      {:ok, state}
    end

    def handle_call(:retrieve, _from, state) do
      {:reply, state, state}
    end

    def handle_cast({:store, value}, _state) do
      {:noreply, value}
    end
end
