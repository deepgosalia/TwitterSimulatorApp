defmodule TwitterWeb.RoomChannel do
  use TwitterWeb, :channel

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      #send(self(), :after)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after, socket) do
    msg = TwitterApp.retData("deep")
    push(socket, "shout", %{name: "deep", message: msg})
    {:noreply,socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end


  def handle_in("shout", payload, socket) do
    {_,name} = Map.fetch(payload, "name")
    {_,message} = Map.fetch(payload,"message")
    l=TwitterApp.addData(name,message)
    msg = TwitterApp.retData(name)
    push(socket, "shout", %{name: name, message: msg})
    #:ets.insert(:msgTable,{payload.name,payload.message})
    #broadcast socket, "shout", payload
    {:noreply, socket}
  end


  def handle_in("tweet", payload, socket) do
    {_,message} = Map.fetch(payload,"message")
    [{_,data}] = :ets.lookup(:eid, "curr_user")
    User.send_message(data,message)
    push(socket, "tweet", %{message: message, id: "0"})
    {:noreply, socket}
  end


  def handle_in("subscribe", payload, socket) do

    {_,message} = Map.fetch(payload,"message")
    temp = message
    [{_,data}] = :ets.lookup(:eid, "curr_user")


    sub=:crypto.hash(:sha, message) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)


   if :ets.member(:usrProcessTable, sub) do
    result=Engine.subscribe(data,sub)
    push(socket, "subscribe", %{message: temp})
  else
    push(socket, "subscribe", %{message: "notfound"})
   end


    # result=Engine.subscribe(data,sub)

    # if result == :false do
    #   push(socket, "subscribe", %{message: "notfound"})
    # else
    #   push(socket, "subscribe", %{message: temp})
    # end

    {:noreply, socket}
  end


  def handle_in("logout", payload, socket) do
    :ets.delete(:eid,"curr_user")
    push(socket,"logout",%{message: "User Logged out"})
    {:noreply, socket}
  end



  def handle_in("query", payload, socket) do
    {_,message} = Map.fetch(payload,"message")
    q=String.first(message)
    if q == "#" do
      [{_,msg}] = :ets.lookup(:hashtag_table,message)
      Enum.each(msg, fn(m)->
        [{_,[mtext,from,type]}] = :ets.lookup(:msgTable,m)
        [{_,fr}] = :ets.lookup(:nameToId, from)
        mtext = "From #{fr}: #{mtext}"
        push(socket, "query", %{message: mtext})
      end)
    else
      #search for subscribed users


      sub=:crypto.hash(:sha, message) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)

      [{_,usr}] = :ets.lookup(:eid, "curr_user")
      [{_,msg}] = :ets.lookup(:send_table,usr)
        Enum.each(msg, fn(m) ->
          [{_,[message,from,type]}] = :ets.lookup(:msgTable,m)
          if from == sub do
            push(socket, "query", %{message: message})
          end

        end)

    end
    {:noreply, socket}
  end



  def handle_in("men", payload, socket) do
    [{_,temp}] = :ets.lookup(:eid, "curr_user")
    [{_,data}] = :ets.lookup(:nameToId, temp)


    [{_,msg}] = :ets.lookup(:mentions_table,data)

    Enum.each(msg, fn(m) ->
      [{_,[message,from,type]}] = :ets.lookup(:msgTable,m)
      push(socket, "men", %{message: message})
    end)
    {:noreply, socket}
  end


  def handle_in("login", payload, socket) do

    {_,usr} = Map.fetch(payload, "usr")
    {_,pswd} = Map.fetch(payload,"pswd")

    usr=:crypto.hash(:sha, usr) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)
    pswd = :crypto.hash(:sha, pswd) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)

    # [{_,data}] = :ets.lookup(:usrProcessTable, uid)
    # p = Enum.at(data, 0)
    if :ets.member(:usrProcessTable, usr) do

      [{_,data}] = :ets.lookup(:usrProcessTable, usr)
      p = Enum.at(data, 0)

      if p != pswd do
        push(socket, "login", %{message: "Invalid username/password"})
      else
        User.login(usr,pswd)
        :ets.insert_new(:eid, {"curr_user",usr})
        [{_,data}] = :ets.lookup(:eid, "curr_user")

        push(socket, "login", %{message: "User Logged in"})


        #prepare dashboard


        # get subscribers list
        [{_,mysub}] = :ets.lookup(:mysubs,usr)
        IO.inspect(mysub)

        if mysub != [] do
          Enum.each(mysub, fn(m) ->
            [{_,data}] = :ets.lookup(:nameToId, m)
            push(socket, "subscribe", %{message: data})
          end)
        end
        #get all tweets:

        [{_,msg}] = :ets.lookup(:send_table,usr)
        Enum.each(msg, fn(m) ->
          [{_,[message,from,type]}] = :ets.lookup(:msgTable,m)

          cond do
            type == 0 ->
              if from == usr do
                message = "You tweeted: #{message}"
                push(socket, "tweet", %{message: message, id: m})
              else
                [{_,data}] = :ets.lookup(:nameToId, from)
                message = "#{data} tweeted: #{message}"
                push(socket, "tweet", %{message: message, id: m})
              end
            type == 1->
              if from == usr do
                message = "You retweeted: #{message}"
                push(socket, "tweet", %{message: message, id: m})
              else
                [{_,data}] = :ets.lookup(:nameToId, from)
                message = "#{data} retweeted: #{message}"
                push(socket, "tweet", %{message: message, id: m})
              end
            type == 2 ->
              [{_,data}] = :ets.lookup(:nameToId, from)
              message = "#{data} mentioned you: #{message}"
              push(socket, "tweet", %{message: message, id: m})
          end
        end)

      end

    else
      push(socket, "login", %{message: "No such user"})
    end
    #User.login(usr,pswd)
    #broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("register", payload, socket) do

    {_,usr} = Map.fetch(payload, "usr")
    {_,pswd} = Map.fetch(payload,"pswd")

    temp = usr
    usr=:crypto.hash(:sha, usr) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)
    pswd = :crypto.hash(:sha, pswd) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)


    # [{_,data}] = :ets.lookup(:usrProcessTable, uid)
    # p = Enum.at(data, 0)
    if :ets.member(:usrProcessTable, usr) do
      push(socket, "register", %{message: "user already exists"})
    else
      TwitterApp.register(usr,pswd)
      :ets.insert(:nameToId, {usr,temp})
      push(socket, "register", %{message: "user created"})
    end
    #User.login(usr,pswd)
    #broadcast socket, "shout", payload
    #broadcast socket, "shout", payload
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
