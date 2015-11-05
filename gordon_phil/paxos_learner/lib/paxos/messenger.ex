defmodule Paxos.Messenger do

    use GenServer

    @base_url "http://paxos.leedscodedojo.org.uk/live/l/gp"

    ## Public API

    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    @doc """
    Get a message from the queue.

    Returns a map (decoded from the remote JSON)
    """
    def get do
      GenServer.call(__MODULE__, :get)
    end

    def post(request) do
      GenServer.call(__MODULE__, {:post, request})
    end


    ## GenServer Callbacks below

    def init(_args) do

      state = %{}
      {:ok, state}
    end

    def handle_call(:get, {from_pid, from_ref}, state) do
      # not ideal
      pid_string = :erlang.pid_to_list(from_pid)
        |> to_string
        |> String.replace("<", "")
        |> String.replace(">", "")

      url = "#{@base_url}-#{pid_string}"

      {:ok, body} = HTTPoison.get!(url, timeout: 15000, recv_timeout: 15000) |> Map.from_struct |> Map.fetch(:body)
      response = body |> JSON.decode
      {:reply, response, state}
    end

    def handle_call({:post, req}, {from_pid, from_ref}, state) do
      # not ideal
      pid_string = :erlang.pid_to_list(from_pid)
        |> to_string
        |> String.replace("<", "")
        |> String.replace(">", "")

      url = "#{@base_url}-#{pid_string}"

      json_body = req |> JSON.encode
      HTTPoison.post!(url, %{"Content-Type" => "application/json"}, json_body)
      {:reply, :ok, state}
    end

end
