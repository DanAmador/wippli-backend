defmodule TelegramBot.FsmServer do
  alias TelegramBot.FlowFsm
  alias TelegramBot.Cache
  alias WippliBackend.Accounts
  use ExActor.GenServer
  @null_arity_events [:return_to_polling, :update_zone_for_user]
  @one_arity_events [:start_polling, :edit_info, :join_zone, :update_db]


  defstart start_link, do: initial_state(FlowFsm.new)

  def create(id) do
    {:ok, pid} = start_link()
    Cache.get_or_create(:id2pid, id, pid)
    user = Accounts.get_simple_user_by_telegram_id(id)
    Cache.get_or_create(:telegram2dbid, id, user.id)
    pid
  end

  for event <- @null_arity_events do
    defcast unquote(event), state: fsm do
      FlowFsm.unquote(event)(fsm)
      |> new_state
    end
  end
  for event <- @one_arity_events do
    defcall unquote(event)(data), state: fsm do
      FlowFsm.unquote(event)(fsm, data)
      |> reply
    end
  end

  defcall state, state: fsm, do: reply(FlowFsm.state(fsm))
  defcall data, state: fsm, do: reply(FlowFsm.data(fsm))
end


defmodule TelegramBot.FlowFsm do
  use Fsm, initial_state: :start
  alias WippliBackend.Accounts
  alias WippliBackend.Wippli
  alias TelegramBot.Cache


  defp get_user_info(telegram_id) do
    %{telegram_id: telegram_id, db_id: Cache.get(:telegram2dbid, telegram_id)}
  end

  #Global error handler to return to the default state 
  defevent return_to_polling, data: data do
    next_state(:polling, get_user_info(data[:telegram_id]))
  end

  defstate start do
    defevent start_polling(id) do
      next_state(:polling, get_user_info(id))
    end
  end

  defstate polling do
    defevent edit_info(key), data: data do
      new_data = data |> Map.put_new(:to_edit, [{String.to_atom(key)}] )
      next_state(:ask_value, new_data)
    end

    defevent join_zone(zone_id), data: data do
      zone =  Wippli.get_simple_zone!(zone_id)
      new_data = data |> Map.put_new(:to_join, [{zone_id}])

      case zone.password do
        nil -> next_state(:zone_register, new_data)
        _ -> next_state(:ask_password, data |> Map.put_new(:to_join, [{zone_id,nil}]))
      end
    end
  end


  defstate ask_value do
    defevent update_db(value), data: data do
      key = data[:to_edit]
      update_params = Map.new([{key, value}])
      Accounts.get_simple_user_by_telegram_id(data[:telegram_id]) |> Accounts.update_user(update_params)
      next_state(:polling, get_user_info(data[:telegram_id]))
    end
  end

  defstate zone_register  do
    defevent update_zone_for_user(), data: data  do
      {id, pass} = data[:to_join]
      Wippli.join_zone(id,data[:db_id], pass)
      next_state(:polling, get_user_info(data[:telegram_id]))
    end
  end
end
