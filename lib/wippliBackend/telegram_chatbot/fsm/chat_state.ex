defmodule TelegramBot.FlowFsm do
  alias WippliBackend.Wippli
  alias WippliBackend.Wippli.Participant
  alias TelegramBot.Cache
  alias WippliBackend.Wippli.Zone
  alias TelegramBot.Fsm
  alias WippliBackend.Accounts

  # Function purgatory
  #  defstate ask_value do
  #    defevent update_db(value), data: data do
  #      key = data[:to_edit]
  #      update_params = Map.new([{key, value}])
  #      Accounts.get_simple_user_by_telegram_id(data[:telegram_id]) |> Accounts.update_user(update_params)
  #      next_state(:polling, get_user_info(data[:telegram_id]))
  #    end
  #  end

  # Shows the possible events a single state could have


  @possible_events %{
    polling: [:goto_ask_value, :goto_zone_register],
    zone_register: [:ev_join_zone],
    ask_password: [:ev_join_zone_with_pass],
    ask_value: [:ev_update_user],
    all: [:return_to_polling]
  }

  def new(telegram_id) do
    %Fsm{state: :polling, data: get_user_info(telegram_id)}
  end

  def get_events_by_arity(arity) do
    function_arity_map = __MODULE__.__info__(:functions)
    Enum.filter(get_all_events(), fn(event) -> function_arity_map[event] == arity + 1 end)
  end

  def get_all_events() do
    @possible_events
    |> Map.values
    |> List.flatten
  end

  def possible_events_from_state(state) do
    @possible_events[state]
  end

  defp get_user_info(telegram_id) do
    %{telegram_id: telegram_id, db_id: Cache.get_value(:telegram2dbid, telegram_id)}
  end

  def next_state(fsm, new_state) do
    Map.put(fsm, :state, new_state)
  end

  def next_state(fsm, new_state, {key, value} = params) do
    Map.put(fsm, key, value) |> next_state(new_state)
  end

  def next_state(fsm, new_state, params) do
      Map.merge(fsm, params) |> next_state(new_state)
  end

  defp join_zone_db(zone_id, user_id, password) do
    with {:ok, %Participant{}} <- Wippli.join_zone(zone_id,user_id, password) do
      %{message: "Successfully joined zone #{to_string(zone_id)}", zone: zone_id}
    else
      _ ->
        {:message,"Error while trying to join zone"}
    end
  end

  #Polling state
  def goto_zone_register(fsm) do
    next_state(fsm, :zone_register)
  end

  def ev_join_zone(fsm, zone_id)  do
    with %Zone{} = zone <- Wippli.get_simple_zone!(zone_id) do
      if zone.password == nil do
        next_state(fsm, :polling, join_zone_db(zone_id, fsm.data[:db_id], nil))
      else
        next_state(fsm, :ask_password, %{to_edit: zone_id, message: "This zone has a password!"})
      end
    else
      _ ->
        next_state(fsm, :polling, {:message, "Zone doesn't exist"})
    end
  end


  #Ask Password state
  def ev_join_zone_with_pass(%Fsm{to_edit: zone_id} = fsm, password)  do
    with %Zone{} = zone <- Wippli.get_simple_zone!(zone_id) do
      next_state(fsm, :polling, join_zone_db(zone_id, fsm.data[:db_id], password))
    end
  end

  #All States, resets the fsm
  def return_to_polling(fsm) do
    fsm2 = new(fsm.data[:telegram_id])
    next_state(fsm2, :polling)
  end


  # Edit user info state
  def goto_ask_value(fsm, to_edit) do
    next_state(fsm, :ask_value, {:to_edit, to_edit})
  end

  def ev_update_user(fsm, to_edit) do
    next_state(fsm, :polling, {:message,  String.capitalize(to_string(to_edit)) <> " correctly updated"})
  end
end
