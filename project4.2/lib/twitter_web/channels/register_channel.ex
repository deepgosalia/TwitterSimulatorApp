defmodule TwitterWeb.RegisterChannel do
  use TwitterWeb, :channel

  def join("register:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end


  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end


  def handle_in("login", payload, socket) do

    {_,usr} = Map.fetch(payload, "usr")
    {_,pswd} = Map.fetch(payload,"pswd")

    usr = Integer.parse(usr)
    pswd = Integer.parse(pswd)

    # [{_,data}] = :ets.lookup(:usrProcessTable, uid)
    # p = Enum.at(data, 0)
    if :ets.member(:usrProcessTable, usr) do
      [{_,data}] = :ets.lookup(:usrProcessTable, usr)
      p = Enum.at(data, 0)
      if p !=pswd do
        push(socket, "login", %{message: "Invalid"})
      end

    else
      User.login(usr,pswd)
      push(socket, "login", %{message: "User Logged in"})
    end


    #User.login(usr,pswd)
    #broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("register", payload, socket) do

    #broadcast socket, "shout", payload
    {:noreply, socket}
  end


  defp authorized?(_payload) do
    true
  end
end
