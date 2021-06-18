defmodule MidtermServer.CurrencyPoller do
	use GenServer

	alias MidtermServer.CurrencyPoller.Impl

	@default_name __MODULE__

	def start_link(opts \\ []) do
		state = Keyword.get(opts, :state, %{})
		opts = Keyword.put_new(opts, :name, @default_name)

		GenServer.start_link(__MODULE__, state, opts)
	end

	def get_exchange_rate(server \\ @default_name, from, to) do
		GenServer.call(server, {:get_exchange_rate, from, to})
	end

	def get_currency_rates(server \\ @default_name, from) do
		GenServer.call(server, {:get_currency_rates, from})
	end

	def get_currency_id(server \\ @default_name, symbol) do
		GenServer.call(server, {:get_currency_id, symbol})
	end

	def get_currency(server \\ @default_name, id) do
		GenServer.call(server, {:get_currency, id})
	end

	@impl true
	def init(currencies) do
		MidtermServer.Finances.delete_currencies_no_longer_supported(currencies)
		currencies_in_db = MidtermServer.Finances.create_supported_currencies(currencies)
		state = %{
			id_to_currency_map: Impl.create_id_to_currency_map(currencies_in_db),
			currency_to_id_map: Impl.create_currency_to_id_map(currencies_in_db), 
			currency_pairs: Impl.create_currency_pairs(currencies), 
			exchange_map: Impl.create_currency_exchange_map(currencies),
			update_task_ref: nil
		}
		schedule_currency_update()
		{:ok, state}
	end

	@impl true
	def handle_info(:update_exchange_rates, %{update_task_ref: ref} = state) when is_reference(ref) do
		{:noreply, state}
	end

	@impl true
	def handle_info(:update_exchange_rates, %{update_task_ref: nil} = state) do
		task = Task.Supervisor.async_nolink(MidtermServer.TaskSupervisor, fn ->
			{:exchange_rates_updated, Impl.update_currency_pairs(state.currency_pairs, state.exchange_map)}
		end)

		{:noreply, %{state | update_task_ref: task.ref}}
	end

	@impl true
	def handle_info({ref, {:exchange_rates_updated, {exchange_map, update_list}}}, %{update_task_ref: ref} = state) do
		Impl.publish_list_of_updated_exchange_rates(update_list)
		{:noreply, %{state | exchange_map: exchange_map}}
	end

	@impl true
	def handle_info({:DOWN, ref, :process, _pid, _reason}, %{update_task_ref: ref} = state) do
		schedule_currency_update()
		{:noreply, %{state | update_task_ref: nil}}
	end

	@impl true
	def handle_call({:get_exchange_rate, from, to}, _from, state) do
		{:reply, state.exchange_map[from][to], state}
	end

	@impl true
	def handle_call({:get_currency_rates, from}, _from, state) do
		{:reply, state.exchange_map[from], state}
	end

	@impl true
	def handle_call({:get_currency_id, symbol}, _from, state) do
		{:reply, state.currency_to_id_map[symbol], state}
	end

	@impl true
	def handle_call({:get_currency, id}, _from, state) do
		{:reply, state.id_to_currency_map[id], state}
	end

	defp schedule_currency_update() do
		Process.send_after(self(), :update_exchange_rates, 1000)
	end
end